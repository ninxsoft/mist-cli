//
//  ListCommand.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "list",
        abstract: "List all macOS Firmwares / Installers available to download.",
        subcommands: [ListFirmwareCommand.self, ListInstallerCommand.self]
    )
}
