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
    /// Current version with error message when unable to lookup latest version.
    private static var versionWithErrorMessage: String {
        "\(currentVersion) (Unable to check for latest version)"
    }

    static func noop() { }

    static func version() -> String {

        guard let url: URL = URL(string: .latestReleaseURL) else {
            return versionWithErrorMessage
        }

        do {
            let string: String = try String(contentsOf: url, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let tag: String = dictionary["tag_name"] as? String else {
                return versionWithErrorMessage
            }

            let latestVersion: String = tag.replacingOccurrences(of: "v", with: "")
            var versionString: String = "\(currentVersion) (Latest: \(latestVersion))"

            guard currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending else {
                return versionString
            }

            versionString += "\nVisit \(String.repositoryURL) to grab the latest release of \(String.appName)"
            return versionString
        } catch {
            return versionWithErrorMessage
        }
    }

    mutating func run() {
        print(Mist.helpMessage())
    }
}
