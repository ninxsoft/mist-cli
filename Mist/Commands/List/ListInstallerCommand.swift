//
//  ListInstallerCommand.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import ArgumentParser
import Foundation

/// Struct used to perform **List Installer** operations.
struct ListInstallerCommand: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "installer",
        abstract: """
        List all macOS Installers available to download.
        * macOS Installers for macOS Catalina 10.15 and older are for Intel based Macs only.
        * macOS Installers for macOS Big Sur 11 and newer are Universal - for both Apple Silicon and Intel based Macs.
        """
    )
    @OptionGroup var options: ListInstallerOptions

    /// Searches and lists the macOS versions available for download, optionally exporting to a file.
    ///
    /// - Parameters:
    ///   - options: List options for macOS Installers.
    ///
    /// - Throws: A `MistError` if macOS versions fail to be retrieved or exported.
    static func run(options: ListInstallerOptions) throws {
        Mist.checkForNewVersion(noAnsi: options.noAnsi)
        try inputValidation(options)
        !options.quiet ? PrettyPrint.printHeader("SEARCH", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Searching for macOS Installer versions...", noAnsi: options.noAnsi) : Mist.noop()
        var catalogURLs: [String] = options.includeBetas ? Catalog.urls : [Catalog.standard.url]

        if let catalogURL: String = options.catalogURL {
            catalogURLs = [catalogURL]
        }

        var installers: [Installer] = HTTP.retrieveInstallers(from: catalogURLs, includeBetas: options.includeBetas, compatible: options.compatible, noAnsi: options.noAnsi, quiet: options.quiet)

        if let searchString: String = options.searchString {
            installers = HTTP.installers(from: installers, searchString: searchString)
        }

        if options.latest {
            if let installer: Installer = installers.first {
                installers = [installer]
            }
        }

        try export(installers.map(\.dictionary), options: options)
        !options.quiet ? PrettyPrint.print("Found \(installers.count) macOS Installer(s) available for download\n", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()

        if !installers.isEmpty {
            try list(installers.map(\.dictionary), options: options)
        }
    }

    /// Perform a series of validations on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: List options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidation(_ options: ListInstallerOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("INPUT VALIDATION", noAnsi: options.noAnsi) : Mist.noop()

        if let string: String = options.searchString {
            guard !string.isEmpty else {
                throw MistError.missingListSearchString
            }

            !options.quiet ? PrettyPrint.print("List search string will be '\(string)'...", noAnsi: options.noAnsi) : Mist.noop()
        }

        !options.quiet ? PrettyPrint.print("Search only for latest (first) result will be '\(options.latest)'...", noAnsi: options.noAnsi) : Mist.noop()

        !options.quiet ? PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...", noAnsi: options.noAnsi) : Mist.noop()

        !options.quiet ? PrettyPrint.print("Only include compatible installers will be '\(options.compatible)'...", noAnsi: options.noAnsi) : Mist.noop()

        if let path: String = options.exportPath {
            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            !options.quiet ? PrettyPrint.print("Export path will be '\(path)'...", noAnsi: options.noAnsi) : Mist.noop()

            let url: URL = URL(fileURLWithPath: path)

            guard ["csv", "json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            !options.quiet ? PrettyPrint.print("Export path file extension is valid...", noAnsi: options.noAnsi) : Mist.noop()
        }

        !options.quiet ? PrettyPrint.print("Output type will be '\(options.outputType)'...", noAnsi: options.noAnsi) : Mist.noop()
    }

    /// Export the macOS downloads list.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///   - options:      List options for macOS Installers.
    ///
    /// - Throws: An `Error` if the dictionaries are unable to be written to disk.
    private static func export(_ dictionaries: [[String: Any]], options: ListInstallerOptions) throws {
        guard let path: String = options.exportPath else {
            return
        }

        let url: URL = URL(fileURLWithPath: path)
        let directory: URL = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        switch url.pathExtension {
        case "csv":
            try dictionaries.installersCSVString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as CSV: '\(path)'", noAnsi: options.noAnsi) : Mist.noop()
        case "json":
            try dictionaries.jsonString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as JSON: '\(path)'", noAnsi: options.noAnsi) : Mist.noop()
        case "plist":
            try dictionaries.propertyListString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as Property List: '\(path)'", noAnsi: options.noAnsi) : Mist.noop()
        case "yaml":
            try dictionaries.yamlString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as YAML: '\(path)'", noAnsi: options.noAnsi) : Mist.noop()
        default:
            break
        }
    }

    /// List the macOS downloads to standard output.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of dictionaries to be printed to standard output.
    ///   - options:      List options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the list is unable to be printed to standard output.
    private static func list(_ dictionaries: [[String: Any]], options: ListInstallerOptions) throws {
        switch options.outputType {
        case .ascii:
            print(dictionaries.installersASCIIString(noAnsi: options.noAnsi))
        case .csv:
            print(dictionaries.installersCSVString())
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
            try ListInstallerCommand.run(options: options)
        } catch {
            if let mistError: MistError = error as? MistError {
                PrettyPrint.print(mistError.description, noAnsi: options.noAnsi, prefix: .ending, prefixColor: .red)
            } else {
                PrettyPrint.print(error.localizedDescription, noAnsi: options.noAnsi, prefix: .ending, prefixColor: .red)
            }
        }
    }
}
