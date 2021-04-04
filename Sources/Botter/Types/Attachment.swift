//
//  Attachment.swift
//
//
//  Created by Nickolay Truhin on 04.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter

public enum Attachment: AutoCodable {
    case photo(Photo)
    case document(Document)
}

public extension Attachment {
    var attachmentId: String {
        switch self {
        case let .photo(photo):
            return photo.attachmentId

        case let .document(doc):
            return doc.attachmentId
        }
    }

    func getUrl(context: BotContextProtocol) throws -> Future<String?>? {
        let app = context.app
        switch self {
        case let .photo(photo):
            switch photo.platform {
            case let .tg(tg):
                return try tg.largerElement!.getUrl(context: context)
                
            case let .vk(vk):
                return app.eventLoopGroup.future(vk.sizes?.sorted { $0.width ?? 0 > $1.width ?? 0 }.first?.url)
            }

        case let .document(doc):
            switch doc.platform {
            case let .tg(tg):
                return try tg.getUrl(context: context)
                
            case let .vk(vk):
                return app.eventLoopGroup.future(vk.url)
            }
        }
    }
}

protocol TgFileIdentificable {
    var fileId: String { get }
}

extension Telegrammer.Document: TgFileIdentificable {}
extension Telegrammer.File: TgFileIdentificable {}
extension Telegrammer.PhotoSize: TgFileIdentificable {}

extension TgFileIdentificable {
    func getUrl(context: BotContextProtocol) throws -> Future<String?>? {
        let bot = context.bot
        return try bot.tg?.getFile(params: .init(fileId: fileId)).map { file in
            guard let path = file.filePath else { return nil }
            return "https://api.telegram.org/file/bot\(bot.tg!.settings.token)/\(path)"
        }
    }
}

extension Telegrammer.Message {
    var botterAttachments: [Attachment] {
        var attachments = [Attachment]()
        
        if let doc = document, let botterDoc = Document(from: doc) {
            attachments.append(.document(botterDoc))
        }
        
        if let photo = photo, let botterPhoto = Photo(from: photo) {
            attachments.append(.photo(botterPhoto))
        }
        
        return attachments
    }
}

extension Vkontakter.ArrayByComma where Element == Vkontakter.Attachment {
    var botterAttachments: [Attachment] {
        array.compactMap { attachment in
            switch attachment {
            case let .photo(photoValue):
                guard let photo = Photo(from: photoValue) else { return nil }
                return .photo(photo)
            case let .doc(docValue):
                guard let doc = Document(from: docValue) else { return nil }
                return .document(doc)
            }
        }
    }
}
