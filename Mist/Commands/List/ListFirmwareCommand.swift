//
//  ListFirmwareCommand.swift
//  Mist
//
//  Created by Nindi Gill on 30/5/2022.
//

import ArgumentParser
import Foundation
import Yams

/// Struct used to perform **List Firmware** operations.
struct ListFirmwareCommand: ParsableCommand {

    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "firmware",
        abstract: """
        List all macOS Firmwares available to download.
        * macOS Firmwares are for Apple Silicon Macs only.
        """
    )
    @OptionGroup var options: ListFirmwareOptions

    /// Searches and lists the macOS versions available for download, optionally exporting to a file.
    ///
    /// - Parameters:
    ///   - options: List options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if macOS versions fail to be retrieved or exported.
    static func run(options: ListFirmwareOptions) throws {
        try inputValidation(options)
        !options.quiet ? PrettyPrint.printHeader("SEARCH") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Searching for macOS Firmware versions...") : Mist.noop()
        var firmwares: [Firmware] = HTTP.retrieveFirmwares(includeBetas: options.includeBetas, compatible: options.compatible, metadataCachePath: options.metadataCachePath, quiet: options.quiet)

        if let searchString: String = options.searchString {
            firmwares = HTTP.firmwares(from: firmwares, searchString: searchString)
        }

        if options.latest {
            if let firmware: Firmware = firmwares.first {
                firmwares = [firmware]
            }
        }

        try export(firmwares.map { $0.dictionary }, options: options)
        !options.quiet ? PrettyPrint.print("Found \(firmwares.count) macOS Firmware(s) available for download\n", prefix: .ending) : Mist.noop()

        if !firmwares.isEmpty {
            try list(firmwares.map { $0.dictionary }, options: options)
        }
    }

    /// Perform a series of validations on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: List options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidation(_ options: ListFirmwareOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("INPUT VALIDATION") : Mist.noop()

        if let string: String = options.searchString {

            guard !string.isEmpty else {
                throw MistError.missingListSearchString
            }

            !options.quiet ? PrettyPrint.print("List search string will be '\(string)'...") : Mist.noop()
        }

        !options.quiet ? PrettyPrint.print("Search only for latest (first) result will be '\(options.latest)'...") : Mist.noop()

        !options.quiet ? PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...") : Mist.noop()

        !options.quiet ? PrettyPrint.print("Only include compatible firmwares will be '\(options.compatible)'...") : Mist.noop()

        if let path: String = options.exportPath {

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            !options.quiet ? PrettyPrint.print("Export path will be '\(path)'...") : Mist.noop()

            let url: URL = URL(fileURLWithPath: path)

            guard ["csv", "json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            !options.quiet ? PrettyPrint.print("Export path file extension is valid...") : Mist.noop()
        }

        guard !options.metadataCachePath.isEmpty else {
            throw MistError.missingFirmwareMetadataCachePath
        }

        !options.quiet ? PrettyPrint.print("macOS Firmware metadata cache path will be '\(options.metadataCachePath)'...") : Mist.noop()

        !options.quiet ? PrettyPrint.print("Output type will be '\(options.outputType)'...") : Mist.noop()
    }

    /// Export the macOS downloads list.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///   - options:      List options for macOS Firmwares.
    ///
    /// - Throws: An `Error` if the dictionaries are unable to be written to disk.
    private static func export(_ dictionaries: [[String: Any]], options: ListFirmwareOptions) throws {

        guard let path: String = options.exportPath else {
            return
        }

        let url: URL = URL(fileURLWithPath: path)
        let directory: URL = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        switch url.pathExtension {
        case "csv":
            try dictionaries.firmwaresCSVString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as CSV: '\(path)'") : Mist.noop()
        case "json":
            try dictionaries.jsonString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as JSON: '\(path)'") : Mist.noop()
        case "plist":
            try dictionaries.propertyListString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as Property List: '\(path)'") : Mist.noop()
        case "yaml":
            try dictionaries.yamlString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as YAML: '\(path)'") : Mist.noop()
        default:
            break
        }
    }

    /// List the macOS downloads to standard output.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of dictionaries to be printed to standard output.
    ///   - options:      List options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if the list is unable to be printed to standard output.
    private static func list(_ dictionaries: [[String: Any]], options: ListFirmwareOptions) throws {

        switch options.outputType {
        case .ascii:
            print(dictionaries.firmwaresASCIIString())
        case .csv:
            print(dictionaries.firmwaresCSVString())
        case .json:
            try print(dictionaries.jsonString())
        case .plist:
            try print(dictionaries.propertyListString())
        case .yaml:
            try print(dictionaries.yamlString())
        }
    }

    mutating func run() {

        do {
            try ListFirmwareCommand.run(options: options)
        } catch {
            if let mistError: MistError = error as? MistError {
                PrettyPrint.print(mistError.description, prefix: .ending, prefixColor: .red)
            } else {
                PrettyPrint.print(error.localizedDescription, prefix: .ending, prefixColor: .red)
            }
        }
    }
}
