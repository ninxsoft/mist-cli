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

    static let defaultURL: String = "https://swscan.apple.com/content/catalogs/others/index-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"

    var identifier: String {
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

    func url(for catalogURL: String) -> String {
        let prefix: String = "https://swscan.apple.com/content/catalogs/others/index-"
        let slug: String = catalogURL.replacingOccurrences(of: prefix, with: "")
        let string: String = self == .standard ? "" : "\(slug.prefix(slug.firstIndex(of: "-")?.utf16Offset(in: slug) ?? 2))"
        return "\(prefix)\(string)\(self.identifier)\(slug)"
    }
}
