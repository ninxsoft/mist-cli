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
        case sha1sum = "sha1sum"
        case size = "filesize"
        case url = "url"
        case date = "releasedate"
        case signed = "signed"
    }

    static let devicesURL: String = "https://api.ipsw.me/v4/devices"
    static let deviceURL: String = "https://api.ipsw.me/v4/device"

    let identifier: String = UUID().uuidString
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
    let sha1sum: String
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
    var dictionary: [String: Any] {
        [
            "signed": signed,
            "name": name,
            "version": version,
            "build": build,
            "date": dateDescription
        ]
    }
    var csvLine: String {
        "\"=\"\"\(signed)\"\"\",\"=\"\"\(name)\"\"\",\"=\"\"\(version)\"\"\",\"=\"\"\(build)\"\"\",\(date)\n"
    }

    static func deviceURL(for identifier: String) -> String {
        "\(deviceURL)/\(identifier)"
    }
}

extension Firmware: Equatable {

    static func == (lhs: Firmware, rhs: Firmware) -> Bool {
        lhs.version == rhs.version &&
        lhs.build == rhs.build &&
        lhs.sha1sum == rhs.sha1sum &&
        lhs.size == rhs.size &&
        lhs.url == rhs.url &&
        lhs.signed == rhs.signed
    }
}
