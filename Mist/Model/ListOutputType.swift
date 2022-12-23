//
//  ListOutputType.swift
//  Mist
//
//  Created by Nindi Gill on 1/9/21.
//

import ArgumentParser

enum ListOutputType: String, ExpressibleByArgument {
    // swiftlint:disable redundant_string_enum_value
    case ascii = "ascii"
    case csv = "csv"
    case json = "json"
    case plist = "plist"
    case yaml = "yaml"
}
