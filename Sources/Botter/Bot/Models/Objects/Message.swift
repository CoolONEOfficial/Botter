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
    
    public let platform: Platform<Telegrammer.Message, Vkontakter.Message>
    
    init(from tg: Telegrammer.Message) {
        platform = .tg(tg)
        
        text = tg.text
        fromId = tg.from?.id ?? tg.chat.id
    }

    init(from vk: Vkontakter.Message) {
        platform = .vk(vk)
        
        text = vk.text
        fromId = vk.fromId
    }
}
