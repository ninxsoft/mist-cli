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
        !options.quiet ? PrettyPrint.printHeader("SEARCH", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Searching for macOS download '\(options.searchString)'...", noAnsi: options.noAnsi) : Mist.noop()

        guard let firmware: Firmware = HTTP.firmware(
            from: HTTP.retrieveFirmwares(includeBetas: options.includeBetas, compatible: options.compatible, metadataCachePath: options.metadataCachePath, noAnsi: options.noAnsi),
            searchString: options.searchString
        ) else {
            !options.quiet ? PrettyPrint.print("No macOS Firmware found with '\(options.searchString)', exiting...", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()
            return
        }

        !options.quiet ? PrettyPrint.print("Found \(firmware.name) \(firmware.version) (\(firmware.build)) [\(firmware.dateDescription)]", noAnsi: options.noAnsi) : Mist.noop()
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

        !options.quiet ? PrettyPrint.printHeader("INPUT VALIDATION", noAnsi: options.noAnsi) : Mist.noop()

        guard !options.searchString.isEmpty else {
            throw MistError.missingDownloadSearchString
        }

        !options.quiet ? PrettyPrint.print("Download search string will be '\(options.searchString)'...", noAnsi: options.noAnsi) : Mist.noop()

        guard !options.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        !options.quiet ? PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Only include compatible firmwares will be '\(options.compatible)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Cache downloads will be '\(options.cacheDownloads)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Output directory will be '\(options.outputDirectory)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Temporary directory will be '\(options.temporaryDirectory)'...", noAnsi: options.noAnsi) : Mist.noop()
        let string: String = "Force flag\(options.force ? " " : " has not been ")set, existing files will\(options.force ? " " : " not ")be overwritten..."
        !options.quiet ? PrettyPrint.print(string, noAnsi: options.noAnsi) : Mist.noop()

        if let path: String = options.exportPath {

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            !options.quiet ? PrettyPrint.print("Export path will be '\(path)'...", noAnsi: options.noAnsi) : Mist.noop()

            let url: URL = URL(fileURLWithPath: path)

            guard ["json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            !options.quiet ? PrettyPrint.print("Export path file extension is valid...", noAnsi: options.noAnsi) : Mist.noop()
        }

        guard !options.metadataCachePath.isEmpty else {
            throw MistError.missingFirmwareMetadataCachePath
        }

        !options.quiet ? PrettyPrint.print("macOS Firmware metadata cache path will be '\(options.metadataCachePath)'...", noAnsi: options.noAnsi) : Mist.noop()

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

        !options.quiet ? PrettyPrint.print("Firmware name will be '\(options.firmwareName)'...", noAnsi: options.noAnsi) : Mist.noop()
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
        var processing: Bool = false

        !options.quiet ? PrettyPrint.printHeader("SETUP", noAnsi: options.noAnsi) : Mist.noop()

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            !options.quiet ? PrettyPrint.print("Creating output directory '\(outputURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.createDirectory(atPath: outputURL.path, withIntermediateDirectories: true, attributes: nil)
            processing = true
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) && !options.cacheDownloads {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
            processing = true
        }

        if !FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)
            processing = true
        }

        if !processing {
            !options.quiet ? PrettyPrint.print("Nothing to do!", noAnsi: options.noAnsi) : Mist.noop()
        }
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
        let required: Int64 = firmware.size

        for url in [outputURL, temporaryURL] {
            let values: URLResourceValues = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeAvailableCapacityKey])
            let free: Int64

            if let volumeAvailableCapacityForImportantUsage: Int64 = values.volumeAvailableCapacityForImportantUsage {
                free = volumeAvailableCapacityForImportantUsage
            } else if let volumeAvailableCapacity: Int = values.volumeAvailableCapacity {
                free = Int64(volumeAvailableCapacity)
            } else {
                throw MistError.notEnoughFreeSpace(volume: url.path, free: 0, required: required)
            }

            guard required < free else {
                throw MistError.notEnoughFreeSpace(volume: url.path, free: free, required: required)
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
        !options.quiet ? PrettyPrint.printHeader("TEARDOWN", noAnsi: options.noAnsi) : Mist.noop()

        if FileManager.default.fileExists(atPath: temporaryURL.path) && !options.cacheDownloads {
            !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        } else {
            !options.quiet ? PrettyPrint.print("Nothing to do!", noAnsi: options.noAnsi, prefix: options.exportPath != nil ? .default : .ending) : Mist.noop()
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
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        let dictionary: [String: Any] = [
            "firmware": firmware.exportDictionary,
            "options": exportDictionary(for: firmware, options: options)
        ]

        switch url.pathExtension {
        case "json":
            try dictionary.jsonString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as JSON: '\(path)'", noAnsi: options.noAnsi) : Mist.noop()
        case "plist":
            try dictionary.propertyListString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as Property List: '\(path)'", noAnsi: options.noAnsi) : Mist.noop()
        case "yaml":
            try dictionary.yamlString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as YAML: '\(path)'", noAnsi: options.noAnsi) : Mist.noop()
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

    static func resumeDataURL(for firmware: Firmware, options: DownloadFirmwareOptions) -> URL {
        let temporaryDirectory: String = temporaryDirectory(for: firmware, options: options)
        let string: String = "\(temporaryDirectory)/\(firmware.filename).resumeData"
        let url: URL = URL(fileURLWithPath: string)
        return url
    }

    mutating func run() {

        do {
            try DownloadFirmwareCommand.run(options: options)
        } catch {
            if let mistError: MistError = error as? MistError {
                PrettyPrint.print(mistError.description, noAnsi: options.noAnsi, prefix: .ending, prefixColor: .red)
            } else {
                PrettyPrint.print(error.localizedDescription, noAnsi: options.noAnsi, prefix: .ending, prefixColor: .red)
            }
        }
    }
}
