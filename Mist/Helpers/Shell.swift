//
//  Shell.swift
//  Mist
//
//  Created by Nindi Gill on 14/3/21.
//

import Foundation

struct Shell {

    static func execute(_ arguments: [String], environment variables: [String: String]? = nil, currentDirectoryPath: String? = nil) throws {
        let process: Process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = arguments

        if let variables: [String: String] = variables {
            var environment: [String: String] = ProcessInfo.processInfo.environment

            for (key, value) in variables {
                environment[key] = value
            }

            process.environment = environment
        }

        if let currentDirectoryPath: String = currentDirectoryPath {
            process.currentDirectoryPath = currentDirectoryPath
        }

        process.launch()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw MistError.invalidExitStatus(code: process.terminationStatus, arguments: arguments)
        }
    }
}
