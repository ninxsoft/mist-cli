//
//  Download.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Download {

    static func run(options: DownloadOptions) throws {
        try sanityChecks(options)
        PrettyPrint.printHeader("SEARCH")
        PrettyPrint.print("Searching for macOS download '\(options.download)'...")

        switch options.platform {
        case .apple:
            guard let firmware: Firmware = HTTP.firmware(from: HTTP.retrieveFirmwares(), download: options.download) else {
                PrettyPrint.print(prefix: "  └─", "No macOS Firmware found with '\(options.download)', exiting...")
                return
            }

            PrettyPrint.print("Found \(firmware.name) \(firmware.version) (\(firmware.build)) [\(firmware.dateDescription)]")
            try setup(firmware, options: options)
            try verifyFreeSpace(firmware, options: options)
            try Downloader.download(firmware, options: options)
            try Generator.generate(firmware, options: options)
            try teardown(firmware, options: options)
        case .intel:
            let catalogURL: String = options.catalogURL ?? Catalog.defaultURL

            guard let product: Product = HTTP.product(from: HTTP.retrieveProducts(catalogURL: catalogURL), download: options.download) else {
                PrettyPrint.print(prefix: "  └─", "No macOS Installer found with '\(options.download)', exiting...")
                return
            }

            PrettyPrint.print("Found [\(product.identifier)] \(product.name) \(product.version) (\(product.build)) [\(product.date)]")
            try setup(product, options: options)
            try verifyFreeSpace(product, options: options)
            try Downloader.download(product, options: options)
            try Installer.install(product, options: options)
            try Generator.generate(product, options: options)
            try teardown(product, options: options)
        }
    }

    private static func sanityChecks(_ options: DownloadOptions) throws {

        PrettyPrint.printHeader("SANITY CHECKS")

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        PrettyPrint.print("User is 'root'...")

        guard !options.download.isEmpty else {
            throw MistError.missingDownloadType
        }

        PrettyPrint.print("Download type is '\(options.download)'...")

        guard !options.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        PrettyPrint.print("Output directory is '\(options.outputDirectory)'...")
        PrettyPrint.print("Temporary directory is '\(options.temporaryDirectory)'...")

        switch options.platform {
        case .apple:
            guard !options.firmwareName.isEmpty else {
                throw MistError.missingFirmwareName
            }

            PrettyPrint.print("Firmware name is '\(options.firmwareName)'...")
        case .intel:

            guard options.application || options.image || options.package else {
                throw MistError.missingOutputType
            }

            PrettyPrint.print("Valid download type(s) specified...")

            if options.application {
                guard !options.applicationName.isEmpty else {
                    throw MistError.missingApplicationName
                }

                PrettyPrint.print("Application name is '\(options.applicationName)'...")
            }

            if options.image {
                guard !options.imageName.isEmpty else {
                    throw MistError.missingImageName
                }

                PrettyPrint.print("Disk Image name is '\(options.imageName)'...")

                if let identity: String = options.imageSigningIdentity {

                    guard !identity.isEmpty else {
                        throw MistError.missingImageSigningIdentity
                    }

                    PrettyPrint.print("Disk Image signing identity is '\(identity)'...")
                }
            }

            if options.package {
                guard !options.packageName.isEmpty else {
                    throw MistError.missingPackageName
                }

                PrettyPrint.print("Package name is '\(options.packageName)'...")

                guard let identifier: String = options.packageIdentifier,
                    !identifier.isEmpty else {
                    throw MistError.missingPackageIdentifier
                }

                PrettyPrint.print("Package identifier is '\(identifier)'...")

                if let identity: String = options.packageSigningIdentity {

                    guard !identity.isEmpty else {
                        throw MistError.missingPackageSigningIdentity
                    }

                    PrettyPrint.print("Package signing identity is '\(identity)'...")
                }
            }
        }
    }

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

    private static func teardown(_ firmware: Firmware, options: DownloadOptions) throws {

        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.printHeader("TEARDOWN")
            PrettyPrint.print(prefix: "  └─", "Deleting temporary directory '\(temporaryURL.path)'...")
            try FileManager.default.removeItem(at: temporaryURL)
        }
    }

    private static func teardown(_ product: Product, options: DownloadOptions) throws {
        PrettyPrint.printHeader("TEARDOWN")
        PrettyPrint.print(prefix: "  └─", "Deleting installer '\(product.installerURL.path)'...")
        try FileManager.default.removeItem(at: product.installerURL)
    }
}
