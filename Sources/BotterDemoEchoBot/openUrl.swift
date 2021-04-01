//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 31.03.2021.
//

import Foundation

func openUrl(_ port: Int = 80) -> String {

    let command = "ssh -R 80:localhost:\(port) localhost.run"
    
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()
    sleep(5)
    task.interrupt()
    
    let bgTask = Process()
    bgTask.arguments = ["-c", command]
    bgTask.launchPath = "/bin/zsh"
    bgTask.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    let res = matches(for: "\\S+(localhost.run)", in: output).last!

    return res
}
