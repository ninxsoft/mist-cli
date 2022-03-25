//
//  Generator.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Helper Struct used to generate macOS Firmwares, Installers, Disk Images and Installer Packages.
struct Generator {

    /// Generates a macOS Firmware.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Firmware options fail to generate.
    static func generate(_ firmware: Firmware, options: DownloadOptions) throws {
        try generateFirmware(firmware: firmware, options: options)
    }

    /// Valides a macOS Firmware shasum and moves it from the temporary directory to the output directory.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Firmware fails to generate.
    private static func generateFirmware(firmware: Firmware, options: DownloadOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("FIRMWARE") : Mist.noop()
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        guard let firmwareURL: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(url: firmware.url)
        }

        let temporaryFirmwareURL: URL = temporaryURL.appendingPathComponent(firmwareURL.lastPathComponent)
        let destinationURL: URL = URL(fileURLWithPath: options.firmwarePath(for: firmware))

        !options.quiet ? PrettyPrint.print("Validating Shasum matches \(firmware.shasum)...") : Mist.noop()

        guard let string: String = try Shell.execute(["shasum", temporaryFirmwareURL.path]),
            let shasum: String = string.split(separator: " ").map({ String($0) }).first else {
            throw MistError.invalidData
        }

        if shasum != firmware.shasum {
            throw MistError.invalidShasum(invalid: shasum, valid: firmware.shasum)
        }

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old firmware '\(destinationURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Moving '\(temporaryFirmwareURL.path)' to '\(destinationURL.path)'...") : Mist.noop()
        try FileManager.default.moveItem(at: temporaryFirmwareURL, to: destinationURL)

