//
//  PrettyPrint.swift
//  Mist
//
//  Created by Nindi Gill on 12/3/21.
//

import Foundation

/// Helper Struct used to format printed messages.
struct PrettyPrint {

    enum Prefix: String {
        case `default` = "  ├─ "
        case ending    = "  └─ "
    }

    /// Prints a string with a border, in blue.
    ///
    /// - Parameters:
    ///   - header: The string to print.
    static func printHeader(_ header: String, structuredOutput:Bool) {
        let stderr = FileHandle.standardError
        var string:String = ""


        if (structuredOutput==false) {
            let horizontal: String = String(repeating: "─", count: header.count + 2)
            string = "┌\(horizontal)┐\n│ \(header) │\n└\(horizontal)┘"

        }
        else {
            let outputDict = [ "Header": header]

            do {
            let data = try JSONSerialization.data(withJSONObject: outputDict, options: [])
                string = String(data: data, encoding: .utf8) ?? "Unknown message"

            } catch {
                Swift.print(error.localizedDescription)
            }

        }
        if let outputString = string.data(using:.utf8) {
            stderr.write(outputString)
            stderr.write("\n".data(using: .utf8)!)
        }
    }

    /// Prints a string with an optional custom prefix.
    ///
    /// - Parameters:
    ///   - string:      The string to print.
    ///   - prefix:      The optional prefix.
    ///   - prefixColor: The optional prefix color.
    ///   - replacing:   Optionally set to `true` to replace the previous line.
    static func print(_ stringToPrint: String, prefix: Prefix = .default, prefixColor: String.Color = .green, replacing: Bool = false, structuredOutput: Bool, messagetype:String = "Info", messageObject:Dictionary<String, Any> = [:]) {
        let stderr = FileHandle.standardError
        var string:String = ""

        if (structuredOutput==false) {
            let replacing: String = replacing ? "\u{1B}[1A\u{1B}[K" : ""
            string = "\(replacing)\(prefix.rawValue.color(prefixColor))\(stringToPrint)"

        }
        else {
            var outputDict=Dictionary<String, Any>()
            if messageObject.keys.count>0 {
                outputDict[messagetype]=messageObject
            }
            else {
                outputDict = [ messagetype : stringToPrint]
            }

            do {
                let data = try JSONSerialization.data(withJSONObject: outputDict, options: [])
                string = String(data: data, encoding: .utf8) ?? "Unknown message"

            } catch {
                Swift.print(error.localizedDescription)
            }

        }
        if let outputString = string.data(using:.utf8) {
            stderr.write(outputString)
            stderr.write("\n".data(using: .utf8)!)
        }

    }
}
