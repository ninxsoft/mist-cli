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
        allCases.map(\.tahoeURL) + allCases.map(\.goldenGateURL)
    }

    var url: String {
        tahoeURL
    }

    private var tahoeURL: String {
        switch self {
        case .standard:
            "https://swscan.apple.com/content/catalogs/others/index-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .customer: // swiftlint:disable:next line_length
            "https://swscan.apple.com/content/catalogs/others/index-26customerseed-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .developer:
            "https://swscan.apple.com/content/catalogs/others/index-26seed-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .public:
            "https://swscan.apple.com/content/catalogs/others/index-26beta-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        }
    }
    
    private var goldenGateURL: String {
        switch self {
        case .standard:
            "https://swscan.apple.com/content/catalogs/others/index-27-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .customer: // swiftlint:disable:next line_length
            "https://swscan.apple.com/content/catalogs/others/index-27customerseed-27-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .developer:
            "https://swscan.apple.com/content/catalogs/others/index-27seed-27-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        case .public:
            "https://swscan.apple.com/content/catalogs/others/index-27beta-27-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz"
        }
    }
}
