//
//  Kind.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

enum Kind: String, ExpressibleByArgument {
    // swiftlint:disable redundant_string_enum_value
    case firmware = "firmware"
    case installer = "installer"
    case app = "app"
    case ipsw = "ipsw"

    var description: String {
        self.rawValue
    }
}
