//
//  File.swift
//
//
//  Created by Nickolay Truhin on 03.12.2020.
//

import Vapor
import Vkontakter
import Telegrammer
import TelegrammerMiddleware
import VkontakterMiddleware

public protocol BotterMiddleware: Middleware {
    var dispatcher: Dispatcher { get }
    var bot: Bot { get }
    var middlewares: [Middleware] { get }
}

public struct VkontakterMiddlewareMock: VkontakterMiddleware {
    public init(_ dispatcher: Vkontakter.Dispatcher, _ bot: Vkontakter.Bot, _ path: String) {
        self.dispatcher = dispatcher
        self.bot = bot
        self.path = path
    }
    
    public var path: String
    public var dispatcher: Vkontakter.Dispatcher
    public var bot: Vkontakter.Bot
}

public struct TelegrammerMiddlewareMock: TelegrammerMiddleware {
    public init(_ dispatcher: Telegrammer.Dispatcher, _ bot: Telegrammer.Bot, _ path: String) {
        self.dispatcher = dispatcher
        self.bot = bot
        self.path = path
    }
    
    public var path: String
    public var dispatcher: Telegrammer.Dispatcher
    public var bot: Telegrammer.Bot
}

extension Middleware {
    public var mdPath: String {
        switch self {
        case let vk as VkontakterMiddleware:
            return vk.path
        case let tg as TelegrammerMiddleware:
            return tg.path
        default:
            fatalError("Unknown middleware")
        }
    }
    
    func setWebhooks(_ serverName: String?) throws -> EventLoopFuture<Bool> {
        switch self {
        case let vk as VkontakterMiddleware:
            return try vk.setWebhooks(serverName: serverName).map { true }
        case let tg as TelegrammerMiddleware:
            return try tg.setWebhooks()
        default:
            fatalError("Unknown middleware")
        }
    }
}

fileprivate struct FailResponder: Responder {
    static let shared: Self = .init()
    
    enum Error: Swift.Error { case  failed }
    
    func respond(to request: Request) -> EventLoopFuture<Response> {
        return request.eventLoop.makeSucceededFuture(.init())
    }
}

public extension BotterMiddleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        debugPrint("Request to \(request.url.path)...")
        return middlewares.map { $0.respond(to: request, chainingTo: FailResponder.shared) }
            .flatten(on: request.eventLoop)
            .map { res in
                return res.first { $0.body.count > 0 }!
            }
    }

    func setWebhooks(_ serverName: String?, _ eventLoop: EventLoop) throws -> EventLoopFuture<Bool> {
        let futures = middlewares.compactMap { try? $0.setWebhooks(serverName) }
        guard !futures.isEmpty else { fatalError("all setWebhooks failed") }
        return futures.flatten(on: eventLoop).map { results in results.allSatisfy { $0 } }
    }
}
