//
//  Package.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Package: Decodable {
    enum CodingKeys: String, CodingKey {
        case url = "URL"
        case size = "Size"
        case integrityDataURL = "IntegrityDataURL"
        case integrityDataSize = "IntegrityDataSize"
    }

    let url: String
    let size: Int
    let integrityDataURL: String?
    let integrityDataSize: Int?
    var filename: String {
        url.components(separatedBy: "/").last ?? url
    }

    var dictionary: [String: Any] {
        [
            "url": url,
            "size": size,
            "integrityDataURL": integrityDataURL ?? "",
            "integrityDataSize": integrityDataSize ?? 0
        ]
    }
}
