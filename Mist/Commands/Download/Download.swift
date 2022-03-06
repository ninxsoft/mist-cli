//
//  Download.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Struct used to perform **Download** operations.
struct Download {

    /// Searches for and downloads a particular macOS version.
    ///
    /// - Parameters:
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if a macOS version fails to download.
    static func run(options: DownloadOptions) throws {
        try inputValidation(options)
        !options.quiet ? PrettyPrint.printHeader("SEARCH") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Searching for macOS download '\(options.searchString)'...") : Mist.noop()

        switch options.kind {
        case .firmware, .ipsw:
            guard let firmware: Firmware = HTTP.firmware(from: HTTP.retrieveFirmwares(includeBetas: options.includeBetas), searchString: options.searchString) else {
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
        case .app, .installer:
            var catalogURLs: [String] = Catalog.urls

            if let catalogURL: String = options.catalogURL {
                catalogURLs = [catalogURL]
            }

            let retrievedProducts: [Product] = HTTP.retrieveProducts(from: catalogURLs, includeBetas: options.includeBetas)

            guard let product: Product = HTTP.product(from: retrievedProducts, searchString: options.searchString) else {
                !options.quiet ? PrettyPrint.print("No macOS Installer found with '\(options.searchString)', exiting...", prefix: .ending) : Mist.noop()
                return
            }

            !options.quiet ? PrettyPrint.print("Found [\(product.identifier)] \(product.name) \(product.version) (\(product.build)) [\(product.date)]") : Mist.noop()
            try verifyExistingFiles(product, options: options)
            try setup(product, options: options)
            try verifyFreeSpace(product, options: options)
            try Downloader().download(product, options: options)
            try Installer.install(product, options: options)
            try Generator.generate(product, options: options)
            try teardown(product, options: options)
            try export(product, options: options)
        }
    }

    /// Performs a series of validations on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidation(_ options: DownloadOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("INPUT VALIDATION") : Mist.noop()

        if [.app, .installer].contains(options.kind) {

            guard NSUserName() == "root" else {
                throw MistError.invalidUser
            }

            !options.quiet ? PrettyPrint.print("User is 'root'...") : Mist.noop()
        }

        guard !options.searchString.isEmpty else {
            throw MistError.missingDownloadSearchString
        }

        !options.quiet ? PrettyPrint.print("Download search string will be '\(options.searchString)'...") : Mist.noop()

        guard !options.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        !options.quiet ? PrettyPrint.print("Kind will be '\(options.kind)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...") : Mist.noop()
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

        switch options.kind {
        case .firmware, .ipsw:
            try inputValidationFirmware(options)
        case .app, .installer:

            guard options.application || options.image || options.iso || options.package else {
                throw MistError.missingOutputType
            }

            !options.quiet ? PrettyPrint.print("Valid download type(s) specified...") : Mist.noop()
            try inputValidationApplication(options)
            try inputValidationImage(options)
            try inputValidationISO(options)
            try inputValidationPackage(options)
        }
    }

    /// Performs a series of input validations specific to macOS Firmware output.
    ///
    /// - Parameters:
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationFirmware(_ options: DownloadOptions) throws {

        guard !options.firmwareName.isEmpty else {
            throw MistError.missingFirmwareName
        }

        !options.quiet ? PrettyPrint.print("Firmware name will be '\(options.firmwareName)'...") : Mist.noop()
    }

    /// Performs a series of input validations specific to macOS Application output.
    ///
    /// - Parameters:
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationApplication(_ options: DownloadOptions) throws {

        if options.application {

            guard !options.applicationName.isEmpty else {
                throw MistError.missingApplicationName
            }

            !options.quiet ? PrettyPrint.print("Application name will be '\(options.applicationName)'...") : Mist.noop()
        }
    }

