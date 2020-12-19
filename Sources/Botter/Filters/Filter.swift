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
 
 Filters may be combined using bitwise operators:
 
 - And:
 ```
 (Filters.text && Filters.entity([.mention]))
 ```
 - Or:
 ```
 (Filters.audio || Filters.video)
 ```
 - Not:
 ```
 !Filters.command
 ```
 Also works with more than two filters:
 ```
 (Filters.text && (Filters.entity([.url, .mention]) || Filters.entity([.command])))
 (Filters.text && !Filters.forwarded)
 ```
 If you want to create your own filters create a struct conforming `Filter` protocol and implement a `filter` method that returns a boolean: `true`, if the message should be handled, `false` otherwise.
 */
public class Filters {

    let vk: Vkontakter.Filters
    let tg: Telegrammer.Filters
    
//    private enum Operation {
//        case and
//        case or
//        case not
//    }
//
//    private typealias Compound = (lhs: Filters, rhs: Filters, op: Operation)
//
//    private var atomicFilter: Filter?
//    private var simpleFilters: Filters?
//    private var compoundFilter: Compound?

    public init(vk: Vkontakter.Filters, tg: Telegrammer.Filters) {
        self.vk = vk
        self.tg = tg
    }

    
//    public init(filter: Filter) {
//        self.atomicFilter = filter
//    }
//
//    public init(filters: Filters) {
//        self.simpleFilters = filters
//    }
//
//    private init(lhs: Filters, rhs: Filters, op: Operation) {
//        self.compoundFilter = (lhs, rhs, op)
//    }

    public func check(_ message: Message) -> Bool {
        switch message.platform {
        case let .tg(tg):
            return self.tg.check(tg)
        case let .vk(vk):
            return self.vk.check(vk)
        }
    }
}

//public extension Filters {
//    static func && (lhs: Filters, rhs: Filters) -> Filters {
//        return Filters(lhs: lhs, rhs: rhs, op: .and)
//    }
//
//    static func || (lhs: Filters, rhs: Filters) -> Filters {
//        return Filters(lhs: lhs, rhs: rhs, op: .or)
//    }
//
//    static prefix func ! (filter: Filters) -> Filters {
//        return Filters(lhs: filter, rhs: filter, op: .not)
//    }
//}
