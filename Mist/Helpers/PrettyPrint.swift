//
//  PrettyPrint.swift
//  Mist
//
//  Created by Nindi Gill on 12/3/21.
//

import Foundation

struct PrettyPrint {

    enum PrintType: String {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"

        var identifier: String {
            rawValue
        }

        var color: String.Color {
            switch self {
            case .info:
                return .green
            case .warning:
                return .yellow
            case.error:
                return .red
            }
        }

        var descriptionWithColor: String {
            identifier.color(self.color)
        }
    }

    static func print(_ type: PrintType, prefix: Bool = true, string: String, carriageReturn: Bool = false, newLine: Bool = true) {
        let carriageReturn: String = carriageReturn ? "\r" : ""
        let terminator: String = newLine ? "\n" : ""
        let string: String = "\(prefix ? "[\(type.descriptionWithColor)] \(Date()) - \(string)" : string)\(carriageReturn)"
        Swift.print(string, terminator: terminator)
    }
}