    /// Performs a series of input validations specific to macOS Disk Image output.
    ///
    /// - Parameters:
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationImage(_ options: DownloadOptions) throws {

        if options.image {

            guard !options.imageName.isEmpty else {
                throw MistError.missingImageName
            }

            !options.quiet ? PrettyPrint.print("Disk Image name will be '\(options.imageName)'...") : Mist.noop()

            if let identity: String = options.imageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingImageSigningIdentity
                }

                !options.quiet ? PrettyPrint.print("Disk Image signing identity will be '\(identity)'...") : Mist.noop()
            }
        }
    }

    /// Performs a series of input validations specific to Bootable macOS Disk Image output.
    ///
    /// - Parameters:
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationISO(_ options: DownloadOptions) throws {

        if options.iso {

            guard !options.isoName.isEmpty else {
                throw MistError.missingIsoName
            }

            !options.quiet ? PrettyPrint.print("Bootable Disk Image name will be '\(options.isoName)'...") : Mist.noop()
        }
    }

    /// Performs a series of input validations specific to macOS Installer Package output.
    ///
    /// - Parameters:
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**)as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationPackage(_ options: DownloadOptions) throws {

        if options.package {

            guard !options.packageName.isEmpty else {
                throw MistError.missingPackageName
            }

            !options.quiet ? PrettyPrint.print("Package name will be '\(options.packageName)'...") : Mist.noop()

            guard let identifier: String = options.packageIdentifier,
                !identifier.isEmpty else {
                throw MistError.missingPackageIdentifier
            }

            !options.quiet ? PrettyPrint.print("Package identifier will be '\(identifier)'...") : Mist.noop()

            if let identity: String = options.packageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingPackageSigningIdentity
                }

                !options.quiet ? PrettyPrint.print("Package signing identity will be '\(identity)'...") : Mist.noop()
            }
        }
    }

    /// Verifies if macOS Firmware files already exist.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if an existing file is found.
    private static func verifyExistingFiles(_ firmware: Firmware, options: DownloadOptions) throws {

        guard !options.force else {
            return
        }

        let path: String = options.firmwarePath(for: firmware)

        guard !FileManager.default.fileExists(atPath: path) else {
            throw MistError.existingFile(path: path)
        }
    }

    /// Verifies if macOS Installer files already exist.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer to be downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if an existing file is found.
    private static func verifyExistingFiles(_ product: Product, options: DownloadOptions) throws {

        guard !options.force else {
            return
        }

        if options.application {
            let path: String = options.applicationPath(for: product)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.image {
            let path: String = options.imagePath(for: product)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.iso {
            let path: String = options.isoPath(for: product)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.package {
            let path: String = options.packagePath(for: product)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }
    }

    /// Sets up directory structure for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func setup(_ firmware: Firmware, options: DownloadOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: options.outputDirectory(for: firmware))
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

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

    /// Sets up directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer to be downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func setup(_ product: Product, options: DownloadOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: options.outputDirectory(for: product))
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))

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
    ///   - options:  Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if there is not enough free space.
    private static func verifyFreeSpace(_ firmware: Firmware, options: DownloadOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: options.outputDirectory(for: firmware))
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

    /// Verifies free space for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer to be downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if there is not enough free space.
    private static func verifyFreeSpace(_ product: Product, options: DownloadOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: options.outputDirectory(for: product))
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory)

        guard let bootVolumePath: String = FileManager.default.componentsToDisplay(forPath: "/")?.first,
            let temporaryVolumePath: String = FileManager.default.componentsToDisplay(forPath: temporaryURL.path)?.first,
            let outputVolumePath: String = FileManager.default.componentsToDisplay(forPath: outputURL.path)?.first else {
            throw MistError.notEnoughFreeSpace(volume: "", free: -1, required: -1)
        }

        var volumes: [(path: String, count: Int64)] = []
        var bootVolume: (path: String, count: Int64) = (path: "/", count: 1)
        var temporaryVolume: (path: String, count: Int64) = (path: temporaryURL.path, count: 1)
        var outputVolume: (path: String, count: Int64) = (path: outputURL.path, count: 0)

        if outputVolumePath == bootVolumePath {
            for boolean in [options.application, options.image, options.iso, options.package] where boolean {
                bootVolume.count += 1
            }
        } else if outputVolumePath == temporaryVolumePath {
            for boolean in [options.application, options.image, options.iso, options.package] where boolean {
                temporaryVolume.count += 1
            }
        } else {
            for boolean in [options.application, options.image, options.iso, options.package] where boolean {
                outputVolume.count += 1
            }

            volumes.insert(outputVolume, at: 0)
        }

        if temporaryVolumePath == bootVolumePath {
            bootVolume.count += 1
        } else {
            volumes.insert(temporaryVolume, at: 0)
        }

        volumes.insert(bootVolume, at: 0)

        for volume in volumes {

            guard let attributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfFileSystem(forPath: volume.path),
                let number: NSNumber = attributes[.systemFreeSize] as? NSNumber else {
                throw MistError.notEnoughFreeSpace(volume: "", free: -1, required: -1)
            }

            let required: Int64 = product.size * volume.count
            let free: Int64 = number.int64Value

            guard required < free else {
                throw MistError.notEnoughFreeSpace(volume: volume.path, free: free, required: required)
            }
        }
    }

    /// Tears down temporary directory structure for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func teardown(_ firmware: Firmware, options: DownloadOptions) throws {

        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.printHeader("TEARDOWN") : Mist.noop()
            !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", prefix: .ending) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }
    }

    /// Tears down temporary directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func teardown(_ product: Product, options: DownloadOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("TEARDOWN") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Deleting installer '\(product.installerURL.path)'...", prefix: .ending) : Mist.noop()
        try FileManager.default.removeItem(at: product.installerURL)
    }

    /// Exports the results for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func export(_ firmware: Firmware, options: DownloadOptions) throws {

        guard let path: String = options.exportPath else {
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
            "options": options.exportDictionary(for: firmware)
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

    /// Exports the results for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func export(_ product: Product, options: DownloadOptions) throws {

        guard let path: String = options.exportPath else {
            return
        }

        let url: URL = URL(fileURLWithPath: path)
        let directory: URL = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        let dictionary: [String: Any] = [
            "installer": product.exportDictionary,
            "options": options.exportDictionary(for: product)
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
}
