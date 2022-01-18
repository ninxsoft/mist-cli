//
//  Installer.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Struct used to install macOS Installers.
struct Installer {

    /// Installs a recently downloaded macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the downloaded macOS Installer fails to install.
    static func install(_ product: Product, options: DownloadOptions) throws {

        guard let url: URL = URL(string: product.distribution) else {
            throw MistError.invalidURL(url: product.distribution)
        }

        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

        PrettyPrint.printHeader("INSTALL",structuredOutput: options.structuredOutput)

        if FileManager.default.fileExists(atPath: product.installerURL.path) {
            PrettyPrint.print("Deleting old installer '\(product.installerURL.path)'...", structuredOutput: options.structuredOutput)
            try FileManager.default.removeItem(at: product.installerURL)
        }

        PrettyPrint.print("Creating new installer '\(product.installerURL.path)'...", structuredOutput: options.structuredOutput)
        let arguments: [String] = ["installer", "-pkg", distributionURL.path, "-target", "/"]
        let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
        _ = try Shell.execute(arguments, environment: variables)
        PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", structuredOutput: options.structuredOutput)
        try FileManager.default.removeItem(at: temporaryURL)
        PrettyPrint.print("Created new installer '\(product.installerURL.path)'", structuredOutput: options.structuredOutput)
    }
}
