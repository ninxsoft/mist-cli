//
//  PrettyPrint.swift
//  Mist
//
//  Created by Nindi Gill on 12/3/21.
//

import Foundation

/// Helper Struct used to format printed messages.
struct PrettyPrint {

    enum Prefix: String, CustomStringConvertible {
        case `default` = "  ├─ "
        case continuing = "  │  "
        case ending    = "  └─ "

        var description: String {
            rawValue
        }
    }

    /// Prints a string with a border, in blue.
    ///
    /// - Parameters:
    ///   - header: The string to print.
    ///   - color:  Set to `false` to print without any color or formatting.
    static func printHeader(_ header: String, color: Bool) {
        let horizontal: String = String(repeating: "─", count: header.count + 2)
        let string: String = "┌\(horizontal)┐\n│ \(header) │\n└\(horizontal)┘"
        Swift.print(color ? string.color(.blue) : string)
    }

    /// Prints a string with an optional custom prefix.
    ///
    /// - Parameters:
    ///   - string:      The string to print.
    ///   - color:       Set to `false` to print without any color or formatting.
    ///   - prefix:      The optional prefix.
    ///   - prefixColor: The optional prefix color.
    ///   - replacing:   Optionally set to `true` to replace the previous line.
    static func print(_ string: String, color: Bool, prefix: Prefix = .default, prefixColor: String.Color = .green, replacing: Bool = false) {
        let replacingString: String = replacing ? "\u{1B}[1A\u{1B}[K" : ""
        let string: String = "\(replacingString)\(color ? prefix.description.color(prefixColor) : prefix.description)\(string)"
        Swift.print(string)
    }
}
