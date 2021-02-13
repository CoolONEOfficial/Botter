//
//  Attachment.swift
//
//
//  Created by Nickolay Truhin on 04.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter

public enum Attachment: AutoCodable {
    case photo(Photo)
    case document(Document)
}

extension Telegrammer.Message {
    var botterAttachments: [Attachment] {
        var attachments = [Attachment]()
        
        if let doc = document, let botterDoc = Document(from: doc) {
            attachments.append(.document(botterDoc))
        }
        
        if let photo = photo {
            attachments.append(contentsOf: photo.compactMap { Photo(from: $0) }.map { .photo($0) })
        }
        
        return attachments
    }
}

extension Vkontakter.ArrayByComma where Element == Vkontakter.Attachment {
    var botterAttachments: [Attachment] {
        array.compactMap { attachment in
            switch attachment {
            case let .photo(photoValue):
                guard let photo = Photo(from: photoValue) else { return nil }
                return .photo(photo)
            case let .doc(docValue):
                guard let doc = Document(from: docValue) else { return nil }
                return .document(doc)
            }
        }
    }
}
