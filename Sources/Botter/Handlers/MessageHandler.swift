//
//  MessageHandler.swift
//  
//
//  Created by Nickolay Truhin on 13.12.2020.
//

import AsyncHTTPClient
import Telegrammer
import Vkontakter

/// Handler for bot messages, can handle normal messages, channel posts, edited messages
public class MessageHandler: Handler {

    /// Name of particular MessageHandler, needed for determine handlers instances of one class in groups
    public var name: String

    /// Option Set for `MessageHandler`
    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        ///Should “normal” message updates be handled?
        public static let messageUpdates = Options(rawValue: 1)
//        ///Should channel posts updates be handled?
//        public static let channelPostUpdates = Options(rawValue: 2)
//        ///Should “edited” message updates be handled?
//        public static let editedUpdates = Options(rawValue: 4)
    }

    let filters: Filters
    public let callback: HandlerCallback
    let options: Options

    public lazy var vk: Vkontakter.Handler = Vkontakter.MessageHandler(
        name: name, filters: filters.vk,
        options: .init(rawValue: options.rawValue)
    ) { update, context throws in
        guard let update = Update(from: update) else { return }
        try! self.callback(update, nil)
    }
    
    public lazy var tg: Telegrammer.Handler = Telegrammer.MessageHandler (
        name: name, filters: filters.tg,
        options: .init(rawValue: options.rawValue)
    ) { update, context throws in
        guard let update = Update(from: update) else { return }
        try! self.callback(update, nil)
    }
    
    public init(
        name: String = String(describing: MessageHandler.self),
        filters: Filters = .all,
        options: Options = [.messageUpdates],// .channelPostUpdates],
        callback: @escaping HandlerCallback
        ) {
        self.filters = filters
        self.callback = callback
        self.options = options
        self.name = name
    }
}
