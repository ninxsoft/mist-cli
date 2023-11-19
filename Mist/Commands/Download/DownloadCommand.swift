//
//  DownloadCommand.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser

struct DownloadCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "download",
        abstract: "Download a macOS Firmware / Installer.",
        subcommands: [DownloadFirmwareCommand.self, DownloadInstallerCommand.self]
    )
}
