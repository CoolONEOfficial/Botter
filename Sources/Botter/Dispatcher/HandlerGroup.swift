//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer

public struct HandlerGroup: Hashable {
    public init(vk: Vkontakter.HandlerGroup, tg: Telegrammer.HandlerGroup) {
        self.vk = vk
        self.tg = tg
    }
    
    let vk: Vkontakter.HandlerGroup
    let tg: Telegrammer.HandlerGroup
}
