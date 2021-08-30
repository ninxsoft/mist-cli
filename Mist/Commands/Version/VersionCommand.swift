//
//  VersionCommand.swift
//  Mist
//
//  Created by Nindi Gill on 26/8/21.
//

import ArgumentParser
import Foundation

struct VersionCommand: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(commandName: "version", abstract: "Display the version of \(String.appName).")

    mutating func run() throws {
        Version.run()
    }
}
