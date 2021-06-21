//
//  Download.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Download {

    static func run(catalogURL: String?, download: String, settings: Settings) throws {

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        try sanityChecks(download, settings: settings)
        let catalogURL: String = catalogURL ?? Catalog.defaultURL
        PrettyPrint.printHeader("SEARCH")
        PrettyPrint.print(prefix: "├─", string: "Searching for macOS download '\(download)'...")

        guard let product: Product = HTTP.product(from: HTTP.retrieveProducts(catalogURL: catalogURL), download: download) else {
            PrettyPrint.print(prefix: "└─", string: "No macOS download found with '\(download)', exiting...")
            return
        }

        PrettyPrint.print(prefix: "└─", string: "Found [\(product.identifier)] \(product.name) \(product.version) (\(product.build)) [\(product.date)]")
        try setup(product, settings: settings)
        try verifyFreeSpace(product, settings: settings)
        try Downloader.download(product, settings: settings)
        try Installer.install(product, settings: settings)
        try Generator.generate(product, settings: settings)
        try teardown(product, settings: settings)
    }

    private static func sanityChecks(_ download: String, settings: Settings) throws {

        guard !download.isEmpty else {
            throw MistError.missingDownloadType
        }

        guard !settings.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        guard settings.image || settings.package else {
            throw MistError.missingOutputType
        }

        if settings.image {
            guard !settings.imageName.isEmpty else {
                throw MistError.missingImageName
            }

            if let identity: String = settings.imageSigningIdentity,
                identity.isEmpty {
                throw MistError.missingImageSigningIdentity
            }
        }

        if settings.package {
            guard !settings.packageName.isEmpty else {
                throw MistError.missingPackageName
            }

            guard !settings.packageIdentifier.isEmpty else {
                throw MistError.missingPackageIdentifier
            }

            if let identity: String = settings.packageSigningIdentity,
                identity.isEmpty {
                throw MistError.missingPackageSigningIdentity
            }
        }
    }

    private static func setup(_ product: Product, settings: Settings) throws {

        let outputURL: URL = URL(fileURLWithPath: settings.outputDirectory(for: product))
        let temporaryURL: URL = URL(fileURLWithPath: "\(settings.temporaryDirectory)/\(product.identifier)")

        if !FileManager.default.fileExists(atPath: outputURL.path) || !FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.printHeader("SETUP")
        }

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Creating output directory '\(outputURL.path)'...")
            try FileManager.default.createDirectory(atPath: outputURL.path, withIntermediateDirectories: true, attributes: nil)
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old temporary directory '\(temporaryURL.path)'...")
            try FileManager.default.removeItem(at: temporaryURL)
        }

        PrettyPrint.print(prefix: "├─", string: "Creating new temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)
    }

    private static func verifyFreeSpace(_ product: Product, settings: Settings) throws {

        let outputURL: URL = URL(fileURLWithPath: settings.outputDirectory(for: product))
        let temporaryURL: URL = URL(fileURLWithPath: settings.temporaryDirectory)

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
            for boolean in [settings.image, settings.package] where boolean {
                bootVolume.count += 1
            }
        } else if outputVolumePath == temporaryVolumePath {
            for boolean in [settings.image, settings.package] where boolean {
                temporaryVolume.count += 1
            }
        } else {
            for boolean in [settings.image, settings.package] where boolean {
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

    private static func teardown(_ product: Product, settings: Settings) throws {
        PrettyPrint.printHeader("TEARDOWN")
        PrettyPrint.print(prefix: "└─", string: "Deleting installer '\(product.installerURL.path)'...")
        try FileManager.default.removeItem(at: product.installerURL)
    }
}
