//
//  RegexpFilter.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 21.04.2018.
//

import Foundation
import Vkontakter
import Telegrammer

/// Filters updates by searching for an occurence of pattern in the message text. The `NSRegularExpression` is used to determine whether an update should be filtered. Refer to the documentation of the `NSRegularExpression` for more information.
public extension Filters {
    static func regexp(pattern: String, options: NSRegularExpression.Options = []) -> Filters {
        return Filters(vk: .regexp(pattern: pattern, options: options), tg: .regexp(pattern: pattern, options: options))
    }
}
