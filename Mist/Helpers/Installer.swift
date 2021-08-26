//
//  Installer.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Installer {

    static func install(_ product: Product, options: DownloadOptions) throws {

        guard let url: URL = URL(string: product.distribution) else {
            throw MistError.invalidURL(url: product.distribution)
        }

        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

        PrettyPrint.printHeader("INSTALL")

        if FileManager.default.fileExists(atPath: product.installerURL.path) {
            PrettyPrint.print("Deleting old installer '\(product.installerURL.path)'...")
            try FileManager.default.removeItem(at: product.installerURL)
        }

        PrettyPrint.print("Creating new installer '\(product.installerURL.path)'...")
        let arguments: [String] = ["installer", "-pkg", distributionURL.path, "-target", "/"]
        let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
        try Shell.execute(arguments, environment: variables)
        PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.removeItem(at: temporaryURL)
        PrettyPrint.print("Created new installer '\(product.installerURL.path)'")
    }
}
