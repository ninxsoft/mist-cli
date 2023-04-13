//
//  Generator.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Struct used to generate macOS Firmwares, Installers, Disk Images and Installer Packages.
struct Generator {

    /// Generates a macOS Firmware.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if the macOS Firmware options fail to generate.
    static func generate(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {
        try generateFirmware(firmware: firmware, options: options)
    }

    /// Valides a macOS Firmware shasum and moves it from the temporary directory to the output directory.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware that was downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if the macOS Firmware fails to generate.
    private static func generateFirmware(firmware: Firmware, options: DownloadFirmwareOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("FIRMWARE", noAnsi: options.noAnsi) : Mist.noop()
        let temporaryURL: URL = URL(fileURLWithPath: DownloadFirmwareCommand.temporaryDirectory(for: firmware, options: options))

        guard let firmwareURL: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(url: firmware.url)
        }

        let temporaryFirmwareURL: URL = temporaryURL.appendingPathComponent(firmwareURL.lastPathComponent)
        let destinationURL: URL = URL(fileURLWithPath: DownloadFirmwareCommand.firmwarePath(for: firmware, options: options))

        !options.quiet ? PrettyPrint.print("Validating Shasum matches \(firmware.shasum)...", noAnsi: options.noAnsi) : Mist.noop()
        try Validator.validate(firmware, at: temporaryFirmwareURL)

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old firmware '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Moving '\(temporaryFirmwareURL.path)' to '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.moveItem(at: temporaryFirmwareURL, to: destinationURL)

        let posixPermissions: Int = 0o644
        !options.quiet ? PrettyPrint.print("Setting POSIX file permissions to '0\(String(posixPermissions, radix: 0o10))' for '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.setAttributes([.posixPermissions: posixPermissions], ofItemAtPath: destinationURL.path)
    }

    /// Generates a macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer options fail to generate.
    static func generate(_ product: Product, options: DownloadInstallerOptions) throws {

        if options.outputType.contains(.application) {
            try generateApplication(product: product, options: options)
        }

        if options.outputType.contains(.image) {
            try generateImage(product: product, options: options)
        }

        if options.outputType.contains(.iso) {
            try generateISO(product: product, options: options)
        }

        if options.outputType.contains(.package) {
            try generatePackage(product: product, options: options)
        }
    }

    /// Generates a macOS Installer Application Bundle.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the Application Bundle fails to generate.
    private static func generateApplication(product: Product, options: DownloadInstallerOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("APPLICATION", noAnsi: options.noAnsi) : Mist.noop()
        let destinationURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.applicationPath(for: product, options: options))

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old application '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Copying '\(product.temporaryInstallerURL.path)' to '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.copyItem(at: product.temporaryInstallerURL, to: destinationURL)
    }

    /// Generates a macOS Installer Disk Image, optionally codesigning.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer Disk Image fails to generate.
    private static func generateImage(product: Product, options: DownloadInstallerOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("DISK IMAGE", noAnsi: options.noAnsi) : Mist.noop()
        let temporaryURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: product, options: options)).appendingPathComponent("image")
        let temporaryApplicationURL: URL = temporaryURL.appendingPathComponent("Install \(product.name).app")
        let destinationURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.imagePath(for: product, options: options))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        !options.quiet ? PrettyPrint.print("Copying '\(product.temporaryInstallerURL.path)' to '\(temporaryApplicationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.copyItem(at: product.temporaryInstallerURL, to: temporaryApplicationURL)

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old image '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Creating image '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
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

            !options.quiet ? PrettyPrint.print("Codesigning image '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            _ = try Shell.execute(arguments)
        }

        !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.removeItem(at: temporaryURL)

        !options.quiet ? PrettyPrint.print("Created image '\(destinationURL.path)'", noAnsi: options.noAnsi) : Mist.noop()
    }

    /// Generates a Bootable macOS Installer Disk Image.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the Bootable macOS Installer Disk Image fails to generate.
    private static func generateISO(product: Product, options: DownloadInstallerOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("BOOTABLE DISK IMAGE", noAnsi: options.noAnsi) : Mist.noop()
        let temporaryURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: product, options: options)).appendingPathComponent("iso")
        let dmgURL: URL = temporaryURL.appendingPathComponent("\(product.identifier).dmg")
        let cdrURL: URL = temporaryURL.appendingPathComponent("\(product.identifier).cdr")
        let destinationURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.isoPath(for: product, options: options))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        !options.quiet ? PrettyPrint.print("Creating disk image '\(dmgURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        var arguments: [String] = ["hdiutil", "create", "-fs", "JHFS+", "-layout", "SPUD", "-size", "\(product.isoSize)g", dmgURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Mounting disk image at mount point '\(product.temporaryISOMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        arguments = ["hdiutil", "attach", dmgURL.path, "-noverify", "-nobrowse", "-mountpoint", product.temporaryISOMountPointURL    .path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Creating install media at mount point '\(product.temporaryISOMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        arguments = ["\(product.temporaryInstallerURL.path)/Contents/Resources/createinstallmedia", "--volume", product.temporaryISOMountPointURL.path, "--nointeraction"]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Unmounting disk image at mount point '\(product.temporaryISOMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        arguments = ["hdiutil", "detach", product.temporaryISOMountPointURL.path, "-force"]
        _ = try Shell.execute(arguments)

        if !options.force {

            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old image '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Converting disk image '\(cdrURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        arguments = ["hdiutil", "convert", dmgURL.path, "-format", "UDTO", "-o", cdrURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Moving '\(cdrURL.path)' to '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.moveItem(at: cdrURL, to: destinationURL)

        !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.removeItem(at: temporaryURL)

        !options.quiet ? PrettyPrint.print("Created bootable disk image '\(destinationURL.path)'", noAnsi: options.noAnsi) : Mist.noop()
    }

    /// Generates a macOS Installer Package, optionally codesigning.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer Package fails to generate.
    private static func generatePackage(product: Product, options: DownloadInstallerOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("PACKAGE", noAnsi: options.noAnsi) : Mist.noop()

        let destinationURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.packagePath(for: product, options: options))

        if product.bigSurOrNewer {
            let temporaryURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: product, options: options))
            let packageURL: URL = temporaryURL.appendingPathComponent("InstallAssistant.pkg")

            if !options.force {

                guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                    throw MistError.existingFile(path: destinationURL.path)
                }
            }

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                !options.quiet ? PrettyPrint.print("Deleting old package '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try FileManager.default.removeItem(at: destinationURL)
            }

            !options.quiet ? PrettyPrint.print("Copying '\(packageURL.path)' to '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.copyItem(at: packageURL, to: destinationURL)
        } else {
            let identifier: String = DownloadInstallerCommand.packageIdentifier(for: product, options: options)
            let version: String = "\(product.version)-\(product.build)"
            var arguments: [String] = ["pkgbuild", "--component", product.temporaryInstallerURL.path, "--identifier", identifier, "--install-location", "/Applications", "--version", version]

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
                !options.quiet ? PrettyPrint.print("Deleting old package '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try FileManager.default.removeItem(at: destinationURL)
            }

            !options.quiet ? PrettyPrint.print("Creating package '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            _ = try Shell.execute(arguments)
            !options.quiet ? PrettyPrint.print("Created package '\(destinationURL.path)'", noAnsi: options.noAnsi) : Mist.noop()
        }
    }
}
