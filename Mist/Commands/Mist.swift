//
//  Mist.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import ArgumentParser
import Foundation

struct Mist: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(abstract: .abstract, discussion: .discussion, version: version(), subcommands: [ListCommand.self, DownloadCommand.self])

    /// Current version.
    private static let currentVersion: String = "1.13"
    /// Visit URL string.
    private static let visitURLString: String = "Visit \(String.repositoryURL) to grab the latest release of \(String.appName)"

    static func noop() { }

    private static func getLatestVersion() -> String? {

        guard let url: URL = URL(string: .latestReleaseURL) else {
            return nil
        }

        do {
            let string: String = try String(contentsOf: url, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let tag: String = dictionary["tag_name"] as? String else {
                return nil
            }

            let latestVersion: String = tag.replacingOccurrences(of: "v", with: "")
            return latestVersion
        } catch {
            return nil
        }
    }

    static func version() -> String {

        guard let latestVersion: String = getLatestVersion() else {
            return "\(currentVersion) (Unable to check for latest version)"
        }

        var string: String = "\(currentVersion) (Latest: \(latestVersion))"

        guard currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending else {
            return string
        }

        string += "\n\(visitURLString)"
        return string
    }
    }

    mutating func run() {
        print(Mist.helpMessage())
    }
}
