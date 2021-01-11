//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 02.12.2020.
//

import Telegrammer
import Vkontakter
import Foundation
import NIO
import Vapor

public extension Message {
    init?(params: Vkontakter.Bot.SendMessageParams, resp: Vkontakter.Bot.SendMessageResp) {
        let respItem = resp.items.first!
        self.init(from: Vkontakter.Message(id: respItem.messageId, date: UInt64(Date().timeIntervalSince1970), peerId: respItem.peerId, fromId: nil, text: params.message, randomId: params.randomId != nil ? .init(params.randomId!) : nil, attachments: params.attachment, geo: nil, payload: params.payload, keyboard: params.keyboard, fwdMessages: params.forwardMessages?.map { Vkontakter.Message(id: $0) } ?? [], replyMessage: nil, action: nil, adminAuthorId: nil, conversationMessageId: nil, isCropped: nil, membersCount: nil, updateTime: nil, wasListened: nil, pinnedAt: nil))
    }
}


extension Vkontakter.Bot.SavedDoc {
    var fileInfoType: FileInfo.`Type` {
        switch self {
        case .graffiti(_):
            fatalError()
        case .audio(_):
            fatalError()
        case .doc(_):
            return .document
        case .photo(_):
            return .photo
        }
    }
}

public struct FileInfo: Codable {

    ///
    public enum `Type`: AutoCodable {
        case photo
        case document
    }

    public let type: `Type`
    
    ///
    public enum Content: AutoCodable {
        case fileId(BotterAttachable)
        case url(String)
        case file(InputFile)
        
        var tg: Telegrammer.FileInfo {
            switch self {
            case let .fileId(attachable):
                return .fileId(attachable.attachmentId)
            case let .url(url):
                return .url(url)
            case let .file(file):
                return .file(file.tg)
            }
        }
    }
    
    let content: Content
    
    public init(type: FileInfo.`Type`, content: FileInfo.Content) {
        self.type = type
        self.content = content
    }
    
    var vk: Vkontakter.Attachment? {
        guard case let .fileId(attachable) = content else { return nil }
        switch type {
        case .photo:
            guard let photo = Vkontakter.Photo(from: attachable.attachmentId) else { return nil }
            return .photo(photo)
        case .document:
            guard let doc = Vkontakter.Doc(from: attachable.attachmentId) else { return nil }
            return .doc(doc)
        }
    }
}

public struct InputFile: Codable {

    let data: Data
    let filename: String
    
    public init(data: Data, filename: String) {
        self.data = data
        self.filename = filename
    }

    var vk: Vkontakter.InputFile {
        .init(data: data, filename: filename)
    }
    
    var tg: Telegrammer.InputFile {
        .init(data: data, filename: filename)
    }
}

public extension Bot {
    
    /// Parameters container struct for `sendMessage` method
    class SendMessageParams: Codable {

        /// Идентификатор пользователя, которому отправляется сообщение.
        public var peerId: Int64?

        /// Текст личного сообщения.
        public var message: String?
        
        /// Объект, описывающий клавиатуру бота.
        public var keyboard: Keyboard?
        
        /// Вложения прикрепленные к сообщению.
        public var attachments: [FileInfo]?

        public init(peerId: Int64? = nil, message: String? = nil, keyboard: Keyboard? = nil, attachments: [FileInfo]? = nil) {
            assert(message != nil || attachments != nil)
            self.peerId = peerId
            self.message = message
            self.keyboard = keyboard
            self.attachments = attachments
        }
        
        func tgMessage(_ content: String) -> Telegrammer.Bot.SendMessageParams {
            .init(chatId: .chat(peerId!), text: content, replyMarkup: keyboard?.tg)
        }
        
