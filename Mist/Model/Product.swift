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

        if version.hasPrefix("11") {
            return "macOS Big Sur"
        } else if version.hasPrefix("10.15") {
            return "macOS Catalina"
        } else if version.hasPrefix("10.14") {
            return "macOS Mojave"
        } else if version.hasPrefix("10.13") {
            return "macOS High Sierra"
        } else {
            return "macOS"
        }
    }
    var installerURL: URL {
        URL(fileURLWithPath: "/Applications/Install \(name).app")
    }
    var imageName: String {
        "Install \(name) \(version) \(build).dmg".replacingOccurrences(of: " ", with: "-")
    }
    var zipName: String {
        "Install \(name) \(version) \(build).zip".replacingOccurrences(of: " ", with: "-")
    }
    var packageName: String {
        "Install \(name) \(version) \(build).pkg".replacingOccurrences(of: " ", with: "-")
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
}
