//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.01.2021.
//

import Foundation
import Vkontakter

public protocol Attachable: Codable {
    var attachmentId: String { get }
}

extension Attachable {
    var object: BotterAttachable {
        .init(attachmentId)
    }
}

public struct BotterAttachable: Attachable {
    public let attachmentId: String
    
    public init(_ attachmentId: String) {
        self.attachmentId = attachmentId
    }
}

extension Vkontakter.Attachable {
    var botterAttachable: BotterAttachable {
        .init(attachmentId)
    }
}

extension Photo: Attachable {}

extension Document: Attachable {}

// TODO: other kinds
