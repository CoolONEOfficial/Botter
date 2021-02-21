// Generated using Sourcery 1.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Attachment {

    enum CodingKeys: String, CodingKey {
        case photo
        case document
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.photo), try container.decodeNil(forKey: .photo) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .photo)
            let associatedValue0 = try associatedValues.decode(Photo.self)
            self = .photo(associatedValue0)
            return
        }
        if container.allKeys.contains(.document), try container.decodeNil(forKey: .document) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .document)
            let associatedValue0 = try associatedValues.decode(Document.self)
            self = .document(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .photo(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .photo)
            try associatedValues.encode(associatedValue0)
        case let .document(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .document)
            try associatedValues.encode(associatedValue0)
        }
    }

}

extension Button.Action {

    enum CodingKeys: String, CodingKey {
        case text
        case link
        case location
        case pay
        case app
        case callback
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.text), try container.decodeNil(forKey: .text) == false {
            self = .text
            return
        }
        if container.allKeys.contains(.link), try container.decodeNil(forKey: .link) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .link)
            let associatedValue0 = try associatedValues.decode(Link.self)
            self = .link(associatedValue0)
            return
        }
        if container.allKeys.contains(.location), try container.decodeNil(forKey: .location) == false {
            self = .location
            return
        }
        if container.allKeys.contains(.pay), try container.decodeNil(forKey: .pay) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .pay)
            let associatedValue0 = try associatedValues.decode(Pay.self)
            self = .pay(associatedValue0)
            return
        }
        if container.allKeys.contains(.app), try container.decodeNil(forKey: .app) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .app)
            let associatedValue0 = try associatedValues.decode(App.self)
            self = .app(associatedValue0)
            return
        }
        if container.allKeys.contains(.callback), try container.decodeNil(forKey: .callback) == false {
            self = .callback
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .text)
        case let .link(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .link)
            try associatedValues.encode(associatedValue0)
        case .location:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        case let .pay(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .pay)
            try associatedValues.encode(associatedValue0)
        case let .app(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .app)
            try associatedValues.encode(associatedValue0)
        case .callback:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .callback)
        }
    }

}

extension FileInfo.Content {

    enum CodingKeys: String, CodingKey {
        case fileId
        case url
        case file
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.fileId), try container.decodeNil(forKey: .fileId) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .fileId)
            let associatedValue0 = try associatedValues.decode(BotterAttachable.self)
            self = .fileId(associatedValue0)
            return
        }
        if container.allKeys.contains(.url), try container.decodeNil(forKey: .url) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .url)
            let associatedValue0 = try associatedValues.decode(String.self)
            self = .url(associatedValue0)
            return
        }
        if container.allKeys.contains(.file), try container.decodeNil(forKey: .file) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .file)
            let associatedValue0 = try associatedValues.decode(InputFile.self)
            self = .file(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .fileId(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .fileId)
            try associatedValues.encode(associatedValue0)
        case let .url(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .url)
            try associatedValues.encode(associatedValue0)
        case let .file(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .file)
            try associatedValues.encode(associatedValue0)
        }
    }

}

extension Update.Content {

    enum CodingKeys: String, CodingKey {
        case message
        case event
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.message), try container.decodeNil(forKey: .message) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .message)
            let associatedValue0 = try associatedValues.decode(Message.self)
            self = .message(associatedValue0)
            return
        }
        if container.allKeys.contains(.event), try container.decodeNil(forKey: .event) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .event)
            let associatedValue0 = try associatedValues.decode(MessageEvent.self)
            self = .event(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .message(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .message)
            try associatedValues.encode(associatedValue0)
        case let .event(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .event)
            try associatedValues.encode(associatedValue0)
        }
    }

}
