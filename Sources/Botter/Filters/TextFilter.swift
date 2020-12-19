//
//  TextFilter.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 21.04.2018.
//

import Foundation
import Telegrammer
import Vkontakter

/// Filters messages to allow only those which contains text
public extension Filters {
    static var text = Filters(vk: Vkontakter.Filters.text, tg: Telegrammer.Filters.text)
}
