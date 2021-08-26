//
//  Settings.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Settings {
    let outputDirectory: String
    let application: Bool
    let applicationName: String
    let image: Bool
    let imageName: String
    let imageSigningIdentity: String?
    let package: Bool
    let packageName: String
    let packageIdentifier: String
    let packageSigningIdentity: String?
    let keychain: String?
    let temporaryDirectory: String

    func outputDirectory(for product: Product) -> String {
        outputDirectory.stringWithSubstitutions(using: product)
    }

    func temporaryDirectory(for product: Product) -> String {
        "\(temporaryDirectory)/\(product.identifier)"
            .replacingOccurrences(of: "//", with: "/")
    }

    func temporaryScriptsDirectory(for product: Product) -> String {
        "\(temporaryDirectory)/\(product.identifier)-Scripts"
            .replacingOccurrences(of: "//", with: "/")
    }

    func applicationPath(for product: Product) -> String {
        "\(outputDirectory)/\(applicationName)".stringWithSubstitutions(using: product)
    }

    func imagePath(for product: Product) -> String {
        "\(outputDirectory)/\(imageName)".stringWithSubstitutions(using: product)
    }

    func packagePath(for product: Product) -> String {
        "\(outputDirectory)/\(packageName)".stringWithSubstitutions(using: product)
    }

    func packageIdentifier(for product: Product) -> String {
        packageIdentifier
            .stringWithSubstitutions(using: product)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }
}
