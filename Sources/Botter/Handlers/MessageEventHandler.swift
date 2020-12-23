//
//  CallbackQueryHandler.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 23.04.2018.
//

import Foundation
import Vkontakter
import Telegrammer

/// Handler for MessageEvent updates
public class MessageEventHandler: Handler {

    public var name: String
    public let callback: HandlerCallback
    
    public lazy var vk: Vkontakter.Handler = Vkontakter.MessageEventHandler(name: name) { update, context throws in
        guard let update = Update(from: update) else { return }
        try! self.callback(update, nil)
    }
    
    public lazy var tg: Telegrammer.Handler = TgSimpleCallbackQueryHandler(name: name) { update, context in
        guard let update = Update(from: update) else { return }
        try! self.callback(update, nil)
    }

    public init(
        name: String = String(describing: MessageEventHandler.self),
        callback: @escaping HandlerCallback
        ) {
        self.callback = callback
        self.name = name
    }
}
