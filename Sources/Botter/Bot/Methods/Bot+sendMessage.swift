//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 02.12.2020.
//

import Telegrammer
import Vkontakter
import Foundation

public extension Message {
    init(params: Vkontakter.Bot.SendMessageParams, resp: Vkontakter.Bot.SendMessageResp) {
        let respItem = resp.items.first!
        self.init(from: Vkontakter.Message(id: respItem.messageId, date: UInt64(Date().timeIntervalSince1970), peerId: respItem.peerId, fromId: nil, text: params.message, randomId: params.randomId != nil ? .init(params.randomId!) : nil, attachments: [], geo: nil, payload: params.payload, keyboard: params.keyboard, fwdMessages: params.forwardMessages?.map { Vkontakter.Message(id: $0) } ?? [], replyMessage: nil, action: nil, adminAuthorId: nil, conversationMessageId: nil, isCropped: nil, membersCount: nil, updateTime: nil, wasListened: nil, pinnedAt: nil))
    }
}

public extension Bot {
    
    /// Parameters container struct for `sendMessage` method
    struct SendMessageParams {

        /// Идентификатор пользователя, которому отправляется сообщение.
        let peerId: Int64

        /// Текст личного сообщения. Обязательный параметр, если не задан параметр attachment.
        let message: String
        
        /// Объект, описывающий клавиатуру бота.
        let keyboard: Keyboard?

        public init(peerId: Int64, message: String, keyboard: Keyboard? = nil) {
            self.peerId = peerId
            self.message = message
            self.keyboard = keyboard
        }
    
        var tg: Telegrammer.Bot.SendMessageParams {
            .init(chatId: .chat(peerId), text: message, replyMarkup: keyboard?.tg)
        }

        var vk: Vkontakter.Bot.SendMessageParams {
            .init(randomId: .random(), peerId: peerId, message: message, keyboard: keyboard?.vk)
        }
    }

    @discardableResult
    func sendMessage<Tg, Vk>(params: SendMessageParams, platform: Platform<Tg, Vk>) throws -> Future<Message>? {
        switch platform {
        case .vk:
            return try vk?.sendMessage(params: params.vk).map { .init(params: params.vk, resp: $0) }
        case .tg:
            return try tg?.sendMessage(params: params.tg).map { .init(from: $0) }
        }
    }
}
