//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 11.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter
import Vapor

public extension Bot {
    
    /// Parameters container struct for `editMessage` method
    class EditMessageParams: Codable {

        /// Текст личного сообщения.
        public var message: String?
        
        /// Объект, описывающий клавиатуру бота.
        public var keyboard: Keyboard?
        
        /// Вложения прикрепленные к сообщению.
        public var attachments: [FileInfo]?

        public init(message: String? = nil, keyboard: Keyboard? = nil, attachments: [FileInfo]? = nil) {
            assert(message != nil || attachments != nil)
            self.message = message
            self.keyboard = keyboard
            self.attachments = attachments
        }
        
        func tgMedia(_ content: FileInfo, _ message: Message) -> Telegrammer.Bot.EditMessageMediaParams? {
            guard let media = content.tgMedia(caption: message.text), let chatId = message.chatId else { return nil }
            return .init(chatId: .chat(chatId), messageId: Int(message.id), media: media)
        }
        
        func tgText(_ content: String, _ message: Message) -> Telegrammer.Bot.EditMessageTextParams? {
            guard let chatId = message.chatId else { return nil }
            return .init(chatId: .chat(chatId), messageId: Int(message.id), text: content)
        }
        
        func tgCaption(_ content: String, _ message: Message) -> Telegrammer.Bot.EditMessageCaptionParams? {
            guard let chatId = message.chatId else { return nil }
            return .init(chatId: .chat(chatId), messageId: Int(message.id), caption: content)
        }
        
        func tgReplyMarkup(_ content: Keyboard, _ message: Message) -> Telegrammer.Bot.EditMessageReplyMarkupParams? {
            guard let chatId = message.chatId else { return nil }
            return .init(chatId: .chat(chatId), messageId: Int(message.id), replyMarkup: content.tgInline)
        }
        
        func vk(_ message: Message) -> Vkontakter.Bot.EditMessageParams? {
            guard let chatId = message.chatId else { return nil }
            return .init(peerId: chatId, message: message.text, attachment: attachments != nil ? .init(attachments!.compactMap { $0.vk }) : nil, keyboard: keyboard?.vk)
        }
        
    }
    
    @discardableResult
    func editMessage(_ message: Message, params: EditMessageParams, app: Application) throws -> Future<Message?>? {
        switch message.platform {
        case .vk:
            guard let vk = vk else { return nil }
            
            guard let params = params.vk(message) else { return nil }
            return try vk.editMessage(params: params).map { Message(params: params, resp: $0) }
            
        case .tg:
            guard let tg = tg else { return nil }
            
            var futures = [Future<MessageOrBool>]()
            
            if let attachments = params.attachments {
                futures.append(contentsOf: try attachments.compactMap { attachment in
                    guard let params = params.tgMedia(attachment, message) else { return nil }
                    return try tg.editMessageMedia(params: params)
                })
            }
            
            if let keyboard = params.keyboard {
                futures.append(try tg.editMessageReplyMarkup(params: params.tgReplyMarkup(keyboard, message)))
            }
            
            if let text = params.message {
                if message.attachments.isEmpty {
                    guard let params = params.tgText(text, message) else { return nil }
                    futures.append(try tg.editMessageText(params: params))
                } else {
                    futures.append(try tg.editMessageCaption(params: params.tgCaption(text, message)))
                }
            }
            
            return futures.flatten(on: app.eventLoopGroup.next()).map { $0.last?.botterMessage }
        }
    }

}

extension Telegrammer.MessageOrBool {
    var botterMessage: Message? {
        switch self {
        case let .message(message):
            return Message(from: message)

        default:
            return nil
        }
    }
}
