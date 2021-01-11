//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 08.01.2021.
//

import Foundation

protocol AutoDecodable: Decodable {}
protocol AutoEncodable: Encodable {}
protocol AutoCodable: AutoEncodable, AutoDecodable {}
