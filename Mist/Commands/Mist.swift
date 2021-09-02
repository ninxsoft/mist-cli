//
//  Mist.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import ArgumentParser
import Foundation

struct Mist: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(abstract: .abstract, discussion: .discussion, subcommands: [ListCommand.self, DownloadCommand.self, VersionCommand.self])

    static func noop() { }

    mutating func run() throws {
        print(Mist.helpMessage())
    }
}
