//
//  Webhooks.swift
//  
//
//  Created by Nickolay Truhin on 13.12.2020.
//

import Foundation
import AsyncHTTPClient
import NIO
import Vkontakter
import Telegrammer

/// Will take care of you webhooks updates
public class Webhooks: Connection {

    public let vk: Vkontakter.Webhooks?
    public let tg: Telegrammer.Webhooks?
    
    private let webhooks: [BaseWebhooks]

    public var worker: Worker

    public init(bot: Bot, dispatcher: Dispatcher, worker: Worker = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)) {
        self.worker = worker
        if let vkBot = bot.vk, let vkDispatcher = dispatcher.vk {
            vk = .init(bot: vkBot, dispatcher: vkDispatcher, worker: worker)
        } else {
            vk = nil
        }
        if let tgBot = bot.tg, let tgDispatcher = dispatcher.tg {
            tg = .init(bot: tgBot, dispatcher: tgDispatcher, worker: worker)
        } else {
            tg = nil
        }
        webhooks = ([ tg, vk ] as [BaseWebhooks?]).compactMap { $0 }
    }

    public func start() throws -> EventLoopFuture<Void> {
        try webhooks.map { try $0.start() }.flatten(on: worker.next())
    }

    public func stop() throws -> EventLoopFuture<Void> {
        try webhooks.map { try $0.stop() }.flatten(on: worker.next())
    }
}
