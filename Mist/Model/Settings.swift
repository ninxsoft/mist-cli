//
//  Settings.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Settings {
    let temporaryDirectory: String
    let outputDirectory: String
    let filenameTemplate: String
    let application: Bool
    let image: Bool
    let imageIdentity: String?
    let package: Bool
    let packageIdentifierPrefix: String?
    let packageIdentity: String?
    let zip: Bool
    let zipIdentity: String?

    func applicationPath(for product: Product) -> String {
        outputPath(for: product).appending(".app")
    }

    func imagePath(for product: Product) -> String {
        outputPath(for: product).appending(".dmg")
    }

    func packagePath(for product: Product) -> String {
        outputPath(for: product).appending(".pkg")
    }

    func zipPath(for product: Product) -> String {
        outputPath(for: product).appending(".zip")
    }

    private func outputPath(for product: Product) -> String {
        outputDirectory + "/" + filenameTemplate
            .replacingOccurrences(of: "%NAME%", with: product.name)
            .replacingOccurrences(of: "%VERSION%", with: product.version)
            .replacingOccurrences(of: "%BUILD%", with: product.build)
    }

    func packageIdentifier(for product: Product) -> String? {

        guard let packageIdentifierPrefix: String = packageIdentifierPrefix else {
            return nil
        }

        return packageIdentifierPrefix + ".install \(product.name)".lowercased().replacingOccurrences(of: " ", with: "-")
    }
}
