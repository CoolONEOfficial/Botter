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
    var destination: SendDestination? { get }
}

extension Message: Replyable {
    public var destination: SendDestination? {
        get {
            if let chatId = self.chatId {
                return .chatId(chatId)
            }
            if let userId = self.userId {
                return .userId(userId)
            }
            return nil
        }
        set {
            fatalError()
        }
    }
    
    public var userId: Int64? {
        get { fromId }
        set { fromId = newValue }
    }
}

public extension Message {
    func reply(_ params: Bot.SendMessageParams, context: BotContextProtocol) throws -> Future<[Message]> {
        try replyMessage(params, context: context)
    }
}

extension MessageEvent: Replyable {
    public var destination: SendDestination? {
        get {
            if let chatId = self.chatId {
                return .chatId(chatId)
            }
            if let userId = self.userId {
                return .userId(userId)
            }
            return nil
        }
        set {
            fatalError()
        }
    }
    
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
    func reply(_ params: Bot.SendMessageEventAnswerParams, platform: AnyPlatform? = nil, context: BotContextProtocol) throws -> Future<Bool> {
        let platform = platform ?? context.platform
        var params = params
        params.event = self
        return try context.bot.sendMessageEventAnswer(params, platform: platform)
    }
}

public extension Replyable where Self: PlatformObject {
    func replyMessage(_ params: Bot.SendMessageParams, context: BotContextProtocol) throws -> Future<[Message]> {
        if let destination = destination {
            params.destination = destination
        } else {
            throw Bot.SendMessageError.destinationNotFound
        }
        return try context.bot.sendMessage(params, platform: platform.any, context: context)
    }
}
