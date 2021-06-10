//
//  PrettyPrint.swift
//  Mist
//
//  Created by Nindi Gill on 12/3/21.
//

import Foundation

struct PrettyPrint {

    enum PrintType: String {
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "⛔️"

        var identifier: String {
            rawValue
        }
    }

    static func print(_ type: PrintType, string: String) {
        let string: String = "\(type.identifier)  \(string)"
        Swift.print(string)
    }
}
