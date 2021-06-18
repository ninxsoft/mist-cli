//
//  Generator.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Generator {

    static func generate(_ product: Product, settings: Settings) throws {

        let outputURL: URL = URL(fileURLWithPath: settings.outputDirectory)

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
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

    }

        PrettyPrint.print(string: "[OUTPUT]".color(.green))
        PrettyPrint.print(prefix: "└─", string: "Deleting installer '\(product.installerURL.path)'...")
        try FileManager.default.removeItem(at: product.installerURL)
    }

    private static func generateImage(product: Product, settings: Settings) throws {

        let temporaryURL: URL = URL(fileURLWithPath: "\(settings.temporaryDirectory)/\(product.identifier)")
        let temporaryApplicationURL: URL = temporaryURL.appendingPathComponent("Install \(product.name).app")
        let destinationURL: URL = URL(fileURLWithPath: settings.imagePath(for: product))

        PrettyPrint.print(string: "[OUTPUT - IMAGE]".color(.green))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old temporary directory '\(temporaryURL.path)'...")
            try FileManager.default.removeItem(at: temporaryURL)
        }

        PrettyPrint.print(prefix: "├─", string: "Creating new temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        PrettyPrint.print(prefix: "├─", string: "Copying '\(product.installerURL.path)' to '\(temporaryApplicationURL.path)'...")
        try FileManager.default.copyItem(at: product.installerURL, to: temporaryApplicationURL)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old image '\(destinationURL.path)'...")
            try FileManager.default.removeItem(at: destinationURL)
        }

        PrettyPrint.print(prefix: "├─", string: "Creating image '\(destinationURL.path)'...")
        let arguments: [String] = ["hdiutil", "create", "-fs", "HFS+", "-srcFolder", temporaryURL.path, "-volname", "Install \(product.name)", destinationURL.path]
        try Shell.execute(arguments)

        if let identity: String = settings.signingIdentityApplication,
            !identity.isEmpty {

            var arguments: [String] = ["codesign", "--sign", identity]

            if let keychain: String = settings.keychain,
                !keychain.isEmpty {
                arguments += ["--keychain", keychain]
            }

            arguments += [destinationURL.path]

            PrettyPrint.print(prefix: "├─", string: "Codesigning image '\(destinationURL.path)'...")
            try Shell.execute(arguments)
        }

        PrettyPrint.print(prefix: "├─", string: "Deleting temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.removeItem(at: temporaryURL)

        PrettyPrint.print(prefix: "└─", string: "Created image '\(destinationURL.path)'...")
    }

    private static func generatePackage(product: Product, settings: Settings) throws {

        PrettyPrint.print(string: "[OUTPUT - PACKAGE]".color(.green))


        guard let identifier: String = settings.packageIdentifier(for: product) else {
            throw MistError.missingPackageIdentifierPrefix
        }

        let temporaryURL: URL = URL(fileURLWithPath: "\(settings.temporaryDirectory)/\(product.identifier)")
        let temporaryScriptsURL: URL = URL(fileURLWithPath: "\(settings.temporaryDirectory)/\(product.identifier)-Scripts")
        let temporaryZipURL: URL = temporaryURL.appendingPathComponent(product.zipName)
        let destinationURL: URL = URL(fileURLWithPath: settings.packagePath(for: product))
        let version: String = "\(product.version)-\(product.build)"
        var arguments: [String] = ["pkgbuild", "--component", product.installerURL.path, "--identifier", identifier, "--install-location", "/Applications", "--version", version]

        if product.isTooBigForPackagePayload {

            let zipArguments: [String] = ["ditto", "-c", "-k", "--keepParent", "--sequesterRsrc", "--zlibCompressionLevel", "0", product.installerURL.path, temporaryZipURL.path]
            PrettyPrint.print(.info, string: "Creating ZIP archive '\(temporaryZipURL.path)'...")
            try Shell.execute(zipArguments)
            PrettyPrint.print(.success, string: "Created ZIP archive '\(temporaryZipURL.path)'")

            let splitArguments: [String] = ["split", "-b", "8191m", temporaryZipURL.path, "\(product.zipName)."]
            PrettyPrint.print(.info, string: "Splitting ZIP archive '\(temporaryZipURL.path)'...")
            try Shell.execute(splitArguments, currentDirectoryPath: temporaryURL.path)
            PrettyPrint.print(.success, string: "Split ZIP archive '\(temporaryZipURL.path)'")

            let temporaryPostInstallURL: URL = temporaryScriptsURL.appendingPathComponent("postinstall")
            PrettyPrint.print(.info, string: "Creating temporary post install script '\(temporaryPostInstallURL.path)'...")
            try postInstall(for: product).write(to: temporaryPostInstallURL, atomically: true, encoding: .utf8)

            let installLocation: String = "\(String.temporaryDirectory)/\(product.identifier)"
            arguments = ["pkgbuild", "--identifier", identifier, "--install-location", installLocation, "--scripts", temporaryScriptsURL.path, "--root", temporaryURL.path, "--version", version]
        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old temporary directory '\(temporaryURL.path)'...")
            try FileManager.default.removeItem(at: temporaryURL)
        }

        PrettyPrint.print(prefix: "├─", string: "Creating new temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        PrettyPrint.print(prefix: "├─", string: "Creating ZIP archive '\(zipURL.path)'...")
        PrettyPrint.print(prefix: "├─", string: "Splitting ZIP archive '\(zipURL.path)'...")
        PrettyPrint.print(prefix: "├─", string: "Deleting temporary ZIP archive '\(zipURL.path)'")
        try FileManager.default.removeItem(at: zipURL)

        if FileManager.default.fileExists(atPath: scriptsURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old temporary scripts directory '\(scriptsURL.path)'...")
            try FileManager.default.removeItem(at: scriptsURL)
        }

        if let identity: String = settings.signingIdentityInstaller,
        PrettyPrint.print(prefix: "├─", string: "Creating new temporary scripts directory '\(scriptsURL.path)'...")
        try FileManager.default.createDirectory(at: scriptsURL, withIntermediateDirectories: true, attributes: nil)

        PrettyPrint.print(prefix: "├─", string: "Creating temporary post install script '\(postInstallURL.path)'...")
        PrettyPrint.print(prefix: "├─", string: "Setting executable permissions on temporary post install script '\(postInstallURL.path)'...")
            !identity.isEmpty {

            arguments += ["--sign", identity]

            if let keychain: String = settings.keychain,
                !keychain.isEmpty {
                arguments += ["--keychain", keychain]
            }
        }

        arguments += [destinationURL.path]

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old package '\(destinationURL.path)'...")
            try FileManager.default.removeItem(at: destinationURL)
        }

        PrettyPrint.print(prefix: "├─", string: "Creating package '\(destinationURL.path)'...")
        try Shell.execute(arguments)

        PrettyPrint.print(prefix: "├─", string: "Deleting temporary directory '\(temporaryURL.path)'...")
        try FileManager.default.removeItem(at: temporaryURL)

        PrettyPrint.print(prefix: "├─", string: "Deleting temporary scripts directory '\(scriptsURL.path)'...")
        try FileManager.default.removeItem(at: scriptsURL)

        PrettyPrint.print(prefix: "└─", string: "Created package '\(destinationURL.path)'")
    }



        if let identity: String = settings.signingIdentityApplication,
            !identity.isEmpty {

            var arguments: [String] = ["codesign", "--sign", identity]

            if let keychain: String = settings.keychain,
                !keychain.isEmpty {
                arguments += ["--keychain", keychain]
            }

            arguments += [destinationURL.path]

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            PrettyPrint.print(prefix: "├─", string: "Deleting old package '\(destinationURL.path)'...")
            try FileManager.default.removeItem(at: destinationURL)
        }

        PrettyPrint.print(prefix: "├─", string: "Creating package '\(destinationURL.path)'...")
        PrettyPrint.print(prefix: "└─", string: "Created package '\(destinationURL.path)'...")
    }

    private static func postInstall(for product: Product) -> String {
        """
        #!/usr/bin/env bash

        set -e

        NAME="Install \(product.name)"
        TEMP_DIR="\(String.temporaryDirectory)/\(product.identifier)"
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
