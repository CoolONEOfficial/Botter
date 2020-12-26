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

public struct Keyboard {

    ///
    public let oneTime: Bool
    
    public struct Button {
        
        public enum Action {
            
            public struct Link {
                public let link: String
                
                public init(link: String) {
                    self.link = link
                }
            }

            public struct Pay {
                public let hash: String

                public init(hash: String) {
                    self.hash = hash
                }
            }
            
            public struct App {
                public let appId: Int64
                
                public let ownerId: Int64?
                
                public let hash: String

                public init(appId: Int64, ownerId: Int64? = nil, hash: String) {
                    self.appId = appId
                    self.ownerId = ownerId
                    self.hash = hash
                }
            }

            case text
            case link(Link)
            case location
            case pay(Pay)
            case app(App)
            case callback

            func vk(parent: Button) -> Vkontakter.Keyboard.Button.Action {
                let data = parent.payload?.description
                
                switch self {
                case .text:
                    return .text(.init(payload: data, label: parent.text))
                case let .link(linkValue):
                    return .link(.init(payload: data, label: parent.text, link: linkValue.link))
                case .location:
                    return .location(.init(payload: data))
                case let .pay(payValue):
                    return .pay(.init(payload: data, hash: payValue.hash))
                case let .app(appValue):
                    return .app(.init(payload: data, label: parent.text, appId: appValue.appId, ownerId: appValue.ownerId, hash: appValue.hash))
                case .callback:
                    return .callback(.init(payload: data, label: parent.text))
                }
            }
        }
        
        ///
        public let action: Action
        
        ///
        public let color: Vkontakter.Keyboard.Button.Color?
        
        ///
        public let text: String
        
        ///
        public let payload: AnyCodable?
        
        public init<T: Encodable>(text: String, action: Action, color: Vkontakter.Keyboard.Button.Color? = nil, data: T? = nil, dataEncoder: JSONEncoder = .snakeCased) throws {
            let test = String(data: try dataEncoder.encode(data), encoding: .utf8)!
            self.init(text: text, action: action, color: color, payload: .init(test))
        }

        public init(text: String, action: Action, color: Vkontakter.Keyboard.Button.Color? = nil, payload: AnyCodable? = nil) {
            self.text = text
            self.action = action
            self.color = color
            self.payload = payload
        }

        var inlineTg: Telegrammer.InlineKeyboardButton? {
            switch action {
            case .text:
                log.warning(.init(stringLiteral: "Telegram doesn't support text inline keyboard button!"))
                return nil
            case let .link(linkValue):
                return .init(text: text, url: linkValue.link, callbackData: payload?.description)
            case .location:
                log.warning(.init(stringLiteral: "Telegram doesn't support location inline keyboard button!"))
                return nil
            case .pay:
                return .init(text: text, pay: true)
            case .app(_):
                return .init(text: text) // TODO: callbackGame: CallbackGame()
            case .callback:
                return .init(text: text, callbackData: payload?.description)
            }
        }
        
        var tg: Telegrammer.KeyboardButton? {
            switch action {
            case .text:
                return .init(text: text)
            case .link:
                log.warning(.init(stringLiteral: "Telegram doesn't support link keyboard button!"))
                return nil
            case .location:
                return .init(text: text, requestContact: nil, requestLocation: true, requestPoll: nil)
            case .pay:
                log.warning(.init(stringLiteral: "Telegram doesn't support pay keyboard button!"))
                return nil
            case .app:
                log.warning(.init(stringLiteral: "Telegram doesn't support app keyboard button!"))
                return nil
            case .callback:
                log.warning(.init(stringLiteral: "Telegram doesn't support callback keyboard button!"))
                return nil
            }
        }

        var vk: Vkontakter.Keyboard.Button? {
            .init(action: action.vk(parent: self), color: color)
        }
    }
    
    ///
    public let buttons: [[Button]]
    
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
