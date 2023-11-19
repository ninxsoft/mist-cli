//
//  Product.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
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
                        url: "https://updates.cdn-apple.com/2019/cert/061-39476-20191023-48f365f4-0015-4c41-9f44-39d3d2aca067/InstallOS.dmg",
                        size: 5_007_882_126,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [
                    "Mac-00BE6ED71E35EB86",
                    "Mac-031AEE4D24BFF0B1",
                    "Mac-031B6874CF7F642A",
                    "Mac-06F11F11946D27C5",
                    "Mac-06F11FD93F0323C5",
                    "Mac-189A3D4F975D5FFC",
                    "Mac-27ADBB7B4CEE8E61",
                    "Mac-2BD1B31983FE1663",
                    "Mac-2E6FAB96566FE58C",
                    "Mac-35C1E88140C3E6CF",
                    "Mac-35C5E08120C7EEAF",
                    "Mac-3CBD00234E554E41",
                    "Mac-42FD25EABCABB274",
                    "Mac-473D31EABEB93F9B",
                    "Mac-4B682C642B45593E",
                    "Mac-4B7AC7E43945597E",
                    "Mac-4BC72D62AD45599E",
                    "Mac-50619A408DB004DA",
                    "Mac-551B86E5744E2388",
                    "Mac-65CE76090165799A",
                    "Mac-66E35819EE2D0D05",
                    "Mac-66F35F19FE2A0D05",
                    "Mac-6F01561E16C75D06",
                    "Mac-742912EFDBEE19B3",
                    "Mac-77EB7D7DAF985301",
                    "Mac-77F17D7DA9285301",
                    "Mac-7BA5B2794B2CDB12",
                    "Mac-7DF21CB3ED6977E5",
                    "Mac-7DF2A3B5E5D671ED",
                    "Mac-81E3E92DD6088272",
                    "Mac-8ED6AF5B48C039E1",
                    "Mac-937CB26E2E02BB01",
                    "Mac-942452F5819B1C1B",
                    "Mac-942459F5819B171B",
                    "Mac-94245A3940C91C80",
                    "Mac-94245B3640C91C81",
                    "Mac-942B59F58194171B",
                    "Mac-942B5BF58194151B",
                    "Mac-942C5DF58193131B",
                    "Mac-9AE82516C7C6B903",
                    "Mac-9F18E312C5C2BF0B",
                    "Mac-A369DDC4E67F1C45",
                    "Mac-A5C67F76ED83108C",
                    "Mac-AFD8A9D944EA4843",
                    "Mac-B4831CEBD52A0C4C",
                    "Mac-B809C3757DA9BB8D",
                    "Mac-BE088AF8C5EB4FA2",
                    "Mac-BE0E8AC46FE800CC",
                    "Mac-C08A6BB70A942AC2",
                    "Mac-C3EC7CD22292981F",
                    "Mac-CAD6701F7CEA0921",
                    "Mac-DB15BD556843C820",
                    "Mac-E43C1C25D4880AD6",
                    "Mac-EE2EBD4B90B839A8",
                    "Mac-F305150B0C7DEEEF",
                    "Mac-F60DEB81FF30ACF6",
                    "Mac-F65AE981FFA204ED",
                    "Mac-FA842E06C61E91C5",
                    "Mac-FC02E91DDD3FA6A4",
                    "Mac-FFE5EF870D7BA81A",
                    "Mac-F2208EC8",
                    "Mac-F221BEC8",
                    "Mac-F221DCC8",
                    "Mac-F222BEC8",
                    "Mac-F2238AC8",
                    "Mac-F2238BAE",
                    "Mac-F22586C8",
                    "Mac-F22589C8",
                    "Mac-F2268CC8",
                    "Mac-F2268DAE",
                    "Mac-F2268DC8",
                    "Mac-F22C89C8",
                    "Mac-F22C8AC8"
                ],
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
                        url: "https://updates.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg",
                        size: 6_204_629_298,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [
                    "Mac-00BE6ED71E35EB86",
                    "Mac-031AEE4D24BFF0B1",
                    "Mac-031B6874CF7F642A",
                    "Mac-06F11F11946D27C5",
                    "Mac-06F11FD93F0323C5",
                    "Mac-189A3D4F975D5FFC",
                    "Mac-27ADBB7B4CEE8E61",
                    "Mac-2BD1B31983FE1663",
                    "Mac-2E6FAB96566FE58C",
                    "Mac-35C1E88140C3E6CF",
                    "Mac-35C5E08120C7EEAF",
                    "Mac-3CBD00234E554E41",
                    "Mac-42FD25EABCABB274",
                    "Mac-4B7AC7E43945597E",
                    "Mac-4BC72D62AD45599E",
                    "Mac-50619A408DB004DA",
                    "Mac-65CE76090165799A",
                    "Mac-66F35F19FE2A0D05",
                    "Mac-6F01561E16C75D06",
                    "Mac-742912EFDBEE19B3",
                    "Mac-77EB7D7DAF985301",
                    "Mac-7BA5B2794B2CDB12",
                    "Mac-7DF21CB3ED6977E5",
                    "Mac-7DF2A3B5E5D671ED",
                    "Mac-81E3E92DD6088272",
                    "Mac-8ED6AF5B48C039E1",
                    "Mac-937CB26E2E02BB01",
                    "Mac-942452F5819B1C1B",
                    "Mac-942459F5819B171B",
                    "Mac-94245A3940C91C80",
                    "Mac-94245B3640C91C81",
                    "Mac-942B59F58194171B",
                    "Mac-942B5BF58194151B",
                    "Mac-942C5DF58193131B",
                    "Mac-9AE82516C7C6B903",
                    "Mac-9F18E312C5C2BF0B",
                    "Mac-A369DDC4E67F1C45",
                    "Mac-AFD8A9D944EA4843",
                    "Mac-B809C3757DA9BB8D",
                    "Mac-BE0E8AC46FE800CC",
                    "Mac-C08A6BB70A942AC2",
                    "Mac-C3EC7CD22292981F",
                    "Mac-DB15BD556843C820",
                    "Mac-E43C1C25D4880AD6",
                    "Mac-F305150B0C7DEEEF",
                    "Mac-F60DEB81FF30ACF6",
                    "Mac-F65AE981FFA204ED",
                    "Mac-FA842E06C61E91C5",
                    "Mac-FC02E91DDD3FA6A4",
                    "Mac-FFE5EF870D7BA81A",
                    "Mac-F2208EC8",
                    "Mac-F2218EA9",
                    "Mac-F2218EC8",
                    "Mac-F2218FA9",
                    "Mac-F2218FC8",
                    "Mac-F221BEC8",
                    "Mac-F221DCC8",
                    "Mac-F222BEC8",
                    "Mac-F2238AC8",
                    "Mac-F2238BAE",
                    "Mac-F223BEC8",
                    "Mac-F22586C8",
                    "Mac-F22587A1",
                    "Mac-F22587C8",
                    "Mac-F22589C8",
                    "Mac-F2268AC8",
                    "Mac-F2268CC8",
                    "Mac-F2268DAE",
                    "Mac-F2268DC8",
                    "Mac-F2268EC8",
                    "Mac-F226BEC8",
                    "Mac-F22788AA",
                    "Mac-F227BEC8",
                    "Mac-F22C86C8",
                    "Mac-F22C89C8",
                    "Mac-F22C8AC8",
                    "Mac-F42386C8",
                    "Mac-F42388C8",
                    "Mac-F4238BC8",
                    "Mac-F4238CC8",
                    "Mac-F42C86C8",
                    "Mac-F42C88C8",
                    "Mac-F42C89C8",
                    "Mac-F42D86A9",
                    "Mac-F42D86C8",
                    "Mac-F42D88C8",
                    "Mac-F42D89A9",
                    "Mac-F42D89C8"
                ],
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
                        url: "https://updates.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg",
                        size: 5_718_074_248,
                        integrityDataURL: nil,
                        integrityDataSize: nil
                    )
                ],
                boardIDs: [
                    "Mac-00BE6ED71E35EB86",
                    "Mac-031AEE4D24BFF0B1",
                    "Mac-031B6874CF7F642A",
                    "Mac-06F11F11946D27C5",
                    "Mac-06F11FD93F0323C5",
                    "Mac-189A3D4F975D5FFC",
                    "Mac-27ADBB7B4CEE8E61",
                    "Mac-2BD1B31983FE1663",
                    "Mac-2E6FAB96566FE58C",
                    "Mac-35C1E88140C3E6CF",
                    "Mac-35C5E08120C7EEAF",
                    "Mac-3CBD00234E554E41",
                    "Mac-42FD25EABCABB274",
                    "Mac-4B7AC7E43945597E",
                    "Mac-4BC72D62AD45599E",
                    "Mac-50619A408DB004DA",
                    "Mac-66F35F19FE2A0D05",
                    "Mac-6F01561E16C75D06",
                    "Mac-742912EFDBEE19B3",
                    "Mac-77EB7D7DAF985301",
                    "Mac-7BA5B2794B2CDB12",
                    "Mac-7DF21CB3ED6977E5",
                    "Mac-7DF2A3B5E5D671ED",
                    "Mac-81E3E92DD6088272",
                    "Mac-8ED6AF5B48C039E1",
                    "Mac-937CB26E2E02BB01",
                    "Mac-942452F5819B1C1B",
                    "Mac-942459F5819B171B",
                    "Mac-94245A3940C91C80",
                    "Mac-94245B3640C91C81",
                    "Mac-942B59F58194171B",
                    "Mac-942B5BF58194151B",
                    "Mac-942C5DF58193131B",
                    "Mac-9F18E312C5C2BF0B",
                    "Mac-AFD8A9D944EA4843",
                    "Mac-BE0E8AC46FE800CC",
                    "Mac-C08A6BB70A942AC2",
                    "Mac-C3EC7CD22292981F",
                    "Mac-E43C1C25D4880AD6",
                    "Mac-F305150B0C7DEEEF",
                    "Mac-F60DEB81FF30ACF6",
                    "Mac-F65AE981FFA204ED",
                    "Mac-FA842E06C61E91C5",
                    "Mac-FC02E91DDD3FA6A4",
                    "Mac-F2208EC8",
                    "Mac-F2218EA9",
                    "Mac-F2218EC8",
                    "Mac-F2218FA9",
                    "Mac-F2218FC8",
                    "Mac-F221BEC8",
                    "Mac-F221DCC8",
                    "Mac-F222BEC8",
                    "Mac-F2238AC8",
                    "Mac-F2238BAE",
                    "Mac-F223BEC8",
                    "Mac-F22586C8",
                    "Mac-F22587A1",
                    "Mac-F22587C8",
                    "Mac-F22589C8",
                    "Mac-F2268AC8",
                    "Mac-F2268CC8",
                    "Mac-F2268DAE",
                    "Mac-F2268DC8",
                    "Mac-F2268EC8",
                    "Mac-F226BEC8",
                    "Mac-F22788AA",
                    "Mac-F227BEC8",
                    "Mac-F22C86C8",
                    "Mac-F22C89C8",
                    "Mac-F22C8AC8",
                    "Mac-F42386C8",
                    "Mac-F42388C8",
                    "Mac-F4238BC8",
                    "Mac-F4238CC8",
                    "Mac-F42C86C8",
                    "Mac-F42C88C8",
                    "Mac-F42C89C8",
                    "Mac-F42D86A9",
                    "Mac-F42D86C8",
                    "Mac-F42D88C8",
                    "Mac-F42D89A9",
                    "Mac-F42D89C8"
                ],
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
                boardIDs: [
                    "Mac-00BE6ED71E35EB86",
                    "Mac-031AEE4D24BFF0B1",
                    "Mac-031B6874CF7F642A",
                    "Mac-27ADBB7B4CEE8E61",
                    "Mac-2E6FAB96566FE58C",
                    "Mac-35C1E88140C3E6CF",
                    "Mac-4B7AC7E43945597E",
                    "Mac-4BC72D62AD45599E",
                    "Mac-50619A408DB004DA",
                    "Mac-66F35F19FE2A0D05",
                    "Mac-6F01561E16C75D06",
                    "Mac-742912EFDBEE19B3",
                    "Mac-7BA5B2794B2CDB12",
                    "Mac-7DF21CB3ED6977E5",
                    "Mac-7DF2A3B5E5D671ED",
                    "Mac-8ED6AF5B48C039E1",
                    "Mac-942452F5819B1C1B",
                    "Mac-942459F5819B171B",
                    "Mac-94245A3940C91C80",
                    "Mac-94245B3640C91C81",
                    "Mac-942B59F58194171B",
                    "Mac-942B5BF58194151B",
                    "Mac-942C5DF58193131B",
                    "Mac-AFD8A9D944EA4843",
                    "Mac-C08A6BB70A942AC2",
                    "Mac-C3EC7CD22292981F",
                    "Mac-F65AE981FFA204ED",
                    "Mac-FC02E91DDD3FA6A4",
                    "Mac-F2208EC8",
                    "Mac-F2218EA9",
                    "Mac-F2218EC8",
                    "Mac-F2218FA9",
                    "Mac-F2218FC8",
                    "Mac-F221BEC8",
                    "Mac-F221DCC8",
                    "Mac-F222BEC8",
                    "Mac-F2238AC8",
                    "Mac-F2238BAE",
                    "Mac-F223BEC8",
                    "Mac-F22586C8",
                    "Mac-F22587A1",
                    "Mac-F22587C8",
                    "Mac-F22589C8",
                    "Mac-F2268AC8",
                    "Mac-F2268CC8",
                    "Mac-F2268DAE",
                    "Mac-F2268DC8",
                    "Mac-F2268EC8",
                    "Mac-F226BEC8",
                    "Mac-F22788AA",
                    "Mac-F227BEC8",
                    "Mac-F22C86C8",
                    "Mac-F22C89C8",
                    "Mac-F22C8AC8",
                    "Mac-F42386C8",
                    "Mac-F42388C8",
                    "Mac-F4238BC8",
                    "Mac-F4238CC8",
                    "Mac-F42C86C8",
                    "Mac-F42C88C8",
                    "Mac-F42C89C8",
                    "Mac-F42D86A9",
                    "Mac-F42D86C8",
                    "Mac-F42D88C8",
                    "Mac-F42D89A9",
                    "Mac-F42D89C8"
                ],
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
                boardIDs: [
                    "Mac-2E6FAB96566FE58C",
                    "Mac-4B7AC7E43945597E",
                    "Mac-4BC72D62AD45599E",
                    "Mac-66F35F19FE2A0D05",
                    "Mac-6F01561E16C75D06",
                    "Mac-742912EFDBEE19B3",
                    "Mac-7BA5B2794B2CDB12",
                    "Mac-8ED6AF5B48C039E1",
                    "Mac-942452F5819B1C1B",
                    "Mac-942459F5819B171B",
                    "Mac-94245A3940C91C80",
                    "Mac-94245B3640C91C81",
                    "Mac-942B59F58194171B",
                    "Mac-942B5BF58194151B",
                    "Mac-942C5DF58193131B",
                    "Mac-C08A6BB70A942AC2",
                    "Mac-C3EC7CD22292981F",
                    "Mac-F2208EC8",
                    "Mac-F2218EA9",
                    "Mac-F2218EC8",
                    "Mac-F2218FA9",
                    "Mac-F2218FC8",
                    "Mac-F221BEC8",
                    "Mac-F221DCC8",
                    "Mac-F222BEC8",
                    "Mac-F2238AC8",
                    "Mac-F2238BAE",
                    "Mac-F223BEC8",
                    "Mac-F22586C8",
                    "Mac-F22587A1",
                    "Mac-F22587C8",
                    "Mac-F22589C8",
                    "Mac-F2268AC8",
                    "Mac-F2268CC8",
                    "Mac-F2268DAE",
                    "Mac-F2268DC8",
                    "Mac-F2268EC8",
                    "Mac-F226BEC8",
                    "Mac-F22788A9",
                    "Mac-F22788AA",
                    "Mac-F22788C8",
                    "Mac-F227BEC8",
                    "Mac-F22C86C8",
                    "Mac-F22C89C8",
                    "Mac-F22C8AC8",
                    "Mac-F4208AC8",
                    "Mac-F4208CA9",
                    "Mac-F4208CAA",
                    "Mac-F4208DA9",
                    "Mac-F4208DC8",
                    "Mac-F4208EAA",
                    "Mac-F42187C8",
                    "Mac-F42189C8",
                    "Mac-F4218EC8",
                    "Mac-F4218FC8",
                    "Mac-F42289C8",
                    "Mac-F4228EC8",
                    "Mac-F42386C8",
                    "Mac-F42388C8",
                    "Mac-F4238BC8",
                    "Mac-F4238CC8",
                    "Mac-F42786A9",
                    "Mac-F42C86C8",
                    "Mac-F42C88C8",
                    "Mac-F42C89C8",
                    "Mac-F42C8CC8",
                    "Mac-F42D86A9",
                    "Mac-F42D86C8",
                    "Mac-F42D88C8",
                    "Mac-F42D89A9",
                    "Mac-F42D89C8"
                ],
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
            if let architecture: Architecture = Hardware.architecture,
                architecture == .appleSilicon {
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
            "packages": packages.map(\.dictionary),
            "beta": beta
        ]
    }
    var mavericksOrNewer: Bool {
        bigSurOrNewer || version.range(of: "^10\\.(9|1[0-5])\\.", options: .regularExpression) != nil
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
        Int64(packages.map(\.size).reduce(0, +))
    }
    var diskImageSize: Double {
        ceil(Double(size) / Double(Int64.gigabyte)) + 1.5
    }
    var isoSize: Double {
        ceil(Double(size) / Double(Int64.gigabyte)) + 1.5
    }
}
