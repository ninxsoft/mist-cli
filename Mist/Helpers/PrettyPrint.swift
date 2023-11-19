//
//  PrettyPrint.swift
//  Mist
//
//  Created by Nindi Gill on 12/3/21.
//

/// Helper Struct used to format printed messages.
struct PrettyPrint {
    enum Prefix: String {
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
    ///   - noAnsi: Set to `true` to print the string without any color or formatting.
    static func printHeader(_ header: String, noAnsi: Bool) {
        let horizontal: String = String(repeating: "─", count: header.count + 2)
        let string: String = "┌\(horizontal)┐\n│ \(header) │\n└\(horizontal)┘"
        Swift.print(noAnsi ? string : string.color(.blue))
    }

    /// Prints a string with an optional custom prefix.
    ///
    /// - Parameters:
    ///   - string:      The string to print.
    ///   - noAnsi:      Set to `true` to print the string without any color or formatting.
    ///   - prefix:      The optional prefix.
    ///   - prefixColor: The optional prefix color.
    ///   - replacing:   Optionally set to `true` to replace the previous line.
    static func print(_ string: String, noAnsi: Bool, prefix: Prefix = .default, prefixColor: String.Color = .green, replacing: Bool = false) {
        let replacingString: String = replacing && !noAnsi ? "\u{1B}[1A\u{1B}[K" : ""
        let prefixString: String = "\(noAnsi ? prefix.description : prefix.description.color(prefixColor))"
        Swift.print("\(replacingString)\(prefixString)\(string)")
    }
}
