//
//  Version.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation

/// Struct used to perform **Version** operations.
struct Version {

    /// Current version.
    static let version: String = "1.6"

    /// Prints the current version and checks for the latest version.
    static func run() {

        guard let url: URL = URL(string: .latestReleaseURL) else {
            print(version)
            return
        }

        do {
            let string: String = try String(contentsOf: url, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let tag: String = dictionary["tag_name"] as? String else {
                print(version)
                return
            }

            let latestVersion: String = tag.replacingOccurrences(of: "v", with: "")
            print("\(version) (latest: \(latestVersion))")

            guard version.compare(latestVersion, options: .numeric) == .orderedAscending else {
                return
            }

            print("Visit \(String.repositoryURL) to grab the latest release of \(String.appName)")
        } catch {
            print("Unable to check for latest version.")
        }
    }
}
