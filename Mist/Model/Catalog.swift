//
//  Catalog.swift
//  Mist
//
//  Created by Nindi Gill on 16/3/21.
//

import ArgumentParser
import Foundation

enum Catalog: String, ExpressibleByArgument {
    // swiftlint:disable redundant_string_enum_value
    case standard = "standard"
    case customer = "customer"
    case developer = "developer"
    case `public` = "public"

    var description: String {
        switch self {
        case .standard:
            return ""
        case .customer:
            return "customerseed-"
        case .developer:
            return "seed-"
        case .`public`:
            return "beta-"
        }
    }

    var urls: [String] {
        let prefix: String = "https://swscan.apple.com/content/catalogs/others/index-"
        let slugs: [String] = [
            "10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
            "10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
            "10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
            "10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
        ]

        return slugs.map { "\(prefix)\(self.description.isEmpty ? "" : $0.prefix(5))\(self.description)\($0)" }
    }
}
