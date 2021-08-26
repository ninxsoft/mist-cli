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
    Override the default Software Update Catalog URL.
    """)
    var catalogURL: String?

    @Flag(name: .shortAndLong, help: """
    List all macOS Installers available to download.
    """)
    var list: Bool = false

    @Option(name: [.customShort("e"), .customLong("list-export")], help: """
    Specify the path to export the list to one of the following formats:
    * /path/to/export.csv (CSV file).
    * /path/to/export.json (JSON file).
    * /path/to/export.plist (Property List) file).
    * /path/to/export.yaml (YAML file).
    Note: The file extension will determine the output file format.
    """)
    var exportPath: String?

    @Option(name: .shortAndLong, help: """
    Download a macOS Installer, specifying a macOS name, version or build:
    * macOS Monterey
    * macOS Big Sur
    * macOS Catalina
    * macOS Mojave
    * macOS High Sierra
    * 12.x (macOS Monterey)
    * 11.x (macOS Big Sur)
    * 10.15.x (macOS Catalina)
    * 10.14.x (macOS Mojave)
    * 10.13.x (macOS High Sierra)
    * 21A5248p (macOS Monterey Beta 12.0)
    * 20F71 (macOS Big Sur 11.4)
    * 19H524 (macOS Catalina 10.15.7)
    * 18G8022 (macOS Mojave 10.14.6)
    * 17G14042 (macOS High Sierra 10.13.6)
    Note: Specifying a macOS name will assume the latest version and build of that particular macOS.
    Note: Specifying a macOS version will assume the latest build of that particular macOS.
    """)
    var download: String?

    @Option(name: .shortAndLong, help: """
    Specify the output directory. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5248p'
    Note: Parent directories will be created automatically.\n
    """)
    var outputDirectory: String = .outputDirectory

    @Flag(name: .shortAndLong, help: """
    Generate a macOS Installer Application Bundle.
    """)
    var application: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Installer output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5248p'\n
    """)
    var applicationName: String = .filenameTemplate + ".app"

    @Flag(name: .shortAndLong, help: """
    Generate a macOS Disk Image.
    """)
    var image: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Disk Image output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5248p'\n
    """)
    var imageName: String = .filenameTemplate + ".dmg"

    @Option(name: .long, help: """
    Codesign the exported macOS Disk Image (.dmg).
    Specify a signing identity name, eg. "Developer ID Application: Nindi Gill (Team ID)".
    """)
    var imageSigningIdentity: String?

    @Flag(name: .shortAndLong, help: """
    Generate a macOS Installer Package.
    """)
    var package: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Installer Package output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5248p'\n
    """)
    var packageName: String = .filenameTemplate + ".pkg"

    @Option(name: .long, help: """
    Specify the macOS Installer Package identifier. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5248p'
    * Spaces will be replaced with hyphens -\n
    """)
    var packageIdentifier: String = "com.mycompany.pkg.install-%NAME%"

    @Option(name: .long, help: """
    Codesign the exported macOS Installer Package (.pkg).
    Specify a signing identity name, eg. "Developer ID Installer: Nindi Gill (Team ID)".
    """)
    var packageSigningIdentity: String?

    @Option(name: .shortAndLong, help: """
    Specify a keychain path to search for signing identities.
    Note: If no keychain is specified, the default user login keychain will be used.
    """)
    var keychain: String?

    @Option(name: .shortAndLong, help: """
    Specify the temporary downloads directory.
    Note: Parent directories will be created automatically.\n
    """)
    var temporaryDirectory: String = .temporaryDirectory

    @Flag(name: .shortAndLong, help: "Display the version of \(String.appName).")
    var version: Bool = false

    mutating func run() throws {

        do {
            if list {
                try List.run(catalogURL: catalogURL, exportPath: exportPath)
            } else if let download: String = download {
                let settings: Settings = Settings(
                    outputDirectory: outputDirectory,
                    application: application,
                    applicationName: applicationName,
                    image: image,
                    imageName: imageName,
                    imageSigningIdentity: imageSigningIdentity,
                    package: package,
                    packageName: packageName,
                    packageIdentifier: packageIdentifier,
                    packageSigningIdentity: packageSigningIdentity,
                    keychain: keychain,
                    temporaryDirectory: temporaryDirectory
                )
                try Download.run(catalogURL: catalogURL, download: download, settings: settings)
            } else if version {
                Version.run()
            } else {
                print(Mist.helpMessage())
            }
        } catch {
            guard let mistError: MistError = error as? MistError else {
                throw error
            }

            PrettyPrint.print(prefix: "└─", mistError.description)
            Mist.exit(withError: mistError)
        }
    }
}
