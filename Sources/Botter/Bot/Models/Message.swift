//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 03.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer

public struct Message {
    
    public let id: Int64
    
    public let text: String?

    public var fromId: Int64?

    public var chatId: Int64?
    
    public let command: String?
    
    public let attachments: [Attachment]
    
    public let platform: Platform<Telegrammer.Message, Vkontakter.Message>

}

extension Message: PlatformObject {

    public typealias Tg = Telegrammer.Message
    public typealias Vk = Vkontakter.Message
    
    init(from tg: Tg) {
        platform = .tg(tg)
        
        id = Int64(tg.messageId)
        text = tg.text
        fromId = tg.from?.id
        chatId = tg.chat.id
        if let entity = tg.entities?.first(where: { $0.type == .botCommand }), let text = text {
            let startIndex = text.index(text.startIndex, offsetBy: entity.offset + 1) // remove "/"
            let endIndex = text.index(startIndex, offsetBy: entity.length - 1)
            command = .init(text[startIndex ..< endIndex])
        } else {
            command = nil
        }
        attachments = tg.botterAttachments
    }

    init(from vk: Vk) {
        platform = .vk(vk)
        
        id = vk.id!
        text = vk.text
        chatId = nil
        fromId = vk.fromId
        if case let .input(command) = vk.payload {
            self.command = command
        } else {
            command = nil
        }
        attachments = vk.attachments?.botterAttachments ?? []
    }
    
    init?(params: Vkontakter.Bot.SendMessageParams, resp: Vkontakter.Bot.SendMessageResp) {
        guard let respItem = resp.items.first else { return nil }
        self.init(from: Vkontakter.Message(
            id: respItem.messageId, date: UInt64(Date().timeIntervalSince1970), peerId: respItem.peerId, fromId: nil,
            text: params.message, randomId: params.randomId != nil ? .init(params.randomId!) : nil,
            attachments: params.attachment, geo: nil, payload: params.payload, keyboard: params.keyboard,
            fwdMessages: params.forwardMessages?.array.map { Vkontakter.Message(id: $0) } ?? [],
            replyMessage: nil, action: nil, adminAuthorId: nil, conversationMessageId: nil,
            isCropped: nil, membersCount: nil, updateTime: nil, wasListened: nil, pinnedAt: nil
        ))
    }
    
    init?(params: Vkontakter.Bot.EditMessageParams, resp: VkFlag) {
        guard resp.bool else { return nil }
        self.init(from: Vkontakter.Message(
            id: params.messageId != nil ? Int64(params.messageId!) : nil,
            date: UInt64(Date().timeIntervalSince1970),
            peerId: params.peerId,
            fromId: nil,
            text: params.message,
            randomId: nil,
            attachments: params.attachment,
            keyboard: params.keyboard
        ))
    }
}
