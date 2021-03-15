//
//  Installer.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Installer {

    static func install(_ product: Product) throws {

        guard let url: URL = URL(string: product.distribution) else {
            throw MistError.invalidURL(string: product.distribution)
        }

        let temporaryURL: URL = URL(fileURLWithPath: "\(String.baseTemporaryDirectory)/\(product.identifier)")
        let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

        try FileManager.default.remove(product.installerURL, description: "old installer")
        PrettyPrint.print(.info, string: "Creating new installer '\(product.installerURL.path)'...")
        try Shell.execute(["installer", "-pkg", distributionURL.path, "-target", "/"])
        PrettyPrint.print(.info, string: "Created new installer '\(product.installerURL.path)'")
        try FileManager.default.remove(temporaryURL, description: "temporary directory")
    }
}
