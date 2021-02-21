//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 11.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter

public enum FileInfoType: String, Codable {
    case photo
    case document
}

public struct FileInfo: Codable {

    public let type: FileInfoType
    
    ///
    public enum Content: AutoCodable {
        case fileId(BotterAttachable)
        case url(String)
        case file(InputFile)
        
        var tg: Telegrammer.FileInfo? {
            switch self {
            case let .fileId(attachable):
                guard let attachmentId = attachable.attachmentId(for: .tg) else { return nil }
                return .fileId(attachmentId)
            case let .url(url):
                return .url(url)
            case let .file(file):
                return .file(file.tg)
            }
        }
    }
    
    let content: Content
    
    public init(type: FileInfoType, content: FileInfo.Content) {
        self.type = type
        self.content = content
    }
    
    var vk: Vkontakter.Attachment? {
        switch content {
        case let .fileId(attachable):
            switch type {
            case .photo:
                guard let attachmentId = attachable.attachmentId(for: .vk),
                      let photo = Vkontakter.Photo(from: attachmentId) else { return nil }
                return .photo(photo)
            case .document:
                guard let attachmentId = attachable.attachmentId(for: .vk),
                      let doc = Vkontakter.Doc(from: attachmentId) else { return nil }
                return .doc(doc)
            }
            
        case .url, .file:
            return nil
        }
    }
    
    func tgMedia(caption: String?) -> Telegrammer.InputMedia? {
        if case .file = content {
            debugPrint("files in groups not impletemnted yet")
            return nil
        }
        guard let mediaData = try? JSONEncoder().encode(content.tg),
              var media = String(data: mediaData, encoding: .utf8)?.trimmingCharacters(in: ["\""])
        else { return nil }
        media.removeAll(where: { $0 == "\\" })
        
        switch type {
        case .photo:
            return .inputMediaPhoto(.init(type: "photo", media: media, caption: caption, parseMode: nil))
        default:
            return nil
        }
    }
}

extension Telegrammer.InputMedia {
    var photoAndVideo: Telegrammer.InputMediaPhotoAndVideo? {
        switch self {
        case let .inputMediaPhoto(photo):
            return .inputMediaPhoto(photo)

        case let .inputMediaVideo(video):
            return .inputMediaVideo(video)

        default:
            return nil
        }
    }
}
