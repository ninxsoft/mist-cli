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
    Specify a catalog seed:
    * standard (Standard - macOS default)
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
    Export the list to CSV file.
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
    Specify a macOS name or version:
    * Monterey or 12.x
    * Big Sur or 11.x
    * Catalina or 10.15.x
    * Mojave or 10.14.x
    * High Sierra or 10.13.x
    Note: Specifying a macOS name will assume the latest version.
    """)
    var macOSVersion: String = "latest"

    @Option(name: .shortAndLong, help: """
    Specify a macOS build:
    * 20F71 (macOS Big Sur 11.4)
    * 19H524 (macOS Catalina 10.15.7)
    * 18G8022 (macOS Mojave 10.14.6)
    * 17G14042 (macOS High Sierra 10.13.6)
    """)
    var build: String = "latest"

    @Option(name: .shortAndLong, help: """
    Specify the temporary downloads directory.
    Note: Parent directories will be created automatically.
    """)
    var temporaryDirectory: String = .temporaryDirectory

    @Option(name: .shortAndLong, help: """
    Specify the output directory.
    Note: Parent directories will be created automatically.
    """)
    var outputDirectory: String = .outputDirectory

    @Option(name: .shortAndLong, help: """
    Specify the filename template. The following variables will be substituted with dynamic values:
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

    @Flag(name: .shortAndLong, help: """
    Export as macOS Installer Package (.pkg).
    """)
    var package: Bool = false

    @Flag(name: .shortAndLong, help: """
    Export as ZIP Archive (.zip).
    """)
    var zip: Bool = false

    @Option(name: .long, help: """
    Specify the package identifier prefix, eg. com.yourcompany.pkg
    Note: .install-%name% will be appended to the prefix.
    """)
    var packageIdentifierPrefix: String?

    @Option(name: .long, help: """
    Codesign the exported macOS Disk Image (.dmg) or ZIP archive (.zip).
    Specify a signing identity name, eg. "Developer ID Application: Nindi Gill (Team ID)".
    """)
    var signingIdentityApplication: String?

    @Option(name: .long, help: """
    Codesign the exported macOS Installer Packages (.pkg).
    Specify a signing identity name, eg. "Developer ID Installer: Nindi Gill (Team ID)".
    """)
    var signingIdentityInstaller: String?

    @Option(name: .shortAndLong, help: """
    Specify a keychain path to search for signing identities.
    """)
    var keychain: String?

    @Flag(name: .shortAndLong, help: "Display the version of \(String.appName).")
    var version: Bool = false

    mutating func run() throws {

        do {
            if list {
                try List.run(catalog: catalog, csv: exportCSV, json: exportJSON, plist: exportPLIST, yaml: exportYAML)
            } else if download {
                let settings: Settings = Settings(
                    temporaryDirectory: temporaryDirectory,
                    outputDirectory: outputDirectory,
                    filenameTemplate: filenameTemplate,
                    application: application,
                    image: image,
                    package: package,
                    packageIdentifierPrefix: packageIdentifierPrefix,
                    zip: zip,
                    signingIdentityApplication: signingIdentityApplication,
                    signingIdentityInstaller: signingIdentityInstaller,
                    keychain: keychain
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
