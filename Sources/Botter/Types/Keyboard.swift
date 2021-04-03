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
    
    public init(oneTime: Bool = false, inline: Bool = true, buttons: [[Button]]) {
        self.oneTime = oneTime
        self.buttons = buttons
        self.inline = inline
    }
    
    var tgInline: Telegrammer.InlineKeyboardMarkup {
        .init(
            inlineKeyboard: buttonsFor(\.inlineTg)
        )
    }
    
    var tg: Telegrammer.ReplyMarkup {
        inline
            ? .inlineKeyboardMarkup(tgInline)
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

extension Keyboard: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = [Button]
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(buttons: elements)
    }
}

public extension Array where Element == [Button] {
    mutating func safeAppend(_ buttons: [Button]) {
        guard let lastRow = last else {
            append(buttons)
            return
        }
        
        if lastRow.count < 2 && lastRow.map(\.text.count).reduce(0, +) < 18 {
            indices.last.map { self[$0] += buttons }
        } else {
            append(buttons)
        }
    }
}
