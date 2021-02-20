//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 13.12.2020.
//

import Foundation

public enum Platform<Tg: Codable, Vk: Codable> {
    case tg(Tg)
    case vk(Vk)
}

public extension Platform {
    func to<T: Codable>(_ value: T) -> Platform<T, T> {
        switch self {
        case .tg:
            return .tg(value)
        case .vk:
            return .vk(value)
        }
    }
}

extension Platform: Codable {

    enum CodingKeys: String, CodingKey {
        case tg
        case vk
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.tg), try container.decodeNil(forKey: .tg) == false {
            let tg = try container.decode(Tg.self, forKey: .tg)
            self = .tg(tg)
            return
        }
        if container.allKeys.contains(.vk), try container.decodeNil(forKey: .vk) == false {
            let vk = try container.decode(Vk.self, forKey: .vk)
            self = .vk(vk)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .tg(tg):
            try container.encode(tg, forKey: .tg)

        case let .vk(vk):
            try container.encode(vk, forKey: .vk)
        }
    }

}

//extension Platform: Codable {
//    enum CodingKeys: CodingKey {
//        case tg
//        case vk
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = decoder.container(keyedBy: CodingKeys.self)
//
//        container.
//    }
//}
