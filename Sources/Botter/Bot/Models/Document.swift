//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 04.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter

public struct Document: Codable {
    
    public let platform: Platform<Tg, Vk>
    
    /// Identifier for this file, which can be used to download or reuse the file
    public var attachmentId: String

    /// Optional. Document thumbnail as defined by sender
    public var thumb: [Photo.Size]?

    /// Optional. Original filename as defined by sender
    public var fileName: String?

    /// Optional. MIME type of the file as defined by sender
    public var mimeType: String?

    /// Optional. File size
    public var size: Int64?

}

extension Document: PlatformObject {

    public typealias Tg = Telegrammer.Document
    public typealias Vk = Vkontakter.Doc
    
    init?(from tg: Tg) {
        platform = .tg(tg)

        attachmentId = tg.fileId
        thumb = [ tg.thumb != nil ? Photo.Size(from: tg.thumb!) : nil ].compactMap { $0 }
        fileName = tg.fileName
        mimeType = tg.mimeType
        size = tg.fileSize != nil ? .init(tg.fileSize!) : nil
    }

    init?(from vk: Vk) {
        platform = .vk(vk)
        
        attachmentId = vk.attachmentId
        thumb = vk.preview?.photo?.sizes?.compactMap { Photo.Size(from: $0) }
        if let title = vk.title, let ext = vk.ext {
            fileName = title + ext
        } else {
            fileName = nil
        }
        mimeType = vk.ext?.mimeType()
        size = vk.size
        
    }
    
}
