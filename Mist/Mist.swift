//
//  Mist.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import ArgumentParser
import Foundation

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}

struct Mist: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(abstract: .abstract, discussion: .discussion)

    @Flag(name: .shortAndLong, help: """
    List all macOS Installers available to download.
    """)
    var list: Bool = false

    @Option(name: .shortAndLong, help: """
    Optionally export the list to a file.
    """)
    var export: String?

    @Option(name: .shortAndLong, help: """
    Format of the list to export:
    csv
    json
    plist
    yaml
    """)
    var format: ExportFormat?

    @Flag(name: .shortAndLong, help: """
    Download a macOS Installer.
    """)
    var download: Bool = false

    @Option(name: .shortAndLong, help: """
    Optionally specify macOS name, examples:
    Big Sur (11.x)
    Catalina (10.15.x)
    Mojave (10.14.x)
    High Sierra (10.13.x)
    """)
    var name: String = "latest"

    @Option(name: .shortAndLong, help: """
    Optionally specify macOS version, examples:
    11.2.3 (macOS Big Sur)
    10.15.7 (macOS Catalina)
    10.14.6 (macOS Mojave)
    10.13.6 (macOS High Sierra)
    """)
    var macOSVersion: String = "latest"

    @Option(name: .shortAndLong, help: """
    Optionally specify macOS build number, examples:
    20D91 (macOS Big Sur 11.2.3)
    19H524 (macOS Catalina 10.15.7)
    18G8022 (macOS Mojave 10.14.6)
    17G14042 (macOS High Sierra 10.13.6)
    """)
    var build: String = "latest"

    @Option(name: .shortAndLong, help: """
    Specify the output directory
    """)
    var output: String = .defaultOutputDirectory

    @Flag(name: .shortAndLong, help: """
    Export as macOS Disk Image (.dmg).
    """)
    var image: Bool = false

    @Flag(name: .shortAndLong, help: """
    Export as macOS Installer Package (.pkg).
    """)
    var package: Bool = false

    @Option(name: .shortAndLong, help: """
    Specify the package identifier.
    eg. com.yourcompany.pkg.mac-os-install-{name}
    """)
    var identifier: String?

    @Option(name: .shortAndLong, help: """
    Optionally codesign macOS Disk Images (.dmg) and macOS Installer Packages (.pkg).
    Specify a signing identity name, eg. "Developer ID Installer: ABC XYZ (Team ID)".
    """)
    var sign: String?

    @Flag(name: .shortAndLong, help: "Display the version of \(String.appName).")
    var version: Bool = false

    mutating func run() throws {

        do {
            if list {
                try List.run(format: format, exportPath: export)
            } else if download {
                let settings: Settings = Settings(image: image, package: package, output: output, identifier: identifier, identity: sign)
                try Download.run(name: name, version: macOSVersion, build: build, settings: settings)
            } else if version {
                Version.run()
            } else {
                print(Mist.helpMessage())
            }
        } catch {
            printFormattedError(error)
        }
    }

    private func printFormattedError(_ error: Error) {

        guard let mistError: MistError = error as? MistError else {
            PrettyPrint.print(.error, string: error.localizedDescription)
            return
        }

        PrettyPrint.print(.error, string: mistError.description)
    }
}
