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
        case boardIDs = "BoardIDs"
        case deviceIDs = "DeviceIDs"
        case unsupportedModelIdentifiers = "UnsupportedModelIdentifiers"
    }

    let identifier: String
    let name: String
    let version: String
    let build: String
    let date: String
    let distribution: String
    let packages: [Package]
    let boardIDs: [String]
    let deviceIDs: [String]
    let unsupportedModelIdentifiers: [String]
    var compatible: Bool {
        // Board ID (Intel)
        if let boardID: String = Hardware.boardID,
            !boardIDs.isEmpty,
            !boardIDs.contains(boardID) {
            return false
        }

        // Device ID (Apple Silicon or Intel T2)
        // macOS Big Sur 11 or newer
        if version.range(of: "^1[1-9]\\.", options: .regularExpression) != nil,
            let deviceID: String = Hardware.deviceID,
            !deviceIDs.isEmpty,
            !deviceIDs.contains(deviceID) {
            return false
        }

        // Model Identifier (Apple Silicon or Intel)
        // macOS Catalina 10.15 or older
        if version.range(of: "^10\\.", options: .regularExpression) != nil {

            if let architecture: String = Hardware.architecture,
                architecture.contains("arm64") {
                return false
            }

            if let modelIdentifier: String = Hardware.modelIdentifier,
                !unsupportedModelIdentifiers.isEmpty,
                unsupportedModelIdentifiers.contains(modelIdentifier) {
                return false
            }
        }

        return true
    }
    var allDownloads: [Package] {
        [Package(url: distribution, size: 0, integrityDataURL: nil, integrityDataSize: nil)] + packages.sorted { $0.filename < $1.filename }
    }
    var installerURL: URL {
        URL(fileURLWithPath: "/Applications/Install \(name).app")
    }
    var dictionary: [String: Any] {
        [
            "identifier": identifier,
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "date": date,
            "compatible": compatible
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
            "compatible": compatible,
            "distribution": distribution,
            "packages": packages.map { $0.dictionary },
            "beta": beta
        ]
    }
    var bigSurOrNewer: Bool {
        version.range(of: "^1[1-9]\\.", options: .regularExpression) != nil
    }
    var beta: Bool {
        build.range(of: "[a-z]$", options: .regularExpression) != nil
    }
    var size: Int64 {
        Int64(packages.map { $0.size }.reduce(0, +))
    }
    var isoSize: Double {
        ceil(Double(size) / Double(Int64.gigabyte)) + 1.5
    }
}
