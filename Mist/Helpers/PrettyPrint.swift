//
//  PrettyPrint.swift
//  Mist
//
//  Created by Nindi Gill on 12/3/21.
//

import Foundation

/// Helper Struct used to format printed messages.
struct PrettyPrint {

    /// Prints a string with a border, in blue.
    ///
    /// - Parameters:
    ///   - header: The string to print.
    static func printHeader(_ header: String) {
        let horizontal: String = String(repeating: "─", count: header.count + 2)
        let string: String = "┌\(horizontal)┐\n│ \(header) │\n└\(horizontal)┘"
        Swift.print(string.color(.blue))
    }

    /// Prints a string with an optional custom prefix.
    ///
    /// - Parameters:
    ///   - string: The string to print.
    ///   - prefix: The optional prefix, in green.
    static func print(_ string: String, prefix: String = "  ├─") {
        let string: String = "\(prefix.color(.green)) \(string)"
        Swift.print(string)
    }
}
