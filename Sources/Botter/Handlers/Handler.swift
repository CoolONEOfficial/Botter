//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 05.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer
import Vapor

public typealias HandlerCallback = (_ update: Update, _ context: BotContextProtocol) throws -> Void

/**
 Protocol for any update handler
 
 Every handler must implement `check` and `handle` methods
 */
public protocol Handler {
    var name: String { get }
    var vk: Vkontakter.Handler { get }
    var tg: Telegrammer.Handler { get }
    var callback: HandlerCallback { get }
    var app: Application! { get set }
    var bot: Bot! { get set }

    func check(update: Update) -> Bool
    func handle(update: Update, dispatcher: Dispatcher)
}

extension Handler {
    internal func context(_ platform: AnyPlatform) -> BotContext {
        .init(app: app, bot: bot, platform: platform)
    }
    
    public var name: String {
        return String(describing: Self.self)
    }
    
    public func check(update: Update) -> Bool {
        switch update.platform {
        case let .tg(tg):
            return self.tg.check(update: tg)
        case let .vk(vk):
            return self.vk.check(update: vk)
        }
    }
    
    public func handle(update: Update, dispatcher: Dispatcher) {
        do {
            let context = BotContext(app: app, bot: bot, platform: update.platform.any)
            try callback(update, context)
        } catch {
            log.error(error.logMessage)
        }
    }
}
