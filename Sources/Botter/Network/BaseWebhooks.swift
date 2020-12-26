//
//  BaseWebhooks.swift
//  
//
//  Created by Nickolay Truhin on 19.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer
import Vapor

protocol BaseWebhooks {
    func start(vkServerName: String?) throws -> EventLoopFuture<Void>
    func stop() throws -> EventLoopFuture<Void>
}

extension Vkontakter.Webhooks: BaseWebhooks {
    func start(vkServerName: String?) throws -> EventLoopFuture<Void> {
        try start(serverName: vkServerName)
    }
}
extension Telegrammer.Webhooks: BaseWebhooks {
    func start(vkServerName: String?) throws -> EventLoopFuture<Void> {
        try start()
    }
}
