//
//  File.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

extension FileManager {

    func create(_ url: URL, description: String) throws {

        guard !FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        PrettyPrint.print(.info, string: "Creating \(description) '\(url.path)'...")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        PrettyPrint.print(.success, string: "Created \(description) '\(url.path)'")
    }

    func copy(_ source: URL, to destination: URL) throws {

        guard FileManager.default.fileExists(atPath: source.path) else {
            return
        }

        PrettyPrint.print(.info, string: "Copying '\(source.path)' to '\(destination.path)'...")
        try FileManager.default.copyItem(at: source, to: destination)
        PrettyPrint.print(.success, string: "Copied '\(source.path)' to '\(destination.path)'...")
    }

    func move(_ source: URL, to destination: URL) throws {

        guard FileManager.default.fileExists(atPath: source.path) else {
            return
        }

        try FileManager.default.moveItem(at: source, to: destination)
    }

    func remove(_ url: URL, description: String) throws {

        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        PrettyPrint.print(.info, string: "Deleting \(description) '\(url.path)'...")
        try FileManager.default.removeItem(at: url)
        PrettyPrint.print(.success, string: "Deleted \(description) '\(url.path)'")
    }
}
