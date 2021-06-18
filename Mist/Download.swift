//
//  Download.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Download {

    static func run(catalog: Catalog, download: String, settings: Settings) throws {

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        }

        if settings.package {
            guard let prefix: String = settings.packageIdentifierPrefix,
                !prefix.isEmpty else {
                throw MistError.missingPackageIdentifierPrefix
            }
        }

        PrettyPrint.print(.info, string: "Checking for macOS download '\(download)'...")

        guard let product: Product = HTTP.product(from: HTTP.retrieveProducts(catalog), download: download) else {
            PrettyPrint.print(.warning, string: "No macOS download found with '\(download)', exiting...")
            return
        }

        PrettyPrint.print(.success, string: "Found \(product.name) \(product.version) (\(product.build))...")

        try verifyFreeSpace(product, settings: settings)
        try Downloader().download(product, settings: settings)
        try Installer.install(product, settings: settings)
        try Generator.generate(product, settings: settings)
    }

    private static func verifyFreeSpace(_ product: Product, settings: Settings) throws {

        var volumes: [(path: String, count: Int64)] = []

        guard let bootVolumePath: String = FileManager.default.componentsToDisplay(forPath: "/")?.first,
            let temporaryVolumePath: String = FileManager.default.componentsToDisplay(forPath: settings.temporaryDirectory)?.first,
            let outputVolumePath: String = FileManager.default.componentsToDisplay(forPath: settings.outputDirectory)?.first else {
            throw MistError.notEnoughFreeSpace(volume: "", free: -1, required: -1)
        }

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
