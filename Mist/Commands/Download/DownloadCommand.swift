//
//  DownloadCommand.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

struct DownloadCommand: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(commandName: "download", abstract: "Download a macOS Installer / Firmware.")
    @OptionGroup var options: DownloadOptions

    mutating func run() throws {

        do {
            try Download.run(options: options)
        } catch {
            guard let mistError: MistError = error as? MistError else {
                throw error
            }

            PrettyPrint.print(mistError.description, prefix: .ending, prefixColor: .red)
            throw mistError
        }
    }
}
