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
    func enqueue(_ bytebuffer: ByteBuffer)
    func add(_ handler: Handler, to group: HandlerGroup)
    func remove(_ handler: Handler, from group: HandlerGroup)
}

extension Vkontakter.Dispatcher: BaseDispatcher {
    func enqueue(_ bytebuffer: ByteBuffer) {
        enqueue(bytebuffer: bytebuffer)
    }
    
    func add(_ handler: Handler, to group: HandlerGroup) {
        add(handler: handler.vk, to: group.vk)
    }
    
    func remove(_ handler: Handler, from group: HandlerGroup) {
        remove(handler: handler.vk, from: group.vk)
    }
}

extension Telegrammer.Dispatcher: BaseDispatcher {
    
    func enqueue(_ bytebuffer: ByteBuffer) {
        enqueue(bytebuffer: bytebuffer)
    }
    
    func add(_ handler: Handler, to group: HandlerGroup) {
        add(handler: handler.tg, to: group.tg)
    }
    
    func remove(_ handler: Handler, from group: HandlerGroup) {
        remove(handler: handler.tg, from: group.tg)
    }
}
