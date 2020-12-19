//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 19.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer

// MARK: - Webhooks config inits

extension Vkontakter.Webhooks.Config {
    public init(ip: String, baseUrl: String, groupId: UInt64? = nil) {
        self.init(ip: ip, url: baseUrl + "/vk", groupId: groupId)
    }
}

extension Telegrammer.Webhooks.Config {
    public init(ip: String, baseUrl: String, port: Int, publicCert: Telegrammer.Webhooks.Config.Certificate? = nil) {
        self.init(ip: ip, url: baseUrl + "/tg", port: port, publicCert: publicCert)
    }
}
