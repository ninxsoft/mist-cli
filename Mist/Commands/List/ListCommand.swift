//
//  ListCommand.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(commandName: "list", abstract: "List all macOS Installers / Firmwares available to download.")
    @OptionGroup var options: ListOptions

    mutating func run() throws {

        do {
            try List.run(options: options)
        } catch {
            guard let mistError: MistError = error as? MistError else {
                throw error
            }

            PrettyPrint.print(mistError.description, prefix: .ending, prefixColor: .red, parsable: false)
            throw mistError
        }
    }
}
