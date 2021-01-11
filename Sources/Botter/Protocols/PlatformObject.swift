//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 21.12.2020.
//

import Foundation

public protocol PlatformObject: Codable {
    associatedtype Tg: Codable
    associatedtype Vk: Codable
    
    var platform: Platform<Tg, Vk> { get }
}
