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

        PrettyPrint.print(string: "[LOOKUP]".color(.green))
        PrettyPrint.print(prefix: "├─", string: "Looking for macOS download '\(download)'...")
        let catalogURL: String = catalogURL ?? Catalog.defaultURL

        guard let product: Product = HTTP.product(from: HTTP.retrieveProducts(catalogURL: catalogURL), download: download) else {
            PrettyPrint.print(prefix: "└─", string: "No macOS download found with '\(download)', exiting...")
            exit(0)
        }

        PrettyPrint.print(prefix: "└─", string: "Found \(product.name) \(product.version) (\(product.build))")

        try verifyFreeSpace(product, settings: settings)
        try Downloader().download(product, settings: settings)
        try Installer.install(product, settings: settings)
        try Generator.generate(product, settings: settings)
    }

    private static func verifyFreeSpace(_ product: Product, settings: Settings) throws {

        let temporaryURL: URL = URL(fileURLWithPath: settings.temporaryDirectory)
        let outputURL: URL = URL(fileURLWithPath: settings.outputDirectory)

        if !FileManager.default.fileExists(atPath: temporaryURL.path) || !FileManager.default.fileExists(atPath: outputURL.path) {
            PrettyPrint.print(string: "[OUTPUT]".color(.green))
        }

        if !FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Creating temporary directory '\(temporaryURL.path)'...")
            try FileManager.default.createDirectory(atPath: settings.temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            PrettyPrint.print(prefix: "└─", string: "Creating output directory '\(outputURL.path)'...")
            try FileManager.default.createDirectory(atPath: settings.outputDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        guard let bootVolumePath: String = FileManager.default.componentsToDisplay(forPath: "/")?.first,
            let temporaryVolumePath: String = FileManager.default.componentsToDisplay(forPath: settings.temporaryDirectory)?.first,
            let outputVolumePath: String = FileManager.default.componentsToDisplay(forPath: settings.outputDirectory)?.first else {
            throw MistError.notEnoughFreeSpace(volume: "", free: -1, required: -1)
        }

        var volumes: [(path: String, count: Int64)] = []
        var bootVolume: (path: String, count: Int64) = (path: "/", count: 1)
        var temporaryVolume: (path: String, count: Int64) = (path: settings.temporaryDirectory, count: 1)
        var outputVolume: (path: String, count: Int64) = (path: settings.outputDirectory, count: 0)

        if temporaryVolumePath == bootVolumePath {
            bootVolume.count += 1
        }

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

            volumes.append(outputVolume)
        }

        volumes.insert(temporaryVolume, at: 0)
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
}
