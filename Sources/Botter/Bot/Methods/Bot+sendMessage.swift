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
    var fileInfoType: FileInfoType {
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

public enum SendDestination: AutoCodable {
    case chatId(Int64)
    case username(String)
    case userId(Int64)
}

public extension SendDestination {
    init(platform: AnyPlatform, id: Int64) {
        switch platform {
        case .tg:
            self = .chatId(id)
        case .vk:
            self = .userId(id)
        }
    }
    
    var userId: Int64? {
        if case let .userId(id) = self {
            return id
        }
        return nil
    }
    
    var chatId: Int64? {
        if case let .chatId(id) = self {
            return id
        }
        return nil
    }
    
    var peerId: Int64? {
        switch self {
        case let .chatId(chatId):
            return chatId
        case let .userId(userId):
            return userId
        default:
            return nil
        }
    }
    
    func tgChatId() throws -> Telegrammer.ChatId {
        switch self {
        case let .chatId(chatId):
            return .chat(chatId)
        case .userId, .username:
            throw Bot.SendMessageError.destinationNotFound
        }
    }
}

public extension Bot {
    
    enum SendMessageError: Error {
        case destinationNotFound
        case textNotFound
        case platformAttachmentIdNotFound
    }
    
    /// Parameters container struct for `sendMessage` method
    class SendMessageParams: Codable {

//        /// Идентификатор чата, которому отправляется сообщение. (только для Tg)
//        public var chatId: Int64?
//
//        /// Идентификатор пользователя, которому отправляется сообщение. (для Vk или Tg)
//        public var userId: Int64?
//
        public var destination: SendDestination?

        /// Текст личного сообщения.
        public var text: String?
        
        /// Объект, описывающий клавиатуру бота.
        public var keyboard: Keyboard?
        
        /// Вложения прикрепленные к сообщению.
        public var attachments: [FileInfo]?

        public convenience init?(to replyable: Replyable, text: String? = nil, keyboard: Keyboard? = nil, attachments: [FileInfo]? = nil) {
            guard let destination = replyable.destination else { return nil }
            self.init(//chatId: replyable.chatId, userId: replyable.userId,
                destination: destination, text: text, keyboard: keyboard, attachments: attachments)
        }
        
        public init(//chatId: Int64? = nil, userId: Int64? = nil,
            destination: SendDestination? = nil,
            text: String? = nil, keyboard: Keyboard? = nil, attachments: [FileInfo]? = nil) {
//            self.chatId = chatId
//            self.userId = userId
            self.destination = destination
            self.text = text
            self.keyboard = keyboard
            self.attachments = attachments
        }
        
        func tgMessage(destination: SendDestination, _ content: String) throws -> Telegrammer.Bot.SendMessageParams {
            .init(chatId: try destination.tgChatId(), text: content, replyMarkup: keyboard?.tg)
        }
        
        func tgPhoto(destination: SendDestination, _ content: FileInfo.Content) throws -> Telegrammer.Bot.SendPhotoParams {
            guard let photo = content.tg else { throw SendMessageError.platformAttachmentIdNotFound }
            return .init(chatId: try destination.tgChatId(), photo: photo, caption: text, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }
        
        func tgGroup(destination: SendDestination, _ content: [FileInfo]) throws -> Telegrammer.Bot.SendMediaGroupParams {
            .init(chatId: try destination.tgChatId(), media: content.compactMap { $0.tgMedia(caption: text)?.photoAndVideo })
        }
        
        func tgDocument(destination: SendDestination, _ content: FileInfo.Content) throws -> Telegrammer.Bot.SendDocumentParams {
            guard let photo = content.tg else { throw SendMessageError.platformAttachmentIdNotFound }
            return .init(chatId: try destination.tgChatId(), document: photo, caption: text, parseMode: nil, disableNotification: nil, replyToMessageId: nil, replyMarkup: keyboard?.tg)
        }

        func vk(peerId: Int64) -> Vkontakter.Bot.SendMessageParams {
            .init(randomId: .random(), peerId: peerId, message: text, attachment: attachments != nil ? .init(attachments!.compactMap { $0.vk }) : nil, keyboard: keyboard?.vk)
        }
        
    }

    @discardableResult
    func sendMessage<Tg, Vk>(params: SendMessageParams, platform: Platform<Tg, Vk>, app: Application) throws -> Future<Message> {
        guard let destination = params.destination else { throw SendMessageError.destinationNotFound }
        switch platform {
        case .vk:
            let vk = try requireVkBot()
            
            switch destination {
            case let .chatId(peerId),
                 let .userId(peerId):
                return try sendVkMessage(vk: vk, params: params, peerId: peerId, app: app)
            
            case let .username(username):
                return try vk.getUser(params: .init(userIds: [ .username(username) ])).map(\.first?.id).unwrap(orError: SendMessageError.destinationNotFound).flatMap { userId in
                    try! self.sendVkMessage(vk: vk, params: params, peerId: userId, app: app)
                }
            }
            
        case .tg:
            let tg = try requireTgBot()
            
            return try sendTgMessage(tg: tg, params: params, destination: destination, app: app)
        }
    }
    
    private func sendVkMessage(vk: Vkontakter.Bot, params: SendMessageParams, peerId: Int64, app: Application) throws -> Future<Message> {
        
        let vkParams = params.vk(peerId: peerId)

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
                
                vkParams.attachment?.array.append(contentsOf: uploadedAttachments.compactMap { $0?.vk })
                return try! vk.sendMessage(params: vkParams).map { Message(params: vkParams, resp: $0)! }
            }
        }

        return try vk.sendMessage(params: vkParams).map { Message(params: vkParams, resp: $0)! }
    }
    
    private func sendTgMessage(tg: Telegrammer.Bot, params: SendMessageParams, destination: SendDestination, app: Application) throws -> Future<Message> {
        if let attachments = params.attachments, !attachments.isEmpty {
            if attachments.count == 1 {
                let attachment = attachments.first!
                let future: Future<Message>
                switch attachment.type {
                case .photo:
                    let params = try params.tgPhoto(destination: destination, attachment.content)
                    future = try tg.sendPhoto(params: params).map { Message(from: $0) }
                case .document:
                    let params = try params.tgDocument(destination: destination, attachment.content)
                    future = try tg.sendDocument(params: params).map { Message(from: $0) }
                }
                return future
            } else {
                let params = try params.tgGroup(destination: destination, attachments)
                return try tg.sendMediaGroup(params: params).map { Message(from: $0.first!) }
            }
        }
        
        guard let text = params.text else { throw SendMessageError.textNotFound }
        let params = try params.tgMessage(destination: destination, text)
        return try tg.sendMessage(params: params).map { Message(from: $0) }
    }
}
