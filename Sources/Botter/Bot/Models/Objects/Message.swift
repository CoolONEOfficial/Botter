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
    public let text: String?
    public let fromId: Int64?
    
    public let command: String?
    
    public let platform: Platform<Telegrammer.Message, Vkontakter.Message>
    
    init(from tg: Telegrammer.Message) {
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
    }

    init(from vk: Vkontakter.Message) {
        platform = .vk(vk)
        
        text = vk.text
        fromId = vk.fromId
        command = vk.payload?.command?.rawValue
    }
}
