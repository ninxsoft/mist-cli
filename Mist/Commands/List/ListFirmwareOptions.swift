//
//  ListFirmwareOptions.swift
//  Mist
//
//  Created by Nindi Gill on 30/5/2022.
//

import ArgumentParser

struct ListFirmwareOptions: ParsableArguments {

    @Argument(help: """
    Optionally specify a macOS name, version or build to filter the list results:
    * macOS Ventura
    * macOS Monterey
    * macOS Big Sur
    * 13.x (macOS Ventura)
    * 12.x (macOS Monterey)
    * 11.x (macOS Big Sur)
    * 22C (macOS Ventura 13.1.x)
    * 21G (macOS Monterey 12.6.x)
    * 20G (macOS Big Sur 11.6.x)
    """)
    var searchString: String?

    @Flag(name: .shortAndLong, help: """
    Filter only the latest (first) result that is found.
    """)
    var latest: Bool = false

    @Flag(name: [.customShort("b"), .long], help: """
    Include beta macOS Firmwares in search results.
    """)
    var includeBetas: Bool = false

    @Flag(name: .long, help: """
    Only include macOS Firmwares that are compatible with this Mac in search results.
    """)
    var compatible: Bool = false

    @Option(name: [.customShort("e"), .customLong("export")], help: """
    Specify the path to export the list to one of the following formats:
    * /path/to/export.csv (CSV file)
    * /path/to/export.json (JSON file)
    * /path/to/export.plist (Property List file)
    * /path/to/export.yaml (YAML file)
    Note: The file extension will determine the output file format.
    """)
    var exportPath: String?

    @Option(name: .customLong("metadata-cache"), help: """
    Optionally specify the path to cache the macOS Firmwares metadata JSON file. This cache is used when mist is unable to retrieve macOS Firmwares remotely.
    """)
    var metadataCachePath: String = .firmwaresMetadataCachePath

    @Flag(name: .long, help: """
    Remove all ANSI escape sequences (ie. strip all color and formatting) from standard output.
    """)
    var noAnsi: Bool = false

    @Option(name: .shortAndLong, help: """
    Specify the standard output format:
    * ascii (ASCII table)
    * csv (Comma Separated Values)
    * json (JSON - pretty printed)
    * plist (Property List)
    * yaml (YAML file)
    """)
    var outputType: ListOutputType = .ascii

    @Flag(name: .shortAndLong, help: """
    Suppress verbose output.
    """)
    var quiet: Bool = false
}
