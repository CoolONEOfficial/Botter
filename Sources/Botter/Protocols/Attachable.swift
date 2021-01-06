//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.01.2021.
//

import Foundation
import Vkontakter

public protocol Attachable {
    var attachmentId: String { get }
}

struct BotterAttachable: Attachable {
    let attachmentId: String
}

extension Vkontakter.Attachable {
    var botterAttachable: BotterAttachable {
        .init(attachmentId: attachmentId)
    }
}

extension Photo: Attachable {}

extension Document: Attachable {}

// TODO: other kinds
