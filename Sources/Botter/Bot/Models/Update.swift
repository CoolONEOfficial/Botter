//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer

public final class Update {
    public enum Content {
        case message(Message)
    }

    public let content: Content
    
    public let platform: Platform<Telegrammer.Update, Vkontakter.Update>
    
    public let secret: String?
    
    public init?(from vk: Vkontakter.Update?) {
        guard let vk = vk, let object = vk.object else { return nil }
        
        platform = .vk(vk)
        switch object {
        case let .message(message):
            content = .message(.init(from: message.message))
        }
        secret = vk.secret
    }
    
    public init?(from tg: Telegrammer.Update?) {
        guard let tg = tg, let message = tg.message ?? tg.editedMessage else { return nil }

        platform = .tg(tg)
        content = .message(.init(from: message))
        secret = nil
    }
}
