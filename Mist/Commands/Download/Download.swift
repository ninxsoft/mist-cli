//
//  Download.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

/// Struct used to perform **Download** operations.
struct Download {

    /// Searches for and downloads a particular macOS version.
    ///
    /// - Parameters:
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if a macOS version fails to download.
    static func run(options: DownloadOptions) throws {
        try inputValidation(options)
        PrettyPrint.printHeader("SEARCH")
        PrettyPrint.print("Searching for macOS download '\(options.searchString)'...")

        switch options.platform {
        case .apple:
            guard let firmware: Firmware = HTTP.firmware(from: HTTP.retrieveFirmwares(includeBetas: options.includeBetas), searchString: options.searchString) else {
                PrettyPrint.print("No macOS Firmware found with '\(options.searchString)', exiting...", prefix: .ending)
                return
            }

            PrettyPrint.print("Found \(firmware.name) \(firmware.version) (\(firmware.build)) [\(firmware.dateDescription)]")
            try verifyExistingFiles(firmware, options: options)
            try setup(firmware, options: options)
            try verifyFreeSpace(firmware, options: options)
            try Downloader().download(firmware, options: options)
            try Generator.generate(firmware, options: options)
            try teardown(firmware, options: options)
        case .intel:
            let catalogURL: String = options.catalogURL ?? Catalog.defaultURL

            guard let product: Product = HTTP.product(from: HTTP.retrieveProducts(catalogURL: catalogURL), searchString: options.searchString) else {
                PrettyPrint.print("No macOS Installer found with '\(options.searchString)', exiting...", prefix: .ending)
                return
            }

            PrettyPrint.print("Found [\(product.identifier)] \(product.name) \(product.version) (\(product.build)) [\(product.date)]")
            try verifyExistingFiles(product, options: options)
            try setup(product, options: options)
            try verifyFreeSpace(product, options: options)
            try Downloader().download(product, options: options)
            try Installer.install(product, options: options)
            try Generator.generate(product, options: options)
            try teardown(product, options: options)
        }
    }

    /// Performs a series of validations on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidation(_ options: DownloadOptions) throws {

        PrettyPrint.printHeader("INPUT VALIDATION")

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        PrettyPrint.print("User is 'root'...")

        guard !options.searchString.isEmpty else {
            throw MistError.missingDownloadSearchString
        }

        PrettyPrint.print("Download search string will be '\(options.searchString)'...")

        guard !options.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        PrettyPrint.print("Platform will be '\(options.platform)'...")
        PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...")
        PrettyPrint.print("Output directory will be '\(options.outputDirectory)'...")
        PrettyPrint.print("Temporary directory will be '\(options.temporaryDirectory)'...")

        if options.force {
            PrettyPrint.print("Force flag set, existing files will be overwritten...")
        } else {
            PrettyPrint.print("Force flag has not been set, existing files will not be overwritten...")
        }

        switch options.platform {
        case .apple:
            try inputValidationFirmware(options)
        case .intel:

            guard options.application || options.image || options.package else {
                throw MistError.missingOutputType
            }

            PrettyPrint.print("Valid download type(s) specified...")
            try inputValidationApplication(options)
            try inputValidationImage(options)
            try inputValidationPackage(options)
        }
    }

    /// Performs a series of input validations specific to macOS Firmware output.
    ///
    /// - Parameters:
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationFirmware(_ options: DownloadOptions) throws {

        guard !options.firmwareName.isEmpty else {
            throw MistError.missingFirmwareName
        }

        PrettyPrint.print("Firmware name will be '\(options.firmwareName)'...")
    }

    /// Performs a series of input validations specific to macOS Application output.
    ///
    /// - Parameters:
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationApplication(_ options: DownloadOptions) throws {

        if options.application {

            guard !options.applicationName.isEmpty else {
                throw MistError.missingApplicationName
            }

            PrettyPrint.print("Application name will be '\(options.applicationName)'...")
        }
    }

    /// Performs a series of input validations specific to macOS Disk Image output.
    ///
    /// - Parameters:
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationImage(_ options: DownloadOptions) throws {

        if options.image {

            guard !options.imageName.isEmpty else {
                throw MistError.missingImageName
            }

            PrettyPrint.print("Disk Image name will be '\(options.imageName)'...")

            if let identity: String = options.imageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingImageSigningIdentity
                }

                PrettyPrint.print("Disk Image signing identity will be '\(identity)'...")
            }
        }
    }

    /// Performs a series of input validations specific to macOS Installer Package output.
    ///
    /// - Parameters:
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationPackage(_ options: DownloadOptions) throws {

        if options.package {

            guard !options.packageName.isEmpty else {
                throw MistError.missingPackageName
            }

            PrettyPrint.print("Package name will be '\(options.packageName)'...")

            guard let identifier: String = options.packageIdentifier,
                !identifier.isEmpty else {
                throw MistError.missingPackageIdentifier
            }

            PrettyPrint.print("Package identifier will be '\(identifier)'...")

            if let identity: String = options.packageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingPackageSigningIdentity
                }

                PrettyPrint.print("Package signing identity will be '\(identity)'...")
            }
        }
    }

    /// Verifies if macOS Firmware files already exist.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
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
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
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
    ///   - options:  Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func setup(_ firmware: Firmware, options: DownloadOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: options.outputDirectory(for: firmware))
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        PrettyPrint.printHeader("SETUP")

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            PrettyPrint.print("Creating output directory '\(outputURL.path)'...")
            try FileManager.default.createDirectory(atPath: outputURL.path, withIntermediateDirectories: true, attributes: nil)
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...")
            try FileManager.default.removeItem(at: temporaryURL)
        }

        PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)
    }

    /// Sets up directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer to be downloaded.
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func setup(_ product: Product, options: DownloadOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: options.outputDirectory(for: product))
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))

        PrettyPrint.printHeader("SETUP")

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            PrettyPrint.print("Creating output directory '\(outputURL.path)'...")
            try FileManager.default.createDirectory(atPath: outputURL.path, withIntermediateDirectories: true, attributes: nil)
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...")
            try FileManager.default.removeItem(at: temporaryURL)
        }

        PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)
    }

    /// Verifies free space for macOS Firmware downloads.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
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
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
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
            for boolean in [options.application, options.image, options.package] where boolean {
                bootVolume.count += 1
            }
        } else if outputVolumePath == temporaryVolumePath {
            for boolean in [options.application, options.image, options.package] where boolean {
                temporaryVolume.count += 1
            }
        } else {
            for boolean in [options.application, options.image, options.package] where boolean {
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
    ///   - options:  Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func teardown(_ firmware: Firmware, options: DownloadOptions) throws {

        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.printHeader("TEARDOWN")
            PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", prefix: .ending)
            try FileManager.default.removeItem(at: temporaryURL)
        }
    }

    /// Tears down temporary directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func teardown(_ product: Product, options: DownloadOptions) throws {
        PrettyPrint.printHeader("TEARDOWN")
        PrettyPrint.print("Deleting installer '\(product.installerURL.path)'...", prefix: .ending)
        try FileManager.default.removeItem(at: product.installerURL)
    }
}
