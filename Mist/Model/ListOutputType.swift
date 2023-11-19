//
//  ListOutputType.swift
//  Mist
//
//  Created by Nindi Gill on 1/9/21.
//

import ArgumentParser

enum ListOutputType: String, ExpressibleByArgument {
    // swiftlint:disable redundant_string_enum_value
    case ascii
    case csv
    case json
    case plist
    case yaml
    // swiftlint:enable redundant_string_enum_value
}
