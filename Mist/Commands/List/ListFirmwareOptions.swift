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

    Name               │ Version │ Build
    ───────────────────┼─────────┼──────
    macOS Sonoma       │ 14.x    │ 23xyz
    macOS Ventura      │ 13.x    │ 22xyz
    macOS Monterey     │ 12.x    │ 21xyz
    macOS Big Sur      │ 11.x    │ 20xyz

    Note: Specifying a macOS name will assume the latest version and build of that particular macOS.
    Note: Specifying a macOS version will assume the latest build of that particular macOS.
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
