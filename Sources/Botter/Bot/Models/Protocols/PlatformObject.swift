//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 21.12.2020.
//

import Foundation

protocol PlatformObject {
    associatedtype Tg
    associatedtype Vk
    
    var platform: Platform<Tg, Vk> { get }
}
