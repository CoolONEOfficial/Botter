//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 20.12.2020.
//

import Foundation
import Telegrammer
import Vkontakter
import AnyCodable

public struct Keyboard: Codable {

    ///
    public let oneTime: Bool
    
    ///
    public var buttons: [[Button]]
    
    ///
    public let inline: Bool
    
    public init(oneTime: Bool, buttons: [[Button]], inline: Bool) {
        self.oneTime = oneTime
        self.buttons = buttons
        self.inline = inline
    }
    
    var tg: Telegrammer.ReplyMarkup {
        inline
            ? .inlineKeyboardMarkup(.init(
                inlineKeyboard: buttonsFor(\.inlineTg)
            ))
            : .replyKeyboardMarkup(.init(
                keyboard: buttonsFor(\.tg),
                resizeKeyboard: true,
                oneTimeKeyboard: oneTime,
                selective: nil
            ))
    }

    var vk: Vkontakter.Keyboard {
        .init(oneTime: oneTime, buttons: buttonsFor(\.vk), inline: inline)
    }
}

private extension Keyboard {
    func buttonsFor<T>(_ transform: (Button) -> T?) -> [[T]] {
        buttons.map { $0.compactMap(transform) }
    }
}