        func tgPhoto(_ content: FileInfo.Content) -> Telegrammer.Bot.SendPhotoParams {
            .init(chatId: .chat(peerId!), photo: content.tg, caption: message, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }
        
        func tgGroup(_ content: [FileInfo]) -> Telegrammer.Bot.SendMediaGroupParams {
            .init(chatId: .chat(peerId!), media: content.compactMap { (_ attachment: FileInfo) -> InputMediaPhotoAndVideo? in
                if case .file = attachment.content {
                    debugPrint("files in groups not impletemnted yet")
                    return nil
                }
                guard let mediaData = try? JSONEncoder().encode(attachment.content.tg),
                      var media = String(data: mediaData, encoding: .utf8)?.trimmingCharacters(in: ["\""])
                else { return nil }
                media.removeAll(where: { $0 == "\\" })
                
                switch attachment.type {
                case .photo:
                    return .inputMediaPhoto(.init(type: "photo", media: media, caption: message, parseMode: nil))
                default:
                    return nil
//                case .document://////
//                    return .inputMediaVideo(.init(type: "video", media: attachment.content.tg, caption: message, parseMode: nil))
                }
            })
        }
        
        func tgDocument(_ content: FileInfo.Content) -> Telegrammer.Bot.SendDocumentParams {
            .init(chatId: .chat(peerId!), document: content.tg, caption: message, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }

        var vk: Vkontakter.Bot.SendMessageParams {
            .init(randomId: .random(), peerId: peerId, message: message, attachment: attachments != nil ? .init(attachments!.compactMap { $0.vk }) : nil, keyboard: keyboard?.vk)
        }
        
    }

    @discardableResult
    func sendMessage<Tg, Vk>(params: SendMessageParams, platform: Platform<Tg, Vk>, app: Application) throws -> Future<Message>? {
        switch platform {
        case .vk:
            if let attachments = params.attachments, !attachments.isEmpty {
                
                var params = params
                let futures: [Future<Vkontakter.Bot.SavedDoc>] = try attachments.enumerated()
                    .compactMap { (index, attachment) -> Future<Vkontakter.Bot.SavedDoc>? in
                    
                    let vkFile: Vkontakter.InputFile
                    switch attachment.content {
                    case .fileId: return nil

                    case let .url(url):
                        guard let url = URL(string: url) else { return nil }
                        guard let data = try? Data(contentsOf: url) else { return nil }
                        vkFile = .init(data: data, filename: url.lastPathComponent)
                        
                    case let .file(file):
                        vkFile = file.vk
                    }
                    
                    let uploadFuture: Future<[Vkontakter.Bot.SavedDoc]>?
                    switch attachment.type {
                    case .photo:
                        uploadFuture = try vk?.upload(vkFile, as: .photo, for: .message)
                    case .document:
                        uploadFuture = try vk?.upload(vkFile, as: .doc(peerId: params.peerId!), for: .message)
                    }

                    guard let uploadSingleFuture = uploadFuture?.map({ res in res.first! }) else { return nil }
                    uploadSingleFuture.whenSuccess { res in
                        params.attachments?[index] = .init(
                            type: res.fileInfoType,
                            content: .fileId(res.attachable.botterAttachable)
                        )
                    }
                    return uploadSingleFuture
                }
                
                return futures.flatten(on: app.eventLoopGroup.next()).flatMap { attachments in
                    try! self.vk!.sendMessage(params: params.vk).map { Message(params: params.vk, resp: $0)! }
                }
            }

            return try vk?.sendMessage(params: params.vk).map { Message(params: params.vk, resp: $0)! }
        case .tg:
            guard let tg = tg else { return nil }
            
            if let attachments = params.attachments, !attachments.isEmpty {
                if attachments.count == 1 {
                    let attachment = attachments.first!
                    let future: Future<Message>
                    switch attachment.type {
                    case .photo:
                        future = try tg.sendPhoto(params: params.tgPhoto(attachment.content)).map { Message(from: $0)! }
                    case .document:
                        future = try tg.sendDocument(params: params.tgDocument(attachment.content)).map { Message(from: $0)! }
                    }
                    return future
                } else {
                    return try tg.sendMediaGroup(params: params.tgGroup(attachments)).map { Message(from: $0.first!)! }
                }
            }
            
            return try tg.sendMessage(params: params.tgMessage(params.message!)).map { Message(from: $0)! }
        }
    }
}