        let posixPermissions: Int = 0o644
        PrettyPrint.print("Setting POSIX file permissions to '0\(String(posixPermissions, radix: 0o10))' for '\(destinationURL.path)'...")
        try FileManager.default.setAttributes([.posixPermissions: posixPermissions], ofItemAtPath: destinationURL.path)
    }

    /// Generates a macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer options fail to generate.
    static func generate(_ product: Product, options: DownloadOptions) throws {

        if options.application {
            try generateApplication(product: product, options: options)
        }

        if options.image {
            try generateImage(product: product, options: options)
        }

        if options.iso {
            try generateISO(product: product, options: options)
        }

        if options.package {
            try generatePackage(product: product, options: options)
        }
    }

    /// Generates a macOS Installer Application Bundle.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the Application Bundle fails to generate.
    private static func generateApplication(product: Product, options: DownloadOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("APPLICATION") : Mist.noop()
        let destinationURL: URL = URL(fileURLWithPath: options.applicationPath(for: product))

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old application '\(destinationURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Copying '\(product.installerURL.path)' to '\(destinationURL.path)'...") : Mist.noop()
        try FileManager.default.copyItem(at: product.installerURL, to: destinationURL)
    }

    /// Generates a macOS Installer Disk Image, optionally codesigning.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer Disk Image fails to generate.
    private static func generateImage(product: Product, options: DownloadOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("DISK IMAGE") : Mist.noop()
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let temporaryApplicationURL: URL = temporaryURL.appendingPathComponent("Install \(product.name).app")
        let destinationURL: URL = URL(fileURLWithPath: options.imagePath(for: product))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        !options.quiet ? PrettyPrint.print("Copying '\(product.installerURL.path)' to '\(temporaryApplicationURL.path)'...") : Mist.noop()
        try FileManager.default.copyItem(at: product.installerURL, to: temporaryApplicationURL)

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old image '\(destinationURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Creating image '\(destinationURL.path)'...") : Mist.noop()
        let arguments: [String] = ["hdiutil", "create", "-fs", "HFS+", "-srcFolder", temporaryURL.path, "-volname", "Install \(product.name)", destinationURL.path]
        _ = try Shell.execute(arguments)

        if let identity: String = options.imageSigningIdentity,
            !identity.isEmpty {

            var arguments: [String] = ["codesign", "--sign", identity]

            if let keychain: String = options.keychain,
                !keychain.isEmpty {
                arguments += ["--keychain", keychain]
            }

            arguments += [destinationURL.path]

            !options.quiet ? PrettyPrint.print("Codesigning image '\(destinationURL.path)'...") : Mist.noop()
            _ = try Shell.execute(arguments)
        }

        !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.removeItem(at: temporaryURL)

        !options.quiet ? PrettyPrint.print("Created image '\(destinationURL.path)'") : Mist.noop()
    }

    /// Generates a Bootable macOS Installer Disk Image.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the Bootable macOS Installer Disk Image fails to generate.
    private static func generateISO(product: Product, options: DownloadOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("BOOTABLE DISK IMAGE") : Mist.noop()
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let dmgURL: URL = temporaryURL.appendingPathComponent("\(product.identifier).dmg")
        let cdrURL: URL = temporaryURL.appendingPathComponent("\(product.identifier).cdr")
        let mountPointURL: URL = URL(fileURLWithPath: "/Volumes/Install \(product.name)")
        let destinationURL: URL = URL(fileURLWithPath: options.isoPath(for: product))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        !options.quiet ? PrettyPrint.print("Creating disk image '\(dmgURL.path)'...") : Mist.noop()
        var arguments: [String] = ["hdiutil", "create", "-fs", "JHFS+", "-layout", "SPUD", "-size", "\(product.isoSize)g", dmgURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Mounting disk image at mount point '\(mountPointURL.path)'...") : Mist.noop()
        arguments = ["hdiutil", "attach", dmgURL.path, "-noverify", "-mountpoint", mountPointURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Creating install media at mount point '\(mountPointURL.path)'...") : Mist.noop()
        arguments = ["\(product.installerURL.path)/Contents/Resources/createinstallmedia", "--volume", mountPointURL.path, "--nointeraction"]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Unmounting disk image at mount point '\(mountPointURL.path)'...") : Mist.noop()
        arguments = ["hdiutil", "detach", mountPointURL.path, "-force"]
        _ = try Shell.execute(arguments)

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old image '\(destinationURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Converting disk image '\(cdrURL.path)'...") : Mist.noop()
        arguments = ["hdiutil", "convert", dmgURL.path, "-format", "UDTO", "-o", cdrURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Moving '\(cdrURL.path)' to '\(destinationURL.path)'...") : Mist.noop()
        try FileManager.default.moveItem(at: cdrURL, to: destinationURL)

        !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.removeItem(at: temporaryURL)

        !options.quiet ? PrettyPrint.print("Created bootable disk image '\(destinationURL.path)'") : Mist.noop()
    }

    /// Generates a macOS Installer Package, optionally codesigning.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer Package fails to generate.
    private static func generatePackage(product: Product, options: DownloadOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("PACKAGE") : Mist.noop()

        if product.isTooBigForPackagePayload {
            try generateBigPackage(product: product, options: options)
        } else {
            try generateSmallPackage(product: product, options: options)
        }
    }

    // swiftlint:disable function_body_length

    /// Generates a macOS Installer Package for payloads larger than 8GB (ie. **macOS Big Sur** and above).
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer Package fails to generate.
    private static func generateBigPackage(product: Product, options: DownloadOptions) throws {

        let identifier: String = options.packageIdentifier(for: product)
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let zipURL: URL = temporaryURL.appendingPathComponent(product.zipName)
        let scriptsURL: URL = URL(fileURLWithPath: options.temporaryScriptsDirectory(for: product))
        let postInstallURL: URL = scriptsURL.appendingPathComponent("postinstall")
        let zipArguments: [String] = ["ditto", "-c", "-k", "--keepParent", "--sequesterRsrc", "--zlibCompressionLevel", "0", product.installerURL.path, zipURL.path]
        let splitArguments: [String] = ["split", "-b", "8191m", zipURL.path, "\(product.zipName)."]
        let installLocation: String = "\(String.temporaryDirectory)/\(product.identifier)"
        let destinationURL: URL = URL(fileURLWithPath: options.packagePath(for: product))
        let version: String = "\(product.version)-\(product.build)"
        var arguments: [String] = ["pkgbuild", "--identifier", identifier, "--install-location", installLocation, "--scripts", scriptsURL.path, "--root", temporaryURL.path, "--version", version]

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        !options.quiet ? PrettyPrint.print("Creating ZIP archive '\(zipURL.path)'...") : Mist.noop()
        _ = try Shell.execute(zipArguments)

        !options.quiet ? PrettyPrint.print("Splitting ZIP archive '\(zipURL.path)'...") : Mist.noop()
        _ = try Shell.execute(splitArguments, currentDirectoryPath: temporaryURL.path)

        !options.quiet ? PrettyPrint.print("Deleting temporary ZIP archive '\(zipURL.path)'") : Mist.noop()
        try FileManager.default.removeItem(at: zipURL)

        if FileManager.default.fileExists(atPath: scriptsURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary scripts directory '\(scriptsURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: scriptsURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary scripts directory '\(scriptsURL.path)'...") : Mist.noop()
        try FileManager.default.createDirectory(at: scriptsURL, withIntermediateDirectories: true, attributes: nil)

        !options.quiet ? PrettyPrint.print("Creating temporary post install script '\(postInstallURL.path)'...") : Mist.noop()
        try postInstall(for: product).write(to: postInstallURL, atomically: true, encoding: .utf8)

        !options.quiet ? PrettyPrint.print("Setting executable permissions on temporary post install script '\(postInstallURL.path)'...") : Mist.noop()
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: postInstallURL.path)

        if let identity: String = options.packageSigningIdentity,
            !identity.isEmpty {

            arguments += ["--sign", identity]

            if let keychain: String = options.keychain,
                !keychain.isEmpty {
                arguments += ["--keychain", keychain]
            }
        }

        arguments += [destinationURL.path]

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old package '\(destinationURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Creating package '\(destinationURL.path)'...") : Mist.noop()
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...") : Mist.noop()
        try FileManager.default.removeItem(at: temporaryURL)

        !options.quiet ? PrettyPrint.print("Deleting temporary scripts directory '\(scriptsURL.path)'...") : Mist.noop()
        try FileManager.default.removeItem(at: scriptsURL)

        !options.quiet ? PrettyPrint.print("Created package '\(destinationURL.path)'") : Mist.noop()
    }

    // swiftlint:enable function_body_length

    /// Generates a macOS Installer Package for payloads smaller than 8GB (ie. **macOS Catalina** and below).
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining kind (ie. **Firmware** or **Installer**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer Package fails to generate.
    private static func generateSmallPackage(product: Product, options: DownloadOptions) throws {

        let identifier: String = options.packageIdentifier(for: product)
        let destinationURL: URL = URL(fileURLWithPath: options.packagePath(for: product))
        let version: String = "\(product.version)-\(product.build)"
        var arguments: [String] = ["pkgbuild", "--component", product.installerURL.path, "--identifier", identifier, "--install-location", "/Applications", "--version", version]

        if let identity: String = options.packageSigningIdentity,
            !identity.isEmpty {

            arguments += ["--sign", identity]

            if let keychain: String = options.keychain,
                !keychain.isEmpty {
                arguments += ["--keychain", keychain]
            }
        }

        arguments += [destinationURL.path]

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old package '\(destinationURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Creating package '\(destinationURL.path)'...") : Mist.noop()
        _ = try Shell.execute(arguments)
        !options.quiet ? PrettyPrint.print("Created package '\(destinationURL.path)'") : Mist.noop()
    }

    /// Creates a custom postinstall script for the macOS Installer Package, used to re-join large payloads (ie. **macOS Big Sur** and above).
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///
    /// - Returns: The contents of the custom postinstall script.
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
