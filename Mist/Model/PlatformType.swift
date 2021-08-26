//
//  PlatformType.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

enum PlatformType: String, ExpressibleByArgument {
    // swiftlint:disable redundant_string_enum_value
    case apple = "apple"
    case intel = "intel"
}
