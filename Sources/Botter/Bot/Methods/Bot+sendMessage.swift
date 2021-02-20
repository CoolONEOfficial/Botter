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
    
    enum SendMessageError: Error {
        case botNotFound
        case destinationNotFound
        case textNotFound
    }
    
    /// Parameters container struct for `sendMessage` method
    class SendMessageParams: Codable {

        /// Идентификатор чата, которому отправляется сообщение. (только для Tg)
        public var chatId: Int64?
        
        /// Идентификатор пользователя, которому отправляется сообщение. (для Vk или Tg)
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
        
        func tgMessage(chatId: Int64, _ content: String) -> Telegrammer.Bot.SendMessageParams {
            .init(chatId: .chat(chatId), text: content, replyMarkup: keyboard?.tg)
        }
        
        func tgPhoto(chatId: Int64, _ content: FileInfo.Content) -> Telegrammer.Bot.SendPhotoParams {
            .init(chatId: .chat(chatId), photo: content.tg, caption: text, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }
        
        func tgGroup(chatId: Int64, _ content: [FileInfo]) -> Telegrammer.Bot.SendMediaGroupParams {
            .init(chatId: .chat(chatId), media: content.compactMap { $0.tgMedia(caption: text)?.photoAndVideo })
        }
        
        func tgDocument(chatId: Int64, _ content: FileInfo.Content) -> Telegrammer.Bot.SendDocumentParams {
            .init(chatId: .chat(chatId), document: content.tg, caption: text, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }

        var vk: Vkontakter.Bot.SendMessageParams {
            .init(randomId: .random(), peerId: chatId ?? userId, message: text, attachment: attachments != nil ? .init(attachments!.compactMap { $0.vk }) : nil, keyboard: keyboard?.vk)
        }
        
    }

    @discardableResult
    func sendMessage<Tg, Vk>(params: SendMessageParams, platform: Platform<Tg, Vk>, app: Application) throws -> Future<Message> {
        switch platform {
        case .vk:
            guard let vk = vk else { throw SendMessageError.botNotFound }
            guard let peerId = params.userId else { throw SendMessageError.destinationNotFound }
            
            let vkParams = params.vk

            if let attachments = params.attachments, !attachments.isEmpty {

                var uploadedAttachments: [FileInfo?] = .init(repeating: nil, count: attachments.count)
                
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
                            uploadedAttachments[index] = .init(
                                type: res.fileInfoType,
                                content: .fileId(res.attachable.botterAttachable)
                            )
                        }
                        return uploadSingleFuture
                    }
                
                return futures.flatten(on: app.eventLoopGroup.next()).flatMap { attachments in
                    
                    vkParams.attachment?.array.append(contentsOf: uploadedAttachments.flatMap { $0?.vk })
                    return try! vk.sendMessage(params: vkParams).map { Message(params: vkParams, resp: $0)! }
                }
            }

            return try vk.sendMessage(params: vkParams).map { Message(params: vkParams, resp: $0)! }
        case .tg:
            guard let tg = tg else { throw SendMessageError.botNotFound }
            guard let chatId = params.chatId else { throw SendMessageError.destinationNotFound }
            
            if let attachments = params.attachments, !attachments.isEmpty {
                if attachments.count == 1 {
                    let attachment = attachments.first!
                    let future: Future<Message>
                    switch attachment.type {
                    case .photo:
                        let params = params.tgPhoto(chatId: chatId, attachment.content)
                        future = try tg.sendPhoto(params: params).map { Message(from: $0) }
                    case .document:
                        let params = params.tgDocument(chatId: chatId, attachment.content)
                        future = try tg.sendDocument(params: params).map { Message(from: $0) }
                    }
                    return future
                } else {
                    let params = params.tgGroup(chatId: chatId, attachments)
                    return try tg.sendMediaGroup(params: params).map { Message(from: $0.first!) }
                }
            }
            
            guard let text = params.text else { throw SendMessageError.textNotFound }
            let params = params.tgMessage(chatId: chatId, text)
            return try tg.sendMessage(params: params).map { Message(from: $0) }
        }
    }
}
