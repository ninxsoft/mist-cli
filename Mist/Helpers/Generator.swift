//
//  Generator.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Generator {

    static func generate(_ product: Product, settings: Settings) throws {

        if settings.application {
            try generateApplication(product: product, settings: settings)
        }

        if settings.image {
            try generateImage(product: product, settings: settings)
        }

        if settings.package {
            try generatePackage(product: product, settings: settings)
        }

        if settings.zip {
            try generateZip(product: product, settings: settings)
        }

        try FileManager.default.remove(product.installerURL, description: "installer")
    }

    private static func generateApplication(product: Product, settings: Settings) throws {
        let destinationURL: URL = URL(fileURLWithPath: settings.output).appendingPathComponent(product.applicationName)
        try FileManager.default.copy(product.installerURL, to: destinationURL)
    }

    private static func generateImage(product: Product, settings: Settings) throws {

        let temporaryURL: URL = URL(fileURLWithPath: "\(String.baseTemporaryDirectory)/\(product.identifier)")
        let temporaryApplicationURL: URL = temporaryURL.appendingPathComponent("Install \(product.name).app")
        let destinationURL: URL = URL(fileURLWithPath: settings.output).appendingPathComponent(product.imageName)

        try FileManager.default.remove(temporaryURL, description: "old temporary directory")
        try FileManager.default.create(temporaryURL, description: "new temporary directory")
        try FileManager.default.copy(product.installerURL, to: temporaryApplicationURL)
        try FileManager.default.remove(destinationURL, description: "old image")

        PrettyPrint.print(.info, string: "Creating new image '\(destinationURL.path)'...")
        try Shell.execute(["hdiutil", "create", "-fs", "HFS+", "-srcFolder", temporaryURL.path, "-volname", "Install \(product.name)", destinationURL.path])
        PrettyPrint.print(.info, string: "Created new image '\(destinationURL.path)'")

        if let identity: String = settings.identity,
            !identity.isEmpty {
            PrettyPrint.print(.info, string: "Codesigning image '\(destinationURL.path)'...")
            try Shell.execute(["codesign", "--sign", identity, destinationURL.path])
            PrettyPrint.print(.info, string: "Codesigned image '\(destinationURL.path)'")
        }

        try FileManager.default.remove(temporaryURL, description: "temporary directory")
    }

    private static func generatePackage(product: Product, settings: Settings) throws {

        guard let identifier: String = settings.packageIdentifier else {
            throw MistError.missingPackageIdentifier
        }

        let temporaryURL: URL = URL(fileURLWithPath: "\(String.baseTemporaryDirectory)/\(product.identifier)")
        let temporaryScriptsURL: URL = URL(fileURLWithPath: "\(String.baseTemporaryDirectory)/\(product.identifier)-Scripts")
        let temporaryZipURL: URL = temporaryURL.appendingPathComponent(product.zipName)
        let destinationURL: URL = URL(fileURLWithPath: settings.output).appendingPathComponent(product.packageName)
        let version: String = "\(product.version)-\(product.build)"
        var arguments: [String] = ["pkgbuild", "--component", product.installerURL.path, "--identifier", identifier, "--install-location", "/Applications", "--version", version, destinationURL.path]

        if product.isTooBigForPackagePayload {
            try FileManager.default.remove(temporaryURL, description: "old temporary directory")
            try FileManager.default.create(temporaryURL, description: "new temporary directory")

            let zipArguments: [String] = ["ditto", "-c", "-k", "--keepParent", "--sequesterRsrc", "--zlibCompressionLevel", "0", product.installerURL.path, temporaryZipURL.path]
            PrettyPrint.print(.info, string: "Creating ZIP archive '\(temporaryZipURL.path)'...")
            try Shell.execute(zipArguments)
            PrettyPrint.print(.info, string: "Created ZIP archive '\(temporaryZipURL.path)'")

            let splitArguments: [String] = ["split", "-b", "8191m", temporaryZipURL.path, "\(product.zipName)."]
            PrettyPrint.print(.info, string: "Splitting ZIP archive '\(temporaryZipURL.path)'...")
            try Shell.execute(splitArguments, currentDirectoryPath: temporaryURL.path)
            PrettyPrint.print(.info, string: "Split ZIP archive '\(temporaryZipURL.path)'")
            try FileManager.default.remove(temporaryZipURL, description: "temporary ZIP archive")

            try FileManager.default.remove(temporaryScriptsURL, description: "old temporary scripts directory")
            try FileManager.default.create(temporaryScriptsURL, description: "new temporary scripts directory")
            let temporaryPostInstallURL: URL = temporaryScriptsURL.appendingPathComponent("postinstall")
            PrettyPrint.print(.info, string: "Creating new temporary post install script '\(temporaryPostInstallURL.path)'...")
            try postInstall(for: product).write(to: temporaryPostInstallURL, atomically: true, encoding: .utf8)
            PrettyPrint.print(.info, string: "Created new temporary post install script '\(temporaryPostInstallURL.path)'...")

            PrettyPrint.print(.info, string: "Setting executable permissions on temporary post install script '\(temporaryPostInstallURL.path)'...")
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: temporaryPostInstallURL.path)
            PrettyPrint.print(.info, string: "Set executable permissions on temporary post install script '\(temporaryPostInstallURL.path)'...")

            arguments = [
                "pkgbuild", "--identifier", identifier, "--install-location", temporaryURL.path, "--scripts", temporaryScriptsURL.path, "--root", "\(temporaryURL.path)",
                "--version", "\(product.version)-\(product.build)", destinationURL.path
            ]
        }

        if let identity: String = settings.identity, !identity.isEmpty {
            arguments += ["--sign", identity]
        }

        try FileManager.default.remove(destinationURL, description: "old package")
        PrettyPrint.print(.info, string: "Creating new package '\(destinationURL.path)'...")
        try Shell.execute(arguments)
        PrettyPrint.print(.info, string: "Created new package '\(destinationURL.path)'")
        try FileManager.default.remove(temporaryURL, description: "temporary directory")
        try FileManager.default.remove(temporaryScriptsURL, description: "temporary scripts directory")
    }

    private static func generateZip(product: Product, settings: Settings) throws {
        let destinationURL: URL = URL(fileURLWithPath: settings.output).appendingPathComponent(product.zipName)
        let arguments: [String] = ["ditto", "-c", "-k", "--keepParent", "--sequesterRsrc", "--zlibCompressionLevel", "0", product.installerURL.path, destinationURL.path]
        PrettyPrint.print(.info, string: "Creating ZIP archive '\(destinationURL.path)'...")
        try Shell.execute(arguments)
        PrettyPrint.print(.info, string: "Created ZIP archive '\(destinationURL.path)'")

        if let identity: String = settings.identity,
            !identity.isEmpty {
            PrettyPrint.print(.info, string: "Codesigning ZIP archive '\(destinationURL.path)'...")
            try Shell.execute(["codesign", "--sign", identity, destinationURL.path])
            PrettyPrint.print(.info, string: "Codesigned ZIP archive '\(destinationURL.path)'")
        }
    }

    private static func postInstall(for product: Product) -> String {
        """
        #!/usr/bin/env bash

        set -e

        NAME="Install \(product.name)"
        TEMP_DIR="\(String.baseTemporaryDirectory)/\(product.identifier)"
        ZIP="$TEMP_DIR/\(product.zipName)"
        APPS_DIR="/Applications"
        APP="$APPS_DIR/$NAME.app"

        # merge the split zip files
        cat "$ZIP."* > "$ZIP"

        # remove installer app if it already exists
        if [[ -d "$APP" ]] ; then
            rm -rf "$APP"
        fi

        # unpack the app bundle
        ditto -x -k "$ZIP" "$APPS_DIR"

        # cleanup
        rm -rf "$TEMP_DIR"

        # change ownership and permissions
        chown -R root:wheel "$APP"
        chmod -R 755 "$APP"

        exit 0

        """
    }
}
