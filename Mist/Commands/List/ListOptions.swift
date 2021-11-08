//
//  ListOptions.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

struct ListOptions: ParsableArguments {

    @Argument(help: """
    Optionally specify a macOS name, version or build to filter the list results:
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
    * 21A (macOS Monterey 12.0.1)
    * 20G (macOS Big Sur 11.6.1)
    * 19H (macOS Catalina 10.15.7)
    * 18G (macOS Mojave 10.14.6)
    * 17G (macOS High Sierra 10.13.6)
    """)
    var searchString: String?

    @Option(name: .shortAndLong, help: """
    Specify the platform which defines the list type:
    * apple (macOS Firmware IPSW File)
    * intel (macOS Installer Application Bundle)\n
    """)
    var platform: PlatformType = .intel

    @Flag(name: .shortAndLong, help: """
    Filter only the latest (first) result that is found.
    """)
    var latest: Bool = false

    @Flag(name: [.customShort("b"), .long], help: """
    Include beta macOS Firmwares / Installers in search results.
    """)
    var includeBetas: Bool = false

    @Option(name: .shortAndLong, help: """
    Override the default Software Update Catalog URLs.
    Note: This only applies when the platform is set to 'intel'.
    """)
    var catalogURL: String?

    @Option(name: [.customShort("e"), .customLong("export")], help: """
    Specify the path to export the list to one of the following formats:
    * /path/to/export.csv (CSV file)
    * /path/to/export.json (JSON file)
    * /path/to/export.plist (Property List file)
    * /path/to/export.yaml (YAML file)
    Note: The file extension will determine the output file format.
    """)
    var exportPath: String?

    @Option(name: .shortAndLong, help: """
    Specify the standard output format:
    * ascii (ASCII table)
    * csv (Comma Separated Values)
    * json (JSON - pretty printed)
    * plist (Property List)
    * yaml (YAML file)\n
    """)
    var outputType: OutputType = .ascii

    @Flag(name: .shortAndLong, help: """
    Suppress verbose output.
    """)
    var quiet: Bool = false
}
