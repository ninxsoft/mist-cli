//
//  Download.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Download {

    static func run(name: String, version: String, build: String, settings: Settings) throws {

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        guard settings.image || settings.package else {
            throw MistError.invalidOutputOption
        }

        PrettyPrint.print(.info, string: "Checking for macOS with name '\(name)', version '\(version)' and build '\(build)'...")

        guard let product: Product = HTTP.product(from: HTTP.retrieveProducts(), name: name, version: version, build: build) else {
            PrettyPrint.print(.warning, string: "No macOS found with name '\(name)', version '\(version)' and build '\(build)', exiting...")
            return
        }

        PrettyPrint.print(.info, string: "Found \(product.name) \(product.version) (\(product.build))...")
        try Downloader.download(product)
        try Installer.install(product)
        try Generator.generate(product, settings: settings)
    }
}
