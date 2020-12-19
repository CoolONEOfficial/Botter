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
    convenience init(params: Vkontakter.Bot.SendMessageParams, resp: Vkontakter.Bot.SendMessageResp) {
        let respItem = resp.items.first!
        self.init(from: Vkontakter.Message(id: respItem.messageId, date: UInt64(Date().timeIntervalSince1970), peerId: respItem.peerId, fromId: nil, text: params.message, randomId: params.randomId != nil ? .init(params.randomId!) : nil, attachments: [], geo: nil, payload: params.payload, keyboard: .init(), fwdMessages: params.forwardMessages?.map { Vkontakter.Message(id: $0) } ?? [], replyMessage: nil, action: nil, adminAuthorId: nil, conversationMessageId: nil, isCropped: nil, membersCount: nil, updateTime: nil, wasListened: nil, pinnedAt: nil))
    }
}

public extension Bot {
    
    /// Parameters container struct for `sendMessage` method
    struct SendMessageParams: JSONEncodable {

        /// Идентификатор пользователя, которому отправляется сообщение.
        let peerId: Int64

        /// Текст личного сообщения. Обязательный параметр, если не задан параметр attachment.
        let message: String

        public init(peerId: Int64, message: String) {
            self.peerId = peerId
            self.message = message
        }
    
        var tg: Telegrammer.Bot.SendMessageParams {
            .init(chatId: .chat(peerId), text: message)
        }

        var vk: Vkontakter.Bot.SendMessageParams {
            .init(randomId: .random(), peerId: peerId, message: message)
        }
    }

    @discardableResult
    func sendMessage(params: SendMessageParams, platform: Platform<Void?, Void?>) throws -> Future<Message>? {
        switch platform {
        case .vk:
            return try vk?.sendMessage(params: params.vk).map { .init(params: params.vk, resp: $0) }
        case .tg:
            return try tg?.sendMessage(params: params.tg).map { .init(from: $0) }
        }
    }
}
