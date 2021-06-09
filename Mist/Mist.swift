//
//  Mist.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import ArgumentParser
import Foundation

struct Mist: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(abstract: .abstract, discussion: .discussion)

    @Option(name: .shortAndLong, help: """
    Optionally specify a catalog seed:
    * customer (Customer Seed - AppleSeed Program)
    * developer (Developer Seed - Apple Developer Program)
    * public (Public Seed - Apple Beta Software Program)
    """)
    var catalog: Catalog = .standard

    @Flag(name: .shortAndLong, help: """
    List all macOS Installers available to download.
    """)
    var list: Bool = false

    @Option(name: .long, help: """
    Export the list to CSV (comma separated values) file.
    """)
    var exportCSV: String?

    @Option(name: .long, help: """
    Export the list to JSON file.
    """)
    var exportJSON: String?

    @Option(name: .long, help: """
    Export the list to PLIST (Property List) file.
    """)
    var exportPLIST: String?

    @Option(name: .long, help: """
    Export the list to a YAML file.
    """)
    var exportYAML: String?

    @Flag(name: .shortAndLong, help: """
    Download a macOS Installer.
    """)
    var download: Bool = false

    @Option(name: .shortAndLong, help: """
    Optionally specify a macOS name or version:
    * Monterey or 12.x
    * Big Sur or 11.x
    * Catalina or 10.15.x
    * Mojave or 10.14.x
    * High Sierra or 10.13.x
    Note: Specifying a macOS name will assume the latest version.
    """)
    var macOSVersion: String = "latest"

    @Option(name: .shortAndLong, help: """
    Optionally specify a macOS build:
    * 20F71 (macOS Big Sur 11.4)
    * 19H524 (macOS Catalina 10.15.7)
    * 18G8022 (macOS Mojave 10.14.6)
    * 17G14042 (macOS High Sierra 10.13.6)
    """)
    var build: String = "latest"

    @Option(name: .shortAndLong, help: """
    Optionally specify the output directory.
    Note: Parent directories will be created automatically.
    """)
    var outputDirectory: String = .outputDirectory

    @Option(name: .shortAndLong, help: """
    Optionally specify the filename template. The following variables will be substituted with dynamic values:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5248p'
    Note: File extensions will be added automatically.
    """)
    var filenameTemplate: String = .filenameTemplate

    @Flag(name: .shortAndLong, help: """
    Export as macOS Installer application bundle (.app).
    """)
    var application: Bool = false

    @Flag(name: .shortAndLong, help: """
    Export as macOS Disk Image (.dmg).
    """)
    var image: Bool = false

    @Option(name: .long, help: """
    Optionally codesign the exported macOS Disk Image (.dmg).
    Specify a signing identity name, eg. "Developer ID Application: Nindi Gill (Team ID)".
    """)
    var imageIdentity: String?

    @Flag(name: .shortAndLong, help: """
    Export as macOS Installer Package (.pkg).
    """)
    var package: Bool = false

    @Option(name: .long, help: """
    Specify the package identifier prefix, eg. com.yourcompany.pkg
    Note: .install-%name% will be appended to the prefix.
    """)
    var packageIdentifierPrefix: String?

    @Option(name: .long, help: """
    Optionally codesign the exported macOS Installer Packages (.pkg).
    Specify a signing identity name, eg. "Developer ID Installer: Nindi Gill (Team ID)".
    """)
    var packageIdentity: String?

    @Flag(name: .shortAndLong, help: """
    Export as ZIP Archive (.zip).
    """)
    var zip: Bool = false

    @Option(name: .long, help: """
    Optionally codesign the exported ZIP archive (.zip).
    Specify a signing identity name, eg. "Developer ID Application: Nindi Gill (Team ID)".
    """)
    var zipIdentity: String?

    @Flag(name: .shortAndLong, help: "Display the version of \(String.appName).")
    var version: Bool = false

    mutating func run() throws {

        do {
            if list {
                try List.run(catalog: catalog, csv: exportCSV, json: exportJSON, plist: exportPLIST, yaml: exportYAML)
            } else if download {
                let settings: Settings = Settings(
                    outputDirectory: outputDirectory,
                    filenameTemplate: filenameTemplate,
                    application: application,
                    image: image,
                    imageIdentity: imageIdentity,
                    package: package,
                    packageIdentifierPrefix: packageIdentifierPrefix,
                    packageIdentity: packageIdentity,
                    zip: zip,
                    zipIdentity: zipIdentity
                )
                try Download.run(catalog: catalog, version: macOSVersion, build: build, settings: settings)
            } else if version {
                Version.run()
            } else {
                print(Mist.helpMessage())
            }
        } catch {
            guard let mistError: MistError = error as? MistError else {
                throw error
            }

            PrettyPrint.print(.error, string: mistError.description)
            throw mistError
        }
    }
}
