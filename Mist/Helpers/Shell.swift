//
//  Shell.swift
//  Mist
//
//  Created by Nindi Gill on 14/3/21.
//

import Foundation

struct Shell {

    static func execute(_ arguments: [String], currentDirectoryPath: String? = nil) throws {
        let process: Process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = arguments

        if let string: String = currentDirectoryPath {
            process.currentDirectoryPath = string
        }

        process.launch()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw MistError.invalidExitStatus(code: process.terminationStatus, arguments: arguments)
        }
    }
}
