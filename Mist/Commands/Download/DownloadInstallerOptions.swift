//
//  DownloadInstallerOptions.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser

struct DownloadInstallerOptions: ParsableArguments {

    @Argument(help: """
    Specify a macOS name, version or build to download:

    Name               │ Version │ Build
    ───────────────────┼─────────┼──────
    macOS Sonoma       │ 14.x    │ 23xyz
    macOS Ventura      │ 13.x    │ 22xyz
    macOS Monterey     │ 12.x    │ 21xyz
    macOS Big Sur      │ 11.x    │ 20xyz
    macOS Catalina     │ 10.15.x │ 19xyz
    macOS Mojave       │ 10.14.x │ 18xyz
    macOS High Sierra  │ 10.13.x │ 17xyz
    macOS Sierra       │ 10.12.x │ 16xyz
    OS X El Capitan    │ 10.11.6 │ 15xyz
    OS X Yosemite      │ 10.10.5 │ 14xyz
    OS X Mountain Lion │ 10.8.5  │ 12xyz
    Mac OS X Lion      │ 10.7.5  │ 11xyz

    Note: Specifying a macOS name will assume the latest version and build of that particular macOS.
    Note: Specifying a macOS version will assume the latest build of that particular macOS.
    """)
    var searchString: String

    @Argument(help: """
    Specify the requested output type(s):
    * application to generate a macOS Installer Application Bundle (.app).
    * image to generate a macOS Disk Image (.dmg).
    * iso to generate a Bootable macOS Disk Image (.iso), for use with virtualization software (ie. Parallels Desktop, VMware Fusion, VirtualBox).
    Note: This option will fail when targeting macOS Catalina 10.15 and older on Apple Silicon Macs.
    Note: This option will fail when targeting OS X Mountain Lion 10.8.5 and older on Intel-based Macs.
    * package to generate a macOS Installer Package (.pkg).
    * bootableinstaller to create a Bootable macOS Installer on a mounted volume
    """)
    var outputType: [InstallerOutputType]

    @Flag(name: [.customShort("b"), .long], help: """
    Include beta macOS Installers in search results.
    """)
    var includeBetas: Bool = false

    @Flag(name: .long, help: """
    Only include macOS Installers that are compatible with this Mac in search results.
    """)
    var compatible: Bool = false

    @Option(name: .shortAndLong, help: """
    Override the default Software Update Catalog URLs.
    """)
    var catalogURL: String?

    @Flag(name: .long, help: """
    Cache downloaded files in the temporary downloads directory.
    """)
    var cacheDownloads: Bool = false

    @Flag(name: .shortAndLong, help: """
    Force overwriting existing macOS Downloads matching the provided filename(s).
    Note: Downloads will fail if an existing file is found and this flag is not provided.
    """)
    var force: Bool = false

    @Option(name: .long, help: """
    Specify the macOS Installer output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    """)
    var applicationName: String = .filenameTemplate + ".app"

    @Option(name: .long, help: """
    Specify the macOS Disk Image output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    """)
    var imageName: String = .filenameTemplate + ".dmg"

    @Option(name: .long, help: """
    Codesign the exported macOS Disk Image (.dmg).
    Specify a signing identity name, eg. "Developer ID Application: Name (Team ID)".
    """)
    var imageSigningIdentity: String?

    @Option(name: .long, help: """
    Specify the Bootable macOS Disk Image output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    """)
    var isoName: String = .filenameTemplate + ".iso"

    @Option(name: .long, help: """
    Specify the macOS Installer Package output filename. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    """)
    var packageName: String = .filenameTemplate + ".pkg"

    @Option(name: .long, help: """
    Specify the macOS Installer Package identifier. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    * Spaces will be replaced with hyphens -
    """)
    var packageIdentifier: String = .packageIdentifierTemplate

    @Option(name: .long, help: """
    Codesign the exported macOS Installer Package (.pkg).
    Specify a signing identity name, eg. "Developer ID Installer: Name (Team ID)".
    """)
    var packageSigningIdentity: String?

    @Option(name: .long, help: """
    Path to the mounted volume that will be used to create the Bootable macOS Installer.
    Note: The volume must be formatted as 'Mac OS Extended (Journaled)'. Use Disk Utility to format volumes as required.
    Note: The volume will be erased automatically. Ensure you have backed up any necessary data before proceeding.
    """)
    var bootableInstallerVolume: String?

    @Option(name: .long, help: """
    Specify a keychain path to search for signing identities.
    Note: If no keychain is specified, the default user login keychain will be used.
    """)
    var keychain: String?

    @Option(name: .shortAndLong, help: """
    Specify the output directory. The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    Note: Parent directories will be created automatically.
    """)
    var outputDirectory: String = .outputDirectory

    @Option(name: .shortAndLong, help: """
    Specify the temporary downloads directory.
    Note: Parent directories will be created automatically.
    """)
    var temporaryDirectory: String = .temporaryDirectory

    @Option(name: .long, help: """
    Optionally specify the <url:port> to an Apple Content Caching Server to help speed up downloads
    Note: Content Caching is only supported over HTTP, not HTTPS
    """)
    var cachingServer: String?

    @Option(name: [.customShort("e"), .customLong("export")], help: """
    Specify the path to export the download results to one of the following formats:
    * /path/to/export.json (JSON file)
    * /path/to/export.plist (Property List file)
    * /path/to/export.yaml (YAML file)
    The following variables will be dynamically substituted:
    * %NAME% will be replaced with 'macOS Monterey'
    * %VERSION% will be replaced with '12.0'
    * %BUILD% will be replaced with '21A5304g'
    Note: The file extension will determine the output file format.
    Note: Parent directories will be created automatically.
    """)
    var exportPath: String?

    @Flag(name: .long, help: """
    Remove all ANSI escape sequences (ie. strip all color and formatting) from standard output.
    """)
    var noAnsi: Bool = false

    @Option(name: .long, help: """
    Number of times to attempt resuming a download before failing.
    """)
    var retries: Int = 10

    @Option(name: .long, help: """
    Number of seconds to wait before attempting to resume a download.
    """)
    var retryDelay: Int = 30

    @Flag(name: .shortAndLong, help: """
    Suppress verbose output.
    """)
    var quiet: Bool = false
}
