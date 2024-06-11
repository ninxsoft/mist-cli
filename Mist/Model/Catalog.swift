//
//  Catalog.swift
//  Mist
//
//  Created by Nindi Gill on 16/3/21.
//

enum Catalog: String, CaseIterable {
    case standard
    case customer
    case developer
    case `public`

    static var urls: [String] {
        allCases.map(\.url) + allCases.map(\.sequioaURL)
    }

    var url: String {
        switch self {
        case .standard:
            "https://swscan.apple.com/content/catalogs/others/index-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .customer:
            "https://swscan.apple.com/content/catalogs/others/index-14customerseed-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .developer:
            "https://swscan.apple.com/content/catalogs/others/index-14seed-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .public:
            "https://swscan.apple.com/content/catalogs/others/index-14beta-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        }
    }

    private var sequioaURL: String {
        switch self {
        case .standard:
            "https://swscan.apple.com/content/catalogs/others/index-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .customer: // swiftlint:disable:next line_length
            "https://swscan.apple.com/content/catalogs/others/index-15customerseed-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .developer:
            "https://swscan.apple.com/content/catalogs/others/index-15seed-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .public:
            "https://swscan.apple.com/content/catalogs/others/index-15beta-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        }
    }
}
