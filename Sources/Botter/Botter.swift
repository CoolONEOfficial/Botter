import Vkontakter
import Telegrammer
import Foundation
import Logging
import NIO
import NIOHTTP1
import AsyncHTTPClient

let log = Logger(label: "com.gp-apps.botter")

public typealias Worker = EventLoopGroup

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
