//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer

public struct Update {
    
    public enum Content: AutoCodable {
        case message(Message)
        case event(MessageEvent)
    }

    public let content: Content
    
    public let platform: Platform<Telegrammer.Update, Vkontakter.Update>
    
    public let secret: String?

}

extension Update: PlatformObject {
    
    public typealias Tg = Telegrammer.Update
    public typealias Vk = Vkontakter.Update
    
    public init?(from vk: Vk?) {
        guard let vk = vk, let object = vk.object else { return nil }
        
        platform = .vk(vk)
        switch object {
        case let .messageWrapper(wrapper):
            content = .message(Message(from: wrapper.message))
        case let .event(event):
            guard let event = MessageEvent(from: event) else { return nil }
            content = .event(event)
        case let .message(message):
            content = .message(Message(from: message))
        }
        secret = vk.secret
    }
    
    public init?(from tg: Tg?) {
        guard let tg = tg else { return nil }

        platform = .tg(tg)
        secret = nil
        
        if let message = tg.message {
            content = .message(Message(from: message))
        } else if let callbackQuery = tg.callbackQuery {
            guard let event = MessageEvent(from: callbackQuery) else { return nil }
            content = .event(event)
        } else {
            return nil
        }
    }
    
}
