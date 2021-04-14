import Foundation
import Botter
import Vkontakter
import Telegrammer
import Vapor

///Getting token from enviroment variable (most safe, recommended)
guard let vkToken = Enviroment.get("VK_BOT_TOKEN") else {
    print("VK_BOT_TOKEN variable wasn't found in enviroment variables")
    exit(1)
}

guard let tgToken = Enviroment.get("TG_BOT_TOKEN") else {
    print("TG_BOT_TOKEN variable wasn't found in enviroment variables")
    exit(1)
}

var vkSettings = Vkontakter.Bot.Settings(token: vkToken)
let vkPort = Int(Enviroment.get("VK_PORT") ?? "1213")!

vkSettings.webhooksConfig = .init(
    ip: "0.0.0.0",
    url: Enviroment.get("VK_BOT_WEBHOOK_URL")!, // or use openUrl(80)
    port: vkPort,
    groupId: UInt64(Enviroment.get("VK_GROUP_ID")!)!
)

var tgSettings = Telegrammer.Bot.Settings(token: tgToken)
let tgPort = Int(Enviroment.get("TG_PORT") ?? "1212")!
 
tgSettings.webhooksConfig = .init(
    ip: "0.0.0.0",
    url: Enviroment.get("TG_WEBHOOK_URL")!, // or use openUrl(tgPort)
    port: tgPort
    //publicCert: .text(content: Enviroment.get("TG_PUBLIC_KEY")!)
)

/// Initializind Bot settings (token, debugmode)
var settings = Bot.Settings(vk: vkSettings, tg: tgSettings)

let bot = try! Bot(settings: settings)

/// Dictionary for user echo modes
var userEchoModes: [Int64: Bool] = [:]

///Callback for Command handler
func startHandle(_ update: Botter.Update, _ context: Botter.BotContextProtocol) throws {
    guard case let .message(message) = update.content else { return }

    _ = try message.reply(.init(text: "Hello!"), context: context)
}

///Callback for Message with text handler
func echoResponse(_ update: Botter.Update, _ context: Botter.BotContextProtocol) throws {
    guard case let .message(message) = update.content,
          let text = message.text,
          let userId = message.fromId else { return }
    
    if text.contains("/echo") {
        var onText = ""
        if let on = userEchoModes[userId] {
            onText = on ? "OFF" : "ON"
            userEchoModes[userId] = !on
        } else {
            onText = "ON"
            userEchoModes[userId] = true
        }

        _ = try message.reply(.init(text: "Echo mode turned \(onText)"), context: context)
    } else if let on = userEchoModes[userId], on == true {
        _ = try message.reply(.init(text: text), context: context)
    }
}

do {
    ///Dispatcher - handle all incoming messages
    let dispatcher = Dispatcher(bot: bot, app: Application())

    ///Creating and adding handler for command /echo
    let commandHandler = CommandHandler(commands: ["start"], callback: startHandle)
    dispatcher.add(handler: commandHandler)

    ///Creating and adding handler for ordinary text messages
    let echoHandler = MessageHandler(filters: Filters.text, callback: echoResponse)
    dispatcher.add(handler: echoHandler)
    
    ///Handle updates
    _ = try Updater(bot: bot, dispatcher: dispatcher).startWebhooks(vkServerName: "title").wait()

} catch {
    print(error.localizedDescription)
}

while true { }
