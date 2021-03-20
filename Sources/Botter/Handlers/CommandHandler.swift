//
//  MessageHandler.swift
//
//
//  Created by Nickolay Truhin on 13.12.2020.
//

import AsyncHTTPClient
import Telegrammer
import Vkontakter
import Vapor

/// Handler for bot messages, can handle normal messages, channel posts, edited messages
public class CommandHandler: Handler {


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
    }

    let commands: [String]
    let filters: Filters
    public let callback: HandlerCallback
    let options: Options
    public var app: Application!
    public var bot: Bot!

    public lazy var vk: Vkontakter.Handler = Vkontakter.CommandHandler(
        name: name, commands: commands, filters: filters.vk,
        options: .init(rawValue: options.rawValue)
    ) { update, _ throws in
        guard let update = Update(from: update) else { return }
        try! self.callback(update, self.context(update.platform.any))
    }
    
    public lazy var tg: Telegrammer.Handler = Telegrammer.CommandHandler (
        name: name, commands: commands.map { "/" + $0 }, filters: filters.tg,
        options: .init(rawValue: options.rawValue)
    ) { update, _ throws in
        guard let update = Update(from: update) else { return }
        try! self.callback(update, self.context(update.platform.any))
    }
    
    public init(
        name: String = String(describing: CommandHandler.self),
        commands: [String],
        filters: Filters = .all,
        options: Options = [],
        callback: @escaping HandlerCallback
        ) {
        self.filters = filters
        self.commands = commands
        self.callback = callback
        self.options = options
        self.name = name
    }
}
