//
//  Firmware.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import Foundation

struct Firmware: Decodable {
    enum CodingKeys: String, CodingKey {
        case version
        case build = "buildid"
        case shasum = "sha1sum"
        case size
        case url
        case date = "releasedate"
        case signed
        case compatible
    }

    static let firmwaresURL: String = "https://api.ipsw.me/v3/firmwares.json/condensed"
    static let deviceURLTemplate: String = "https://api.ipsw.me/v4/device/MODELIDENTIFIER?type=ipsw"

    var identifier: String {
        "\(String.identifier).\(version)-\(build)"
    }

    var name: String {
        var name: String = ""

        if version.range(of: "^15", options: .regularExpression) != nil {
            name = "macOS Sequoia"
        } else if version.range(of: "^14", options: .regularExpression) != nil {
            name = "macOS Sonoma"
        } else if version.range(of: "^13", options: .regularExpression) != nil {
            name = "macOS Ventura"
        } else if version.range(of: "^12", options: .regularExpression) != nil {
            name = "macOS Monterey"
        } else if version.range(of: "^11", options: .regularExpression) != nil {
            name = "macOS Big Sur"
        } else {
            name = "macOS \(version)"
        }

        name = beta ? "\(name) beta" : name
        return name
    }

    let version: String
    let build: String
    let shasum: String
    let size: Int64
    let url: String
    let date: String
    let compatible: Bool
    var dateDescription: String {
        String(date.prefix(10))
    }

    let signed: Bool
    var beta: Bool {
        build.range(of: "[a-z]$", options: .regularExpression) != nil
    }

    var filename: String {
        url.components(separatedBy: "/").last ?? url
    }

    var dictionary: [String: Any] {
        [
            "signed": signed,
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "date": dateDescription,
            "compatible": compatible
        ]
    }

    var exportDictionary: [String: Any] {
        [
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "url": url,
            "date": date,
            "compatible": compatible,
            "signed": signed,
            "beta": beta
        ]
    }

    /// Perform a lookup and retrieve a list of supported Firmware builds for this Mac.
    ///
    /// - Returns: An array of Firmware build strings.
    static func supportedBuilds() -> [String] {
        guard
            let architecture: Architecture = Hardware.architecture,
            architecture == .appleSilicon,
            let modelIdentifier: String = Hardware.modelIdentifier,
            let url: URL = URL(string: Firmware.deviceURLTemplate.replacingOccurrences(of: "MODELIDENTIFIER", with: modelIdentifier)) else {
            return []
        }

        do {
            let string: String = try String(contentsOf: url)

            guard
                let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let array: [[String: Any]] = dictionary["firmwares"] as? [[String: Any]] else {
                return []
            }

            return array.compactMap { $0["buildid"] as? String }
        } catch {
            return []
        }
    }
}

extension Firmware: Equatable {
    static func == (lhs: Firmware, rhs: Firmware) -> Bool {
        lhs.version == rhs.version &&
            lhs.build == rhs.build &&
            lhs.shasum == rhs.shasum &&
            lhs.size == rhs.size &&
            lhs.url == rhs.url &&
            lhs.signed == rhs.signed
    }
}
