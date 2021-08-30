//
//  Shell.swift
//  Mist
//
//  Created by Nindi Gill on 14/3/21.
//

import Foundation

struct Shell {

    static func execute(_ arguments: [String], environment variables: [String: String] = [:], currentDirectoryPath: String? = nil) throws -> String? {
        let output: Pipe = Pipe()
        let process: Process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = arguments
        process.standardOutput = output

        var environment: [String: String] = ProcessInfo.processInfo.environment

        for (key, value) in variables {
            environment[key] = value
        }

        process.environment = environment

        if let currentDirectoryPath: String = currentDirectoryPath {
            process.currentDirectoryPath = currentDirectoryPath
        }

        process.launch()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw MistError.invalidExitStatus(code: process.terminationStatus, arguments: arguments)
        }

        let data: Data = output.fileHandleForReading.readDataToEndOfFile()

        guard let string: String = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }
}
