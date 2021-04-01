//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer
import Dispatch
import NIO
import Logging
import AsyncHTTPClient
import Vapor

public class Dispatcher {
    public let vk: Vkontakter.Dispatcher?
    public let tg: Telegrammer.Dispatcher?
    private let dispatchers: [BaseDispatcher]
    private let bot: Bot
    private let app: Application?
    
    public init(bot: Bot, app: Application?, worker: Worker = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)) {
        if let vkBot = bot.vk {
            vk = .init(bot: vkBot, worker: worker)
        } else {
            vk = nil
        }
        if let tgBot = bot.tg {
            tg = .init(bot: tgBot, worker: worker)
        } else {
            tg = nil
        }
        self.bot = bot
        self.app = app
        dispatchers = ([tg, vk] as [BaseDispatcher?]).compactMap { $0 }
    }
    
    public func enqueue(bytebuffer: ByteBuffer) {
        for dispatcher in dispatchers {
            dispatcher.enqueue(bytebuffer)
        }
    }
}

public extension Dispatcher {
    /**
     Add new handler to group

     - Parameters:
     - handler: Handler to add in `Dispatcher`'s handlers queue
     - group: Group of `Dispatcher`'s handler queue, `zero` group by default
     */
    func add(handler: Handler, to group: HandlerGroup = .init(vk: .zero, tg: .zero)) {
        var handler = handler
        handler.app = app
        handler.bot = bot
        vk?.add(handler: handler.vk, to: group.vk)
        tg?.add(handler: handler.tg, to: group.tg)
    }

    /**
     Remove handler from specific group of `Dispatchers`'s queue

     Note: If in one group present more then one handlers with the same name, they both will be deleted

     - Parameters:
     - handler: Handler to be removed
     - group: Group from which handlers will be removed
     */
    func remove(handler: Handler, from group: HandlerGroup) {
        vk?.remove(handler: handler.vk, from: group.vk)
        tg?.remove(handler: handler.tg, from: group.tg)
    }
}
