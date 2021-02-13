//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 07.01.2021.
//

import Foundation
import Vapor
import NIO

public protocol Replyable {
    var userId: Int64? { get set }
    var chatId: Int64? { get set }
}

extension Message: Replyable {
    public var userId: Int64? {
        get { fromId }
        set { fromId = newValue }
    }
}

public extension Message {
    func reply(from bot: Bot, params: Bot.SendMessageParams, app: Application) throws -> Future<Message>? {
        try replyMessage(from: bot, params: params, app: app)
    }
}

extension MessageEvent: Replyable {
    public var userId: Int64? {
        get { fromId }
        set { fromId = newValue }
    }
    
    public var chatId: Int64? {
        get { peerId }
        set { peerId = newValue }
    }
}

extension Bot.SendMessageParams: Replyable {}

public extension MessageEvent {
    func reply(from bot: Bot, params: Bot.SendMessageEventAnswerParams, app: Application) throws -> Future<Bool>? {
        var params = params
        params.event = self
        return try bot.sendMessageEventAnswer(params: params, platform: platform)
    }
}

public extension Replyable where Self: PlatformObject {
    func replyMessage(from bot: Bot, params: Bot.SendMessageParams, app: Application) throws -> Future<Message>? {
        params.chatId = chatId
        params.userId = userId
        return try bot.sendMessage(params: params, platform: platform, app: app)
    }
}

public extension Replyable {
    mutating func setDestination(to replyable: Replyable) {
        chatId = replyable.chatId
        userId = replyable.userId
    }
}
