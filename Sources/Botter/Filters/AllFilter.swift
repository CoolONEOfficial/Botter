//
//  AllFilter.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 21.04.2018.
//

import Foundation
import Vkontakter
import Telegrammer

/// Filter for any update, said "no filter"
public extension Filters {
    static var all = Filters(vk: Vkontakter.Filters.all, tg: Telegrammer.Filters.all)
}
