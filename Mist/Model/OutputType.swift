//
//  OutputType.swift
//  Mist
//
//  Created by Nindi Gill on 1/9/21.
//

import ArgumentParser
import Foundation

enum OutputType: String, ExpressibleByArgument {
    // swiftlint:disable redundant_string_enum_value
    case ascii = "ascii"
    case csv = "csv"
    case json = "json"
    case plist = "plist"
    case yaml = "yaml"
}
