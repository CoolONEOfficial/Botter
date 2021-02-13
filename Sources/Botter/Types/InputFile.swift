//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 11.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter

public struct InputFile: Codable {

    let data: Data
    let filename: String
    
    public init(data: Data, filename: String) {
        self.data = data
        self.filename = filename
    }

    var vk: Vkontakter.InputFile {
        .init(data: data, filename: filename)
    }
    
    var tg: Telegrammer.InputFile {
        .init(data: data, filename: filename)
    }
}
