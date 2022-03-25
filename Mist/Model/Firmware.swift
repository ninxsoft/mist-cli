//
//  Firmware.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import Foundation

struct Firmware: Decodable {

    enum CodingKeys: String, CodingKey {
        case version = "version"
        case build = "buildid"
        case shasum = "sha1sum"
        case size = "size"
        case url = "url"
        case date = "releasedate"
        case signed = "signed"
    }

    static let firmwaresURL: String = "https://api.ipsw.me/v3/firmwares.json/condensed"

    var identifier: String {
        "\(String.identifier).\(version)-\(build)"
    }
    var name: String {

        if version.range(of: "^12", options: .regularExpression) != nil {
            return "macOS Monterey"
        } else if version.range(of: "^11", options: .regularExpression) != nil {
            return "macOS Big Sur"
        } else {
            return "macOS"
        }
    }
    let version: String
    let build: String
    let shasum: String
    let size: Int64
    let url: String
    let date: String
    var dateDescription: String {
        String(date.prefix(10))
    }
    let signed: Bool
    var signedDescription: String {
        signed ? "Yes": "No"
    }
    var isBeta: Bool {
        build.range(of: "[a-z]$", options: .regularExpression) != nil
    }
    var dictionary: [String: Any] {
        [
            "signed": signed,
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "date": dateDescription
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
            "signed": signed,
            "beta": isBeta
        ]
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
