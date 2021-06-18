//
//  Installer.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Installer {

    static func install(_ product: Product, settings: Settings) throws {

        guard let url: URL = URL(string: product.distribution) else {
            throw MistError.invalidURL(url: product.distribution)
        }

        let temporaryURL: URL = URL(fileURLWithPath: "\(settings.temporaryDirectory)/\(product.identifier)")
        let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

        PrettyPrint.print(string: "[INSTALL]".color(.green))

        if FileManager.default.fileExists(atPath: product.installerURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old installer '\(product.installerURL.path)'...")
            try FileManager.default.removeItem(at: product.installerURL)
        }

        PrettyPrint.print(prefix: "├─", string: "Creating new installer '\(product.installerURL.path)'...")
        let arguments: [String] = ["installer", "-pkg", distributionURL.path, "-target", "/"]
        let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
        try Shell.execute(arguments, environment: variables)
        PrettyPrint.print(prefix: "├─", string: "Deleting temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.removeItem(at: temporaryURL)
        PrettyPrint.print(prefix: "└─", string: "Created new installer '\(product.installerURL.path)'")
    }
}
