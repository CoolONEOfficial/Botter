//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 20.03.2021.
//

import Foundation
import Telegrammer
import Vkontakter
import Vapor

public extension Bot {
    
    /// Parameters container struct for `forwardMessage` method
    class ForwardMessageParams: Codable {

        /// Destination of forwarding message
        public var destination: SendDestination
        
        /// Forwarding message
        public var message: Message
        
        func tg(destination: SendDestination, message: Message) throws -> Telegrammer.Bot.ForwardMessageParams? {
            guard let fromChatId = message.chatId else { return nil }
            return Telegrammer.Bot.ForwardMessageParams(chatId: try destination.tgChatId(), fromChatId: .chat(fromChatId), messageId: Int(message.id))
        }
        
    }
    
    @discardableResult
    func editMessage(params: ForwardMessageParams, app: Application) throws -> Future<Message>? {
        switch params.message.platform {
        case .vk:
            fatalError()
//            guard let vk = vk else { return nil }
//
//            guard let params = params.vk(message) else { return nil }
//            return try vk.editMessage(params: params).map { Message(params: params, resp: $0) }
            
        case .tg:
            guard let tg = tg else { return nil }

            guard let params = try params.tg(destination: params.destination, message: params.message) else { return nil }
            return try tg.forwardMessage(params: params).map { Message(from: $0) }
            
        }
    }

}
