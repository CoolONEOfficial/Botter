//
//  Encodables.swift
//  App
//
//  Created by Givi Pataridze on 07.04.2018.
//

import Foundation
import struct NIO.ByteBufferAllocator

/// Represent Telegram type, which will be encoded as Json on sending to server
protocol JSONEncodable: Encodable {}

extension JSONEncodable {
    var dictionary: [String: String]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let test = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { dict in
            return dict as? [String: Any]
        }
        let mapped = test?.compactMapValues { val in
            val is Dictionary<AnyHashable, Any>
                ? String(data: try! JSONSerialization.data(withJSONObject: val, options: .fragmentsAllowed), encoding: .utf8)
                : String(describing: val)
        }
        return mapped
    }
}
