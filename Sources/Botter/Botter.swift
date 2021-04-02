import Vkontakter
import Telegrammer
import Foundation
import Logging
import NIO
import NIOHTTP1
import AsyncHTTPClient
import Vapor

let log = Logger(label: "com.gp-apps.botter")

public typealias Worker = EventLoopGroup

public protocol BotContextProtocol {
    var app: Application { get }
    var bot: Botter.Bot { get }
    var platform: AnyPlatform { get }
}

public struct BotContext: BotContextProtocol {
    public init(app: Application, bot: Bot, platform: AnyPlatform) {
        self.app = app
        self.bot = bot
        self.platform = platform
    }
    
    public let app: Application
    public let bot: Botter.Bot
    public let platform: AnyPlatform
}

public final class Bot {
    public struct Settings {
        public let vk: Vkontakter.Bot.Settings?
        public let tg: Telegrammer.Bot.Settings?

        public init(vk: Vkontakter.Bot.Settings? = nil, tg: Telegrammer.Bot.Settings? = nil) {
            self.vk = vk
            self.tg = tg
        }
    }
    
    public let tg: Telegrammer.Bot?
    public let vk: Vkontakter.Bot?

    public init(settings: Settings, numThreads: Int = System.coreCount) throws {
        if let tgSettings = settings.tg {
            tg = try .init(settings: tgSettings, numThreads: numThreads)
        } else {
            tg = nil
        }
        if let vkSettings = settings.vk {
            vk = try .init(settings: vkSettings, numThreads: numThreads)
        } else {
            vk = nil
        }
    }
    
    public func checkSecret(with update: Update?) -> Bool {
        guard let update = update else { return false }
        switch update.platform {
        case .tg:
            return true
        case .vk:
            return vk?.checkSecretKey(with: update.secret) ?? false
        }
        
    }
}

extension Bot {
    enum BotError: Error {
        case botNotFound
    }

    func requireVkBot() throws -> Vkontakter.Bot {
        guard let vk = vk else { throw BotError.botNotFound }
        return vk
    }
    
    func requireTgBot() throws -> Telegrammer.Bot {
        guard let tg = tg else { throw BotError.botNotFound }
        return tg
    }
}
