//
//  Bot+sendMessageEventAnswer.swift
//  
//
//  Created by Nickolay Truhin on 24.12.2020.
//

import Telegrammer
import Vkontakter
import Foundation

public extension Bot {
    
    /// Parameters container struct for `sendMessageEventAnswer` method
    struct SendMessageEventAnswerParams {

        /// Идентификатор события
        let eventId: String
        
        let userId: Int64
        
        let peerId: Int64?
        
        public enum `Type` {
            case notification(text: String, isAlert: Bool? = nil)
            case link(url: String)
            
            var vk: Vkontakter.EventData {
                switch self {
                case let .notification(text, _):
                    return .snackbar(.init(text: text))
                case let .link(url):
                    return .link(.init(link: url))
                }
            }
        }
        
        let type: Type
    
        var tg: Telegrammer.Bot.AnswerCallbackQueryParams {
            switch type {
            case let .notification(text, isAlert):
                return .init(callbackQueryId: eventId, text: text, showAlert: isAlert, url: nil, cacheTime: nil)
            case let .link(url):
                return .init(callbackQueryId: eventId, text: nil, showAlert: nil, url: url, cacheTime: nil)
            }
        }

        var vk: Vkontakter.Bot.SendMessageEventAnswerParams? {
            guard let peerId = peerId else {
                log.warning("peerId is needed for sendMessageEventAnswer for VK")
                return nil
            }
            return .init(eventId: eventId, userId: userId, peerId: peerId, eventData: type.vk)
        }
        
        public init(eventId: String, userId: Int64, peerId: Int64?, type: Bot.SendMessageEventAnswerParams.`Type`) {
            self.eventId = eventId
            self.userId = userId
            self.peerId = peerId
            self.type = type
        }
        
        public init(event: MessageEvent, type: Bot.SendMessageEventAnswerParams.`Type`) {
            self.init(eventId: event.id, userId: event.userId, peerId: event.peerId, type: type)
        }
    }

    @discardableResult
    func sendMessageEventAnswer<Tg, Vk>(params: SendMessageEventAnswerParams, platform: Platform<Tg, Vk>) throws -> Future<Bool>? {
        switch platform {
        case .vk:
            guard let paramsVk = params.vk else { return nil }
            return try vk?.sendMessageEventAnswer(params: paramsVk).map { $0.bool }
        case .tg:
            return try tg?.answerCallbackQuery(params: params.tg)
        }
    }
}
