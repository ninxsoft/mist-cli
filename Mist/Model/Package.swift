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
    }

    let url: String
    let size: Int
}
