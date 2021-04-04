//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 04.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter

public struct Photo {

    public let platform: Platform<Tg, Vk>

    /// Идентификатор фотографии.
    public let attachmentId: String
    
    public let sizes: [Size]

}

extension Photo: PlatformObject {
    
    public typealias Tg = [Telegrammer.PhotoSize]
    public typealias Vk = Vkontakter.Photo
    
    init?(from tg: Tg) {
        platform = .tg(tg)

        attachmentId = tg.largerElement!.fileId
        sizes = tg.map { Size(from: $0) }.compactMap { $0 }
    }

    init?(from vk: Vk) {
        platform = .vk(vk)
        
        attachmentId = vk.attachmentId
        sizes = vk.sizes?.compactMap { Size(from: $0) } ?? []
    }
    
}

extension Array where Element == Telegrammer.PhotoSize {
    var largerElement: Element? {
        sorted { $0.fileSize ?? 0 > $1.fileSize ?? 0 }.first
    }
}

public extension Photo {
    struct Size: PlatformObject {
        public typealias Tg = Telegrammer.PhotoSize
        public typealias Vk = Vkontakter.PhotoSize
        
        public let platform: Platform<Tg, Vk>
        
        ///
        public let url: String?
        
        ///
        public let width: Int?
        
        ///
        public let height: Int?
        
        init?(from tg: Tg) {
            platform = .tg(tg)

            url = nil
            width = tg.width
            height = tg.height
        }

        init?(from vk: Vk) {
            platform = .vk(vk)
            
            url = vk.url
            width = vk.width
            height = vk.height
        }
    }
}
