//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 07.01.2021.
//

import Foundation
import Vapor
import NIO

public protocol Replyable: PlatformObject {
    var fromId: Int64? { get }
}

extension Message: Replyable {}

public extension Message {
    func reply(from bot: Bot, params: Bot.SendMessageParams, app: Application) throws -> Future<Message>? {
        try replyMessage(from: bot, params: params, app: app)
    }
}

extension MessageEvent: Replyable {}

public extension MessageEvent {
    func reply(from bot: Bot, params: Bot.SendMessageEventAnswerParams, app: Application) throws -> Future<Bool>? {
        var params = params
        params.event = self
        return try bot.sendMessageEventAnswer(params: params, platform: platform)
    }
}

public extension Replyable {
    func replyMessage(from bot: Bot, params: Bot.SendMessageParams, app: Application) throws -> Future<Message>? {
        var params = params
        guard let fromId = fromId else { return nil }
        params.peerId = fromId
        return try bot.sendMessage(params: params, platform: platform, app: app)
    }
}
