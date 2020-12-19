//
//  Network.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 09.04.2018.
//

import NIO
import AsyncHTTPClient

/// Convenience shorthand for `EventLoopFuture`.
public typealias Future = EventLoopFuture

/// Convenience shorthand for `EventLoopPromise`.
public typealias Promise = EventLoopPromise

public protocol Connection {
    var worker: Worker { get }
}
