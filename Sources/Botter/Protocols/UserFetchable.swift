//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 13.02.2021.
//

import Foundation
import Vkontakter
import Telegrammer

// MARK: - User Fetchanble

public protocol UserFetchable {
    var userInfo: UserInfo { get }
}

public enum UserInfo {
    case id(Int64?)
    case user(User?)
}

// MARK: - Implementation

// MARK: Vkontakter

extension Vkontakter.Message: UserFetchable {
    public var userInfo: UserInfo { .id(fromId) }
}

extension Vkontakter.MessageEvent: UserFetchable {
    public var userInfo: UserInfo { .id(fromId) }
}

// MARK: Telegrammer

extension Telegrammer.Message: UserFetchable {
    public var userInfo: UserInfo { .user(User(from: self.from)) }
}

extension Telegrammer.CallbackQuery: UserFetchable {
    public var userInfo: UserInfo { .user(User(from: self.from)) }
}

// MARK: Botter

extension Update: UserFetchable {
    public var userInfo: UserInfo {
        switch content {
        case let .event(event):
            return event.userInfo
        case let .message(message):
            return message.userInfo
        }
    }
}

extension MessageEvent: UserFetchable {
    public var userInfo: UserInfo { platform.fetchable.userInfo }
}

extension Message: UserFetchable {
    public var userInfo: UserInfo { platform.fetchable.userInfo }
}

extension Platform where Vk: UserFetchable, Tg: UserFetchable {
    var fetchable: UserFetchable {
        switch self {
        case let .tg(tg):
            return tg
        case let .vk(vk):
            return vk
        }
    }
}
