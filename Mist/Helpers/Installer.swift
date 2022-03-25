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
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the downloaded macOS Installer fails to install.
    static func install(_ product: Product, options: DownloadOptions) throws {

        guard let url: URL = URL(string: product.distribution) else {
            throw MistError.invalidURL(url: product.distribution)
        }

        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

        !options.quiet ? PrettyPrint.printHeader("INSTALL") : Mist.noop()

        if FileManager.default.fileExists(atPath: product.installerURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old installer '\(product.installerURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: product.installerURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new installer '\(product.installerURL.path)'...") : Mist.noop()
        let arguments: [String] = ["installer", "-pkg", distributionURL.path, "-target", "/"]
        let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
        _ = try Shell.execute(arguments, environment: variables)
        !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.removeItem(at: temporaryURL)
        !options.quiet ? PrettyPrint.print("Created new installer '\(product.installerURL.path)'") : Mist.noop()
    }
}
