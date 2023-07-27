//
//  TgSimpleCallbackQueryHandler.swift
//  Telegrammer
//
//  Created by Givi Pataridze on 23.04.2018.
//

import Foundation
import Telegrammer

/// Handler for CallbackQuery updates
struct TgSimpleCallbackQueryHandler: Telegrammer.Handler {

    var name: String

    let callback: Telegrammer.HandlerCallback

    public func check(update: Telegrammer.Update) -> Bool {
        update.callbackQuery?.data != nil
    }

    public func handle(update: Telegrammer.Update, dispatcher: Telegrammer.Dispatcher) async {
        do {
            try await callback(update, nil)
        } catch {
            log.error(error.logMessage)
        }
    }
}
