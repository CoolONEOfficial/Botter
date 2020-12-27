//
//  CommandFilter.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 21.04.2018.
//

import Foundation
import Vkontakter
import Telegrammer

/// Messages which contains command
public extension Filters {
    static var command = Filters(vk: Vkontakter.Filters.command, tg: Telegrammer.Filters.command)
}
