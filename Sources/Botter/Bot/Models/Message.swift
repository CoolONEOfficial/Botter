//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 03.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer

public struct Message: PlatformObject {
    
    public typealias Tg = Telegrammer.Message
    public typealias Vk = Vkontakter.Message
    
    public let text: String?
    public let fromId: Int64?
    
    public let command: String?
    
    public let attachments: [Attachment]
    
    public let platform: Platform<Telegrammer.Message, Vkontakter.Message>
    
    init?(from tg: Tg) {
        platform = .tg(tg)
        
        text = tg.text
        fromId = tg.from?.id ?? tg.chat.id
        if let entity = tg.entities?.first(where: { $0.type == .botCommand }), let text = text {
            let startIndex = text.index(text.startIndex, offsetBy: entity.offset + 1) // remove "/"
            let endIndex = text.index(startIndex, offsetBy: entity.length - 1)
            command = .init(text[startIndex ..< endIndex])
        } else {
            command = nil
        }
        attachments = tg.botterAttachments
    }

    init?(from vk: Vk) {
        platform = .vk(vk)
        
        text = vk.text
        fromId = vk.fromId
        if case let .input(command) = vk.payload {
            self.command = command?.rawValue
        } else {
            command = nil
        }
        attachments = vk.attachments?.botterAttachments ?? []
    }
}
