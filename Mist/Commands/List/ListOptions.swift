//
//  ListOptions.swift
//  Mist
//
//  Created by nindi on 26/8/21.
//

import ArgumentParser
import Foundation

struct ListOptions: ParsableArguments {

    @Option(name: .shortAndLong, help: """
    Specify the platform which defines the list type:
    * apple (macOS Firmware IPSW File)
    * intel (macOS Installer Application Bundle)\n
    """)
    var platform: PlatformType = .intel

    @Option(name: .shortAndLong, help: """
    Override the default Software Update Catalog URL.
    Note: This only applies when the platform is set to 'intel'.
    """)
    var catalogURL: String?

    @Option(name: [.customShort("e"), .customLong("export")], help: """
    Specify the path to export the list to one of the following formats:
    * /path/to/export.csv (CSV file).
    * /path/to/export.json (JSON file).
    * /path/to/export.plist (Property List) file).
    * /path/to/export.yaml (YAML file).
    Note: The file extension will determine the output file format.
    """)
    var exportPath: String?
}
