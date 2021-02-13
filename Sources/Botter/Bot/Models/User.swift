//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 13.02.2021.
//

import Foundation
import Vkontakter
import Telegrammer

public struct User: Codable {

    public let id: Int64
    
    public let firstName: String?
    
    public let lastName: String?
    
    // MARK: - Platform object
    
    public typealias Tg = Telegrammer.User
    public typealias Vk = Vkontakter.User
    
    public let platform: Platform<Tg, Vk>

}

extension User: PlatformObject {
    
    public init?(from vk: Vk?) {
        guard let vk = vk else { return nil }
        
        platform = .vk(vk)
        firstName = vk.firstName
        lastName = vk.lastName
        id = vk.id
    }
    
    public init?(from tg: Tg?) {
        guard let tg = tg else { return nil }

        platform = .tg(tg)
        firstName = tg.firstName
        lastName = tg.lastName
        id = tg.id
    }
    
}
