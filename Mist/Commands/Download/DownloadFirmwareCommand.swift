//
//  DownloadFirmwareCommand.swift
//  Mist
//
//  Created by Nindi Gill on 30/5/2022.
//

import ArgumentParser
import Foundation

/// Struct used to perform **Download Firmware** operations.
struct DownloadFirmwareCommand: ParsableCommand {

    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "firmware",
        abstract: """
        Download a macOS Firmware.
        * macOS Firmwares are for Apple Silicon Macs only.
        """
    )
    @OptionGroup var options: DownloadFirmwareOptions

    /// Searches for and downloads a particular macOS version.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if a macOS version fails to download.
    static func run(options: DownloadFirmwareOptions) throws {
        try inputValidation(options)
        !options.quiet ? PrettyPrint.printHeader("SEARCH") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Searching for macOS download '\(options.searchString)'...") : Mist.noop()

        guard let firmware: Firmware = HTTP.firmware(from: HTTP.retrieveFirmwares(includeBetas: options.includeBetas, compatible: options.compatible), searchString: options.searchString) else {
            !options.quiet ? PrettyPrint.print("No macOS Firmware found with '\(options.searchString)', exiting...", prefix: .ending) : Mist.noop()
            return
        }

        !options.quiet ? PrettyPrint.print("Found \(firmware.name) \(firmware.version) (\(firmware.build)) [\(firmware.dateDescription)]") : Mist.noop()
        try verifyExistingFiles(firmware, options: options)
        try setup(firmware, options: options)
        try verifyFreeSpace(firmware, options: options)
        try Downloader().download(firmware, options: options)
        try Generator.generate(firmware, options: options)
        try teardown(firmware, options: options)
        try export(firmware, options: options)
    }

    /// Performs a series of validations on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidation(_ options: DownloadFirmwareOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("INPUT VALIDATION") : Mist.noop()

        guard !options.searchString.isEmpty else {
            throw MistError.missingDownloadSearchString
        }

        !options.quiet ? PrettyPrint.print("Download search string will be '\(options.searchString)'...") : Mist.noop()

        guard !options.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        !options.quiet ? PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Only include compatible firmwares will be '\(options.compatible)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Output directory will be '\(options.outputDirectory)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Temporary directory will be '\(options.temporaryDirectory)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Force flag\(options.force ? " " : " has not been ")set, existing files will\(options.force ? " " : " not ")be overwritten...") : Mist.noop()

        if let path: String = options.exportPath {

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            !options.quiet ? PrettyPrint.print("Export path will be '\(path)'...") : Mist.noop()

            let url: URL = URL(fileURLWithPath: path)

            guard ["json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            !options.quiet ? PrettyPrint.print("Export path file extension is valid...") : Mist.noop()
        }

        try inputValidationFirmware(options)
    }

    /// Performs a series of input validations specific to macOS Firmware output.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationFirmware(_ options: DownloadFirmwareOptions) throws {

        guard !options.firmwareName.isEmpty else {
            throw MistError.missingFirmwareName
        }

        !options.quiet ? PrettyPrint.print("Firmware name will be '\(options.firmwareName)'...") : Mist.noop()
    }

    /// Verifies if macOS Firmware files already exist.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if an existing file is found.
    private static func verifyExistingFiles(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {

        guard !options.force else {
            return
        }

        let path: String = firmwarePath(for: firmware, options: options)

        guard !FileManager.default.fileExists(atPath: path) else {
            throw MistError.existingFile(path: path)
        }
    }

    /// Sets up directory structure for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func setup(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: outputDirectory(for: firmware, options: options))
        let temporaryURL: URL = URL(fileURLWithPath: temporaryDirectory(for: firmware, options: options))

        !options.quiet ? PrettyPrint.printHeader("SETUP") : Mist.noop()

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            !options.quiet ? PrettyPrint.print("Creating output directory '\(outputURL.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(atPath: outputURL.path, withIntermediateDirectories: true, attributes: nil)
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)
    }

    /// Verifies free space for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if there is not enough free space.
    private static func verifyFreeSpace(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: outputDirectory(for: firmware, options: options))
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory)

        for path in [outputURL.path, temporaryURL.path] {

            guard let attributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfFileSystem(forPath: path),
                let number: NSNumber = attributes[.systemFreeSize] as? NSNumber else {
                throw MistError.notEnoughFreeSpace(volume: "", free: -1, required: -1)
            }

            let required: Int64 = firmware.size
            let free: Int64 = number.int64Value

            guard required < free else {
                throw MistError.notEnoughFreeSpace(volume: path, free: free, required: required)
            }
        }
    }

    /// Tears down temporary directory structure for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func teardown(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {

        let temporaryURL: URL = URL(fileURLWithPath: temporaryDirectory(for: firmware, options: options))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.printHeader("TEARDOWN") : Mist.noop()
            !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", prefix: .ending) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }
    }

    /// Exports the results for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func export(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {

        guard let path: String = exportPath(for: firmware, options: options) else {
            return
        }

        let url: URL = URL(fileURLWithPath: path)
        let directory: URL = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        let dictionary: [String: Any] = [
            "firmware": firmware.exportDictionary,
            "options": exportDictionary(for: firmware, options: options)
        ]

        switch url.pathExtension {
        case "json":
            try dictionary.jsonString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as JSON: '\(path)'") : Mist.noop()
        case "plist":
            try dictionary.propertyListString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as Property List: '\(path)'") : Mist.noop()
        case "yaml":
            try dictionary.yamlString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as YAML: '\(path)'") : Mist.noop()
        default:
            break
        }
    }

    private static func exportDictionary(for firmware: Firmware, options: DownloadFirmwareOptions) -> [String: Any] {
        [
            "includeBetas": options.includeBetas,
            "force": options.force,
            "firmwarePath": firmwarePath(for: firmware, options: options),
            "outputDirectory": outputDirectory(for: firmware, options: options),
            "temporaryDirectory": temporaryDirectory(for: firmware, options: options),
            "exportPath": exportPath(for: firmware, options: options) ?? "",
            "quiet": options.quiet
        ]
    }

    private static func exportPath(for firmware: Firmware, options: DownloadFirmwareOptions) -> String? {

        guard let path: String = options.exportPath else {
            return nil
        }

        return path.stringWithSubstitutions(using: firmware)
    }

    static func firmwarePath(for firmware: Firmware, options: DownloadFirmwareOptions) -> String {
        "\(options.outputDirectory)/\(options.firmwareName)".stringWithSubstitutions(using: firmware)
    }

    private static func outputDirectory(for firmware: Firmware, options: DownloadFirmwareOptions) -> String {
        options.outputDirectory.stringWithSubstitutions(using: firmware)
    }

    static func temporaryDirectory(for firmware: Firmware, options: DownloadFirmwareOptions) -> String {
        "\(options.temporaryDirectory)/\(firmware.identifier)".replacingOccurrences(of: "//", with: "/")
    }

    mutating func run() {

        do {
            try DownloadFirmwareCommand.run(options: options)
        } catch {
            if let mistError: MistError = error as? MistError {
                PrettyPrint.print(mistError.description, prefix: .ending, prefixColor: .red)
            } else {
                PrettyPrint.print(error.localizedDescription, prefix: .ending, prefixColor: .red)
            }
        }
    }
}
