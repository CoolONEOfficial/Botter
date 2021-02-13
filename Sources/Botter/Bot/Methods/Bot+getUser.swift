//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 13.02.2021.
//

import Telegrammer
import Vkontakter
import Foundation
import NIO
import Vapor

public extension Bot {
    
    enum GetUserError: Error {
        case emptyArray
        case fromEntryNotFound
    }
    
    @discardableResult
    func getUser(from userFetchable: UserFetchable, app: Application) throws -> Future<User>? {
        switch userFetchable.userInfo {
        case let .id(userId):
            guard let userId = userId else { return nil }
            return try vk?.getUser(params: .init(userIds: .init(userId), fields: nil, nameCase: nil)).map { User(from: $0.first) }.unwrap(orError: Bot.GetUserError.emptyArray)
        
        case let .user(user):
            return app.eventLoopGroup.future(user).unwrap(or: GetUserError.fromEntryNotFound)
        }
    }

}

extension Message {
    var vkUserParams: Vkontakter.Bot.GetUserParams? {
        guard let userId = self.userId else { return nil }
        return .init(userIds: .init(userId), fields: nil, nameCase: nil)
    }
}
