//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.01.2021.
//

import Foundation
import Vkontakter

public protocol Attachable: Codable {
    func attachmentId(for platform: AnyPlatform) -> String?
}

extension Attachable {
    func object(for platform: AnyPlatform) -> BotterAttachable? {
        guard let attachmentId = attachmentId(for: platform) else { return nil }
        return .init(platform.convert(to: attachmentId))
    }
}

public struct BotterAttachable: Attachable {
    public typealias PlatformId = Platform<String, String>
    
    public let platformAttachmentIds: [PlatformId]
    
    public init(_ platformAttachmentIds: PlatformId...) {
        self.init(platformAttachmentIds)
    }
    
    public init(_ platformAttachmentIds: [PlatformId]) {
        self.platformAttachmentIds = platformAttachmentIds
    }

    public func attachmentId(for platform: AnyPlatform) -> String? {
        guard let platformAttachmentId = self.platformAttachmentIds.first(where: { $0.same(platform) }) else { return nil }
        return platformAttachmentId.value
    }
}

extension Vkontakter.Attachable {
    var botterAttachable: BotterAttachable {
        .init(.vk(attachmentId))
    }
}

extension Photo: Attachable {
    public func attachmentId(for platform: AnyPlatform) -> String? {
        attachmentId
    }
}

extension Document: Attachable {
    public func attachmentId(for platform: AnyPlatform) -> String? {
        attachmentId
    }
}

// TODO: other kinds
