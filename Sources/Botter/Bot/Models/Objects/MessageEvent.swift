//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 21.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer
import AnyCodable

public struct MessageEvent: PlatformObject {
    
    public typealias Tg = Telegrammer.CallbackQuery
    public typealias Vk = Vkontakter.MessageEvent
    
    public let platform: Platform<Tg, Vk>
    
    //public let message: Message?
    public let data: AnyCodable
    public let peerId: Int64
    
    init?(from tg: Tg) {
        platform = .tg(tg)
        
//        if let message = tg.message {
//            self.message = .init(from: message)
//        } else {
//            self.message = nil
//        }
        peerId = tg.from.id
        guard let data = tg.data else { return nil }
        self.data = .init(data)
//        text = tg.text
//        fromId = tg.from?.id ?? tg.chat.id
    }

    init?(from vk: Vk) {
        platform = .vk(vk)
        
        peerId = vk.peerId
        guard let data = vk.payload else { return nil }
        self.data = data
//        text = vk.text
//        fromId = vk.fromId
    }
}

//extension Message {
//    init(from event: Vkontakter.MessageEvent) {
//        fromId = event.peerId
//        text = event.
//    }
//}
