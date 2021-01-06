//
//  Filter.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 21.04.2018.
//

import Foundation
import Vkontakter
import Telegrammer

///Base protocol for atomic filter
public protocol Filter {
    var vk: Vkontakter.Filters { get }
    var tg: Telegrammer.Filters { get }
    
    var name: String { get }
    func filter(message: Message) -> Bool
}

extension Filter {
    public func filter(message: Message) -> Bool {
        switch message.platform {
        case let .tg(tg):
            return self.tg.check(tg)
        case let .vk(vk):
            return self.vk.check(vk)
        }
    }
}

/**
 Class cluster for all filters.
 */
public class Filters {

    let vk: Vkontakter.Filters
    let tg: Telegrammer.Filters

    public init(vk: Vkontakter.Filters, tg: Telegrammer.Filters) {
        self.vk = vk
        self.tg = tg
    }

    public func check(_ message: Message) -> Bool {
        switch message.platform {
        case let .tg(tg):
            return self.tg.check(tg)
        case let .vk(vk):
            return self.vk.check(vk)
        }
    }
}
