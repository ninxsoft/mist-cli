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
        case version = "Version"
        case build = "Build"
        case date = "PostDate"
        case distribution = "DistributionURL"
        case packages = "Packages"
    }

    let identifier: String
    let version: String
    let build: String
    let date: String
    let distribution: String
    let packages: [Package]
    var name: String {

        var name: String = ""

        if version.hasPrefix("11") {
            name = "macOS Big Sur"
        } else if version.hasPrefix("10.15") {
            name = "macOS Catalina"
        } else if version.hasPrefix("10.14") {
            name = "macOS Mojave"
        } else if version.hasPrefix("10.13") {
            name = "macOS High Sierra"
        } else {
            name = "macOS"
        }

        let beta: Bool = build.range(of: "[a-z]$", options: .regularExpression) != nil
        name += beta ? " Beta" : ""
        return name
    }
    var installerURL: URL {
        URL(fileURLWithPath: "/Applications/Install \(name).app")
    }
    var applicationName: String {
        "\(baseName).app"
    }
    var imageName: String {
        "\(baseName).dmg"
    }
    var packageName: String {
        "\(baseName).pkg"
    }
    var zipName: String {
        "\(baseName).zip"
    }
    private var baseName: String {
        "Install \(name) \(version) \(build)".replacingOccurrences(of: " ", with: "-")
    }
    var totalFiles: Int {
        packages.count + 1
    }
    var dictionary: [String: Any] {
        [
            "identifier": identifier,
            "name": name,
            "version": version,
            "build": build,
            "date": date
        ]
    }
    var csvLine: String {
        "\(identifier),\(name),\(version),\(build),\(date)\n"
    }
    var isTooBigForPackagePayload: Bool {
        version.range(of: "^1[1-9]\\.", options: .regularExpression) != nil
    }
    var size: Int64 {
        Int64(packages.map { $0.size }.reduce(0, +))
    }
}
