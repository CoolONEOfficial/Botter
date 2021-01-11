//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 21.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer
import AnyCodable

public struct MessageEvent: PlatformObject {
    
    public typealias Tg = Telegrammer.CallbackQuery
    public typealias Vk = Vkontakter.MessageEvent
    
    public let platform: Platform<Tg, Vk>

    public let id: String
    public let data: AnyCodable
    public let peerId: Int64?
    public let fromId: Int64?
    
    public func decodeData<T: Decodable>(decoder: JSONDecoder = .snakeCased) throws -> T {
        try decoder.decode(T.self, from: JSONSerialization.data(withJSONObject: data.value))
    }
    
    init?(from tg: Tg) {
        platform = .tg(tg)

        id = tg.id
        peerId = nil
        fromId = tg.from.id
        guard let data = tg.data?.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        self.data = .init(jsonObject)
    }

    init?(from vk: Vk) {
        platform = .vk(vk)
        
        id = vk.eventId
        peerId = vk.peerId
        fromId = vk.userId
        guard let data = vk.payload else { return nil }
        self.data = data
    }
}
