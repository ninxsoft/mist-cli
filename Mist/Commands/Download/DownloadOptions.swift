//
//  DownloadOptions.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

struct DownloadOptions: ParsableArguments {

    @Argument(help: """
    Specify a macOS name, version or build to download:
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
    * 21A5304g (macOS Monterey Beta 12.0)
    * 20G95 (macOS Big Sur 11.5.2)
    * 19H15 (macOS Catalina 10.15.7)
    * 18G8103 (macOS Mojave 10.14.6)
    * 17G66 (macOS High Sierra 10.13.6)
    Note: Specifying a macOS name will assume the latest version and build of that particular macOS.
    Note: Specifying a macOS version will assume the latest build of that particular macOS.
    """)
    var searchString: String

    @Option(name: .shortAndLong, help: """
    Specify the platform which defines the download type:
    * apple (macOS Firmware IPSW File)
    * intel (macOS Installer Application Bundle)\n
    """)
    var platform: PlatformType = .intel

    @Flag(name: [.customShort("b"), .long], help: """
    Include beta macOS Firmwares / Installers in search results.
    """)
    var includeBetas: Bool = false

    @Flag(name: [.customShort("j"), .long], help: """
    Output status in json format for easy parsing.
    """)
    var structuredOutput: Bool = false

    @Option(name: .shortAndLong, help: """
    Override the default Software Update Catalog URLs.
    Note: This only applies when the platform is set to 'intel'.
    """)
    var catalogURL: String?

    @Flag(name: .shortAndLong, help: """
    Force overwriting existing macOS Downloads matching the provided filename(s).
    Note: Downloads will fail if an existing file is found and this flag is not provided.
    """)
    var force: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Firmware output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'\n
    """)
    var firmwareName: String = .filenameTemplate + ".ipsw"

    @Flag(name: .long, help: """
    Generate a macOS Installer Application Bundle.
    Note: This only applies when the platform is set to 'intel'.
    """)
    var application: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Installer output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'\n
    """)
    var applicationName: String = .filenameTemplate + ".app"

    @Flag(name: .long, help: """
    Generate a macOS Disk Image.
    Note: This only applies when the platform is set to 'intel'.
    """)
    var image: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Disk Image output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'\n
    """)
    var imageName: String = .filenameTemplate + ".dmg"

    @Option(name: .long, help: """
    Codesign the exported macOS Disk Image (.dmg).
    Specify a signing identity name, eg. "Developer ID Application: Name (Team ID)".
    """)
    var imageSigningIdentity: String?

    @Flag(name: .long, help: """
    Generate a macOS Installer Package.
    Note: This only applies when the platform is set to 'intel'.
    """)
    var package: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Installer Package output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'\n
    """)
    var packageName: String = .filenameTemplate + ".pkg"

    @Option(name: .long, help: """
    Specify the macOS Installer Package identifier. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    * Spaces will be replaced with hyphens -
    """)
    var packageIdentifier: String?

    @Option(name: .long, help: """
    Codesign the exported macOS Installer Package (.pkg).
    Specify a signing identity name, eg. "Developer ID Installer: Name (Team ID)".
    """)
    var packageSigningIdentity: String?

    @Option(name: .shortAndLong, help: """
    Specify a keychain path to search for signing identities.
    Note: If no keychain is specified, the default user login keychain will be used.
    Note: This only applies when the platform is set to 'intel'.
    """)
    var keychain: String?

    @Option(name: .shortAndLong, help: """
    Specify the output directory. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    Note: Parent directories will be created automatically.\n
    """)
    var outputDirectory: String = .outputDirectory

    @Option(name: .shortAndLong, help: """
    Specify the temporary downloads directory.
    Note: Parent directories will be created automatically.\n
    """)
    var temporaryDirectory: String = .temporaryDirectory

    func outputDirectory(for firmware: Firmware) -> String {
        outputDirectory.stringWithSubstitutions(using: firmware)
    }

    func outputDirectory(for product: Product) -> String {
        outputDirectory.stringWithSubstitutions(using: product)
    }

    func temporaryDirectory(for firmware: Firmware) -> String {
        "\(temporaryDirectory)/\(firmware.identifier)"
            .replacingOccurrences(of: "//", with: "/")
    }

    func temporaryDirectory(for product: Product) -> String {
        "\(temporaryDirectory)/\(product.identifier)"
            .replacingOccurrences(of: "//", with: "/")
    }

    func firmwarePath(for firmware: Firmware) -> String {
        "\(outputDirectory)/\(firmwareName)".stringWithSubstitutions(using: firmware)
    }

    func applicationPath(for product: Product) -> String {
        "\(outputDirectory)/\(applicationName)".stringWithSubstitutions(using: product)
    }

    func imagePath(for product: Product) -> String {
        "\(outputDirectory)/\(imageName)".stringWithSubstitutions(using: product)
    }

    func packagePath(for product: Product) -> String {
        "\(outputDirectory)/\(packageName)".stringWithSubstitutions(using: product)
    }

    func packageIdentifier(for product: Product) -> String {

        guard let identifier: String = packageIdentifier else {
            return ""
        }

        return identifier
            .stringWithSubstitutions(using: product)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }

    func temporaryScriptsDirectory(for product: Product) -> String {
        "\(temporaryDirectory)/\(product.identifier)-Scripts"
            .replacingOccurrences(of: "//", with: "/")
    }
}
