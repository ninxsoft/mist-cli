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

    static func print(_ type: PrintType, string: String) {
        let date: Date = Date()
        let string: String = "[\(type.descriptionWithColor)] \(date) - \(string)"
        Swift.print(string)
    }
}
