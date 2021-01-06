//
//  PhotoFilter.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 21.04.2018.
//

import Foundation
import Vkontakter
import Telegrammer

/// Filters messages to allow only those which contains photo
public extension Filters {
    static var photo = Filters(vk: Vkontakter.Filters.photo, tg: Telegrammer.Filters.photo)
}
