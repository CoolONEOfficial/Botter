//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 13.12.2020.
//

import Foundation

public enum Platform<Tg, Vk> {
    case tg(Tg)
    case vk(Vk)
}

public extension Platform {
    var void: Platform<Void?, Void?> {
        switch self {
        case .tg(_):
            return .tg(nil)
        case .vk(_):
            return .vk(nil)
        }
    }
}
