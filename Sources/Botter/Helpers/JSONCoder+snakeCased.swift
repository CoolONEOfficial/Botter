//
//  File.swift
//
//
//  Created by Nickolay Truhin on 02.12.2020.
//

import Foundation

public extension JSONDecoder {
    static var snakeCased: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

public extension JSONEncoder {
    static var snakeCased: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}
