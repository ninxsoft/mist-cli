//
//  Mist.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import ArgumentParser
import Foundation

struct Mist: ParsableCommand {
    static let configuration: CommandConfiguration = .init(abstract: .abstract, discussion: .discussion, version: version(), subcommands: [ListCommand.self, DownloadCommand.self])

    /// Current version.
    private static let currentVersion: String = "2.2"

    /// Visit URL string.
    private static let visitURLString: String = "Visit \(String.repositoryURL) to grab the latest release of \(String.appName)"

    static func noop() {}

    private static func getLatestVersion() -> String? {
        guard let url: URL = URL(string: .latestReleaseURL) else {
            return nil
        }

        do {
            let string: String = try String(contentsOf: url, encoding: .utf8)

            guard
                let data: Data = string.data(using: .utf8),
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

        var string: String = "\(currentVersion) (latest: \(latestVersion))"

        guard currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending else {
            return string
        }

        string += "\n\(visitURLString)"
        return string
    }

    static func checkForNewVersion(noAnsi: Bool) {
        guard
            let latestVersion: String = getLatestVersion(),
            currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending else {
            return
        }

        PrettyPrint.printHeader("UPDATE AVAILABLE", noAnsi: noAnsi)
        let updateAvailableString: String = "There is a \(String.appName) update available (current version: \(currentVersion), latest version: \(latestVersion))".color(noAnsi ? .reset : .yellow)
        let visitURLString: String = visitURLString.color(noAnsi ? .reset : .yellow)
        PrettyPrint.print(updateAvailableString, noAnsi: noAnsi)
        PrettyPrint.print(visitURLString, noAnsi: noAnsi)
    }

    mutating func run() {
        print(Mist.helpMessage())
    }
}
