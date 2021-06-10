//
//  Download.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Download {

    static func run(catalog: Catalog, version: String, build: String, settings: Settings) throws {

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        guard settings.application || settings.image || settings.package || settings.zip else {
            throw MistError.invalidOutputOption
        }

        PrettyPrint.print(.info, string: "Checking for macOS with version '\(version)' and build '\(build)'...")

        guard let product: Product = HTTP.product(from: HTTP.retrieveProducts(catalog), version: version, build: build) else {
            PrettyPrint.print(.warning, string: "No macOS found with version '\(version)' and build '\(build)', exiting...")
            return
        }

        PrettyPrint.print(.info, string: "Found \(product.name) \(product.version) (\(product.build))...")

        try verifyFreeSpace(product, settings: settings)
        try Downloader().download(product, settings: settings)
        try Installer.install(product, settings: settings)
        try Generator.generate(product, settings: settings)
    }

    private static func verifyFreeSpace(_ product: Product, settings: Settings) throws {

        guard let attributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfFileSystem(forPath: "/"),
            let number: NSNumber = attributes[.systemFreeSize] as? NSNumber else {
            throw MistError.notEnoughFreeSpace(free: -1, required: -1)
        }

        let free: Int64 = number.int64Value

        // one for the downloads and one for the macos installer application bundle
        var required: Int64 = product.size + product.size

        if settings.application {
            required += product.size
        }

        if settings.image {
            required += product.size
        }

        if settings.package {
            required += product.size
        }

        if settings.zip {
            required += product.size
        }

        guard required < free else {
            throw MistError.notEnoughFreeSpace(free: free, required: required)
        }
    }
}
