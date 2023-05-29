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

    static var legacyProducts: [Product] {
        [
            Product(
                identifier: "10.12.6-16G29",
                name: "macOS Sierra",
                version: "10.12.6",
                build: "16G29",
                date: "2017-07-15",
                distribution: "",
                packages: [
                    Package(
                        url: "http://updates-http.cdn-apple.com/2019/cert/061-39476-20191023-48f365f4-0015-4c41-9f44-39d3d2aca067/InstallOS.dmg",
                        size: 5_007_882_126,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [],
                deviceIDs: [],
                unsupportedModelIdentifiers: []
            ),
            Product(
                identifier: "10.11.6-15G31",
                name: "OS X El Capitan",
                version: "10.11.6",
                build: "15G31",
                date: "2016-05-18",
                distribution: "",
                packages: [
                    Package(
                        url: "http://updates-http.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg",
                        size: 6_204_629_298,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [],
                deviceIDs: [],
                unsupportedModelIdentifiers: []
            ),
            Product(
                identifier: "10.10.5-14F27",
                name: "OS X Yosemite",
                version: "10.10.5",
                build: "14F27",
                date: "2015-08-05",
                distribution: "",
                packages: [
                    Package(
                        url: "http://updates-http.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg",
                        size: 5_718_074_248,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [],
                deviceIDs: [],
                unsupportedModelIdentifiers: []
            ),
            Product(
                identifier: "10.8.5-12F45",
                name: "OS X Mountain Lion",
                version: "10.8.5",
                build: "12F45",
                date: "2013-09-27",
                distribution: "",
                packages: [
                    Package(
                        url: "https://updates.cdn-apple.com/2021/macos/031-0627-20210614-90D11F33-1A65-42DD-BBEA-E1D9F43A6B3F/InstallMacOSX.dmg",
                        size: 4_449_317_520,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [],
                deviceIDs: [],
                unsupportedModelIdentifiers: []
            ),
            Product(
                identifier: "10.7.5-11G63",
                name: "Mac OS X Lion",
                version: "10.7.5",
                build: "11G63",
                date: "2012-09-28",
                distribution: "",
                packages: [
                    Package(
                        url: "https://updates.cdn-apple.com/2021/macos/041-7683-20210614-E610947E-C7CE-46EB-8860-D26D71F0D3EA/InstallMacOSX.dmg",
                        size: 4_720_237_409,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [],
                deviceIDs: [],
                unsupportedModelIdentifiers: []
            )
        ]
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
        (sierraOrOlder ? [] : [Package(url: distribution, size: 0, integrityDataURL: nil, integrityDataSize: nil)]) + packages.sorted { $0.filename < $1.filename }
    }
    var temporaryDiskImageMountPointURL: URL {
        URL(fileURLWithPath: "/Volumes/\(identifier)")
    }
    var temporaryInstallerURL: URL {
        temporaryDiskImageMountPointURL.appendingPathComponent("/Applications/Install \(name).app")
    }
    var temporaryISOMountPointURL: URL {
        URL(fileURLWithPath: "/Volumes/Install \(name)")
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
    var sierraOrOlder: Bool {
        version.range(of: "^10\\.([7-9]|1[0-2])\\.", options: .regularExpression) != nil
    }
    var catalinaOrNewer: Bool {
        bigSurOrNewer || version.range(of: "^10\\.15\\.", options: .regularExpression) != nil
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
    var diskImageSize: Double {
        ceil(Double(size) / Double(Int64.gigabyte)) + 1.5
    }
    var isoSize: Double {
        ceil(Double(size) / Double(Int64.gigabyte)) + 1.5
    }
}
