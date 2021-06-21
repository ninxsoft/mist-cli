//
//  Settings.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

struct Settings {
    let outputDirectory: String
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
        outputDirectory
            .replacingOccurrences(of: "%NAME%", with: product.name)
            .replacingOccurrences(of: "%VERSION%", with: product.version)
            .replacingOccurrences(of: "%BUILD%", with: product.build)
            .replacingOccurrences(of: "//", with: "/")
    }

    func temporaryDirectory(for product: Product) -> String {
        "\(temporaryDirectory)/\(product.identifier)"
            .replacingOccurrences(of: "//", with: "/")
    }

    func temporaryScriptsDirectory(for product: Product) -> String {
        "\(temporaryDirectory)/\(product.identifier)-Scripts"
            .replacingOccurrences(of: "//", with: "/")
    }

    func imagePath(for product: Product) -> String {
        "\(outputDirectory)/\(imageName)"
            .replacingOccurrences(of: "%NAME%", with: product.name)
            .replacingOccurrences(of: "%VERSION%", with: product.version)
            .replacingOccurrences(of: "%BUILD%", with: product.build)
            .replacingOccurrences(of: "//", with: "/")
    }

    func packagePath(for product: Product) -> String {
        "\(outputDirectory)/\(packageName)"
            .replacingOccurrences(of: "%NAME%", with: product.name)
            .replacingOccurrences(of: "%VERSION%", with: product.version)
            .replacingOccurrences(of: "%BUILD%", with: product.build)
            .replacingOccurrences(of: "//", with: "/")
    }

    func packageIdentifier(for product: Product) -> String {
        packageIdentifier
            .replacingOccurrences(of: "%NAME%", with: product.name)
            .replacingOccurrences(of: "%VERSION%", with: product.version)
            .replacingOccurrences(of: "%BUILD%", with: product.build)
            .replacingOccurrences(of: "//", with: "/")
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }
}
