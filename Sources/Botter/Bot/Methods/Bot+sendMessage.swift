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

public extension Bot {
    
    /// Parameters container struct for `sendMessage` method
    class SendMessageParams: Codable {

        /// Идентификатор чата, которому отправляется сообщение.
        public var chatId: Int64?
        
        ///
        public var userId: Int64?

        /// Текст личного сообщения.
        public var text: String?
        
        /// Объект, описывающий клавиатуру бота.
        public var keyboard: Keyboard?
        
        /// Вложения прикрепленные к сообщению.
        public var attachments: [FileInfo]?

        public convenience init(to replyable: Replyable, text: String? = nil, keyboard: Keyboard? = nil, attachments: [FileInfo]? = nil) {
            self.init(chatId: replyable.chatId, userId: replyable.userId, text: text, keyboard: keyboard, attachments: attachments)
        }
        
        public init(chatId: Int64? = nil, userId: Int64? = nil, text: String? = nil, keyboard: Keyboard? = nil, attachments: [FileInfo]? = nil) {
            self.chatId = chatId
            self.userId = userId
            self.text = text
            self.keyboard = keyboard
            self.attachments = attachments
        }
        
        func tgMessage(_ content: String) -> Telegrammer.Bot.SendMessageParams? {
            guard let chatId = chatId else { return nil }
            return .init(chatId: .chat(chatId), text: content, replyMarkup: keyboard?.tg)
        }
        
        func tgPhoto(_ content: FileInfo.Content) -> Telegrammer.Bot.SendPhotoParams? {
            guard let chatId = chatId else { return nil }
            return .init(chatId: .chat(chatId), photo: content.tg, caption: text, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }
        
        func tgGroup(_ content: [FileInfo]) -> Telegrammer.Bot.SendMediaGroupParams? {
            guard let chatId = chatId else { return nil }
            return .init(chatId: .chat(chatId), media: content.compactMap { $0.tgMedia(caption: text)?.photoAndVideo })
        }
        
        func tgDocument(_ content: FileInfo.Content) -> Telegrammer.Bot.SendDocumentParams? {
            guard let chatId = chatId else { return nil }
            return .init(chatId: .chat(chatId), document: content.tg, caption: text, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }

        var vk: Vkontakter.Bot.SendMessageParams {
            .init(randomId: .random(), peerId: chatId ?? userId, message: text, attachment: attachments != nil ? .init(attachments!.compactMap { $0.vk }) : nil, keyboard: keyboard?.vk)
        }
        
    }

    @discardableResult
    func sendMessage<Tg, Vk>(params: SendMessageParams, platform: Platform<Tg, Vk>, app: Application) throws -> Future<Message>? {
        assert(params.chatId != nil || params.userId != nil, "Specify peer or chat id!")
        switch platform {
        case .vk:
            guard let vk = vk, let peerId = params.chatId ?? params.userId else { return nil }
           
            let vkParams = params.vk

            if let attachments = params.attachments, !attachments.isEmpty {

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
                    
                    let uploadFuture: Future<[Vkontakter.Bot.SavedDoc]>
                    switch attachment.type {
                    case .photo:
                        uploadFuture = try vk.upload(vkFile, as: .photo, for: .message)
                    case .document:
                        uploadFuture = try vk.upload(vkFile, as: .doc(peerId: peerId), for: .message)
                    }

                    let uploadSingleFuture = uploadFuture.map({ res in res.first! })
                    uploadSingleFuture.whenSuccess { res in
                        params.attachments?[index] = .init(
                            type: res.fileInfoType,
                            content: .fileId(res.attachable.botterAttachable)
                        )
                    }
                    return uploadSingleFuture
                }
                
                return futures.flatten(on: app.eventLoopGroup.next()).flatMap { attachments in
                    try! vk.sendMessage(params: vkParams).map { Message(params: vkParams, resp: $0)! }
                }
            }

            return try vk.sendMessage(params: vkParams).map { Message(params: vkParams, resp: $0)! }
        case .tg:
            guard let tg = tg else { return nil }
            
            if let attachments = params.attachments, !attachments.isEmpty {
                if attachments.count == 1 {
                    let attachment = attachments.first!
                    let future: Future<Message>
                    switch attachment.type {
                    case .photo:
                        guard let params = params.tgPhoto(attachment.content) else { return nil }
                        future = try tg.sendPhoto(params: params).map { Message(from: $0) }
                    case .document:
                        guard let params = params.tgDocument(attachment.content) else { return nil }
                        future = try tg.sendDocument(params: params).map { Message(from: $0) }
                    }
                    return future
                } else {
                    guard let params = params.tgGroup(attachments) else { return nil }
                    return try tg.sendMediaGroup(params: params).map { Message(from: $0.first!) }
                }
            }
            
            guard let text = params.text, let params = params.tgMessage(text) else { return nil }
            return try tg.sendMessage(params: params).map { Message(from: $0) }
        }
    }
}
