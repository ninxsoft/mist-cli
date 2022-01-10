//
//  Product.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation

struct DownloadInfo: Decodable {

    enum CodingKeys: String, CodingKey {
        case identifier = "Identifier"
        case name = "Name"
        case version = "Version"
        case build = "Build"
        case date = "PostDate"
        case distribution = "DistributionURL"
        case packages = "Packages"
    }

    let identifier: String
    let name: String
    let version: String
    let build: String
    let date: String
    let distribution: String
    let packages: [Package]

    var totalFiles: Int {
        packages.count + 1
    }
    var dictionary: [String: Any] {
        [
            "identifier": identifier,
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "date": date
        ]
    }
    var size: Int64 {
        Int64(packages.map { $0.size }.reduce(0, +))
    }
    init(from firmware: Firmware) throws {
        self.identifier=firmware.identifier
        self.name=firmware.name
        self.version=firmware.version
        self.build=firmware.build
        self.date=firmware.date
        self.distribution=""
        self.packages=[]
    }
    init(from product: Product) throws {
        self.identifier=product.identifier
        self.name=product.name
        self.version=product.version
        self.build=product.build
        self.date=product.date
        self.distribution=product.distribution
        self.packages=product.packages
    }
}
