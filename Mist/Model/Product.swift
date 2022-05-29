//
//  Product.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation

struct Product: Decodable {
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
    var allDownloads: [Package] {
        [Package(url: distribution, size: 0, integrityDataURL: nil, integrityDataSize: nil)] + packages.sorted { $0.filename < $1.filename }
    }
    var installerURL: URL {
        URL(fileURLWithPath: "/Applications/Install \(name).app")
    }
    var zipName: String {
        "Install \(name) \(version) \(build).zip".replacingOccurrences(of: " ", with: "-")
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
    var exportDictionary: [String: Any] {
        [
            "identifier": identifier,
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "date": date,
            "distribution": distribution,
            "packages": packages.map { $0.dictionary },
            "beta": isBeta
        ]
    }
    var isTooBigForPackagePayload: Bool {
        version.range(of: "^1[1-9]\\.", options: .regularExpression) != nil
    }
    var isBeta: Bool {
        build.range(of: "[a-z]$", options: .regularExpression) != nil
    }
    var size: Int64 {
        Int64(packages.map { $0.size }.reduce(0, +))
    }
    var isoSize: Int64 {
        Int64(ceil(Double(size) / Double(Int64.gigabyte))) + 1
    }
}
