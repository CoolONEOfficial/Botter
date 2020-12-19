//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 19.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer
import Vapor

protocol BaseDispatcher {
    func enqueue(bytebuffer: ByteBuffer)
    func add(handler: Handler, to group: HandlerGroup)
    func remove(handler: Handler, from group: HandlerGroup)
}

extension Vkontakter.Dispatcher: BaseDispatcher {
    func add(handler: Handler, to group: HandlerGroup) {
        add(handler: handler.vk, to: group.vk)
    }
    
    func remove(handler: Handler, from group: HandlerGroup) {
        remove(handler: handler.vk, from: group.vk)
    }
}

extension Telegrammer.Dispatcher: BaseDispatcher {
    func add(handler: Handler, to group: HandlerGroup) {
        add(handler: handler.tg, to: group.tg)
    }
    
    func remove(handler: Handler, from group: HandlerGroup) {
        remove(handler: handler.tg, from: group.tg)
    }
}
