//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 13.12.2020.
//

import Foundation

public enum Platform<Tg: Codable, Vk: Codable>: AutoCodable {
    case tg(Tg)
    case vk(Vk)
}
