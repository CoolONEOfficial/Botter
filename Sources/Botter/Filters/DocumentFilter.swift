//
//  DocumentFilter.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 21.04.2018.
//

import Foundation
import Telegrammer
import Vkontakter

/// Filters messages to allow only those which contains document
public extension Filters {
    static var document = Filters(vk: Vkontakter.Filters.document, tg: Telegrammer.Filters.document)
}

