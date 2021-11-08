//
//  Catalog.swift
//  Mist
//
//  Created by Nindi Gill on 16/3/21.
//

import Foundation

enum Catalog: String, CaseIterable {
    // swiftlint:disable redundant_string_enum_value
    case standard = "standard"
    case customer = "customer"
    case developer = "developer"
    case `public` = "public"

    static var urls: [String] {
        self.allCases.map { $0.url }
    }

    var url: String {
        switch self {
        case .standard:
            return "https://swscan.apple.com/content/catalogs/others/index-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .customer:
            return "https://swscan.apple.com/content/catalogs/others/index-12customerseed-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .developer:
            return "https://swscan.apple.com/content/catalogs/others/index-12seed-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .`public`:
            return "https://swscan.apple.com/content/catalogs/others/index-12beta-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "Standard"
        case .customer:
            return "Customer Seed"
        case .developer:
            return "Developer Seed"
        case .`public`:
            return "Public Seed"
        }
    }
}
