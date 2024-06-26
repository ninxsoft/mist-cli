//
//  Generator.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

// swiftlint:disable file_length type_body_length

/// Helper Struct used to generate macOS Firmwares, Installers, Disk Images and Installer Packages.
enum Generator {
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
        let temporaryURL: URL = .init(fileURLWithPath: DownloadFirmwareCommand.temporaryDirectory(for: firmware, options: options))

        guard let firmwareURL: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(firmware.url)
        }

        let temporaryFirmwareURL: URL = temporaryURL.appendingPathComponent(firmwareURL.lastPathComponent)
        let destinationURL: URL = .init(fileURLWithPath: DownloadFirmwareCommand.firmwarePath(for: firmware, options: options))

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
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer options fail to generate.
    static func generate(_ installer: Installer, options: DownloadInstallerOptions) throws {
        if options.outputType.contains(.application) {
            try generateApplication(installer: installer, options: options)
        }

        if options.outputType.contains(.image) {
            try generateImage(installer: installer, options: options)
        }

        if options.outputType.contains(.iso) {
            try generateISO(installer: installer, options: options)
        }

        if options.outputType.contains(.package) {
            try generatePackage(installer: installer, options: options)
        }

        if options.outputType.contains(.bootableInstaller) {
            try generateBootableInstaller(installer: installer, options: options)
        }
    }

    /// Generates a macOS Installer Application Bundle.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the Application Bundle fails to generate.
    private static func generateApplication(installer: Installer, options: DownloadInstallerOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("APPLICATION", noAnsi: options.noAnsi) : Mist.noop()
        let destinationURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.applicationPath(for: installer, options: options))

        if !options.force {
            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old application '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: destinationURL)
        }

        !options.quiet ? PrettyPrint.print("Copying '\(installer.temporaryInstallerURL.path)' to '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.copyItem(at: installer.temporaryInstallerURL, to: destinationURL)
    }

    /// Generates a macOS Installer Disk Image, optionally codesigning.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer Disk Image fails to generate.
    private static func generateImage(installer: Installer, options: DownloadInstallerOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("DISK IMAGE", noAnsi: options.noAnsi) : Mist.noop()
        let temporaryURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: installer, options: options)).appendingPathComponent("image")
        let temporaryApplicationURL: URL = temporaryURL.appendingPathComponent("Install \(installer.name).app")
        let destinationURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.imagePath(for: installer, options: options))

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        !options.quiet ? PrettyPrint.print("Copying '\(installer.temporaryInstallerURL.path)' to '\(temporaryApplicationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.copyItem(at: installer.temporaryInstallerURL, to: temporaryApplicationURL)

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
        let arguments: [String] = ["hdiutil", "create", "-fs", "HFS+", "-srcFolder", temporaryURL.path, "-volname", "Install \(installer.name)", destinationURL.path]
        _ = try Shell.execute(arguments)

        if
            let identity: String = options.imageSigningIdentity,
            !identity.isEmpty {
            var arguments: [String] = ["codesign", "--sign", identity]

            if
                let keychain: String = options.keychain,
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

    // swiftlint:disable cyclomatic_complexity function_body_length

    /// Generates a Bootable macOS Installer Disk Image.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the Bootable macOS Installer Disk Image fails to generate.
    private static func generateISO(installer: Installer, options: DownloadInstallerOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("BOOTABLE DISK IMAGE", noAnsi: options.noAnsi) : Mist.noop()
        let temporaryURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: installer, options: options)).appendingPathComponent("iso")
        let dmgURL: URL = temporaryURL.appendingPathComponent("\(installer.identifier).dmg")
        let cdrURL: URL = temporaryURL.appendingPathComponent("\(installer.identifier).cdr")
        let destinationURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.isoPath(for: installer, options: options))
        var arguments: [String] = []

        if !options.force {
            guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw MistError.existingFile(path: destinationURL.path)
            }
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)

        if installer.mavericksOrNewer {
            !options.quiet ? PrettyPrint.print("Creating disk image '\(dmgURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["hdiutil", "create", "-fs", "JHFS+", "-layout", "SPUD", "-size", "\(installer.isoSize)g", dmgURL.path]
            _ = try Shell.execute(arguments)

            !options.quiet ? PrettyPrint.print("Mounting disk image at mount point '\(installer.temporaryISOMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["hdiutil", "attach", dmgURL.path, "-noverify", "-nobrowse", "-mountpoint", installer.temporaryISOMountPointURL.path]
            _ = try Shell.execute(arguments)

            // Workaround to make macOS Sierra 10.12 createinstallmedia work
            if installer.version.hasPrefix("10.12") {
                let url: URL = installer.temporaryInstallerURL.appendingPathComponent("Contents/Info.plist")
                try updatePropertyList(url, key: "CFBundleShortVersionString", value: "12.6.03")
            }

            arguments = ["\(installer.temporaryInstallerURL.path)/Contents/Resources/createinstallmedia"]

            if !installer.bigSurOrNewer {
                // swiftlint:disable:next line_length
                !options.quiet ? PrettyPrint.print("Copying '\(installer.temporaryInstallerURL.path)' to '\(installer.temporaryInstallerWithAdHocCodeSignaturesURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try FileManager.default.copyItem(at: installer.temporaryInstallerURL, to: installer.temporaryInstallerWithAdHocCodeSignaturesURL)
                !options.quiet ? PrettyPrint.print("Ad-hoc code signing '\(installer.temporaryInstallerWithAdHocCodeSignaturesURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try adHocCodesign(installer.temporaryInstallerWithAdHocCodeSignaturesURL)
                arguments = ["\(installer.temporaryInstallerWithAdHocCodeSignaturesURL.path)/Contents/Resources/createinstallmedia"]
            }

            arguments += ["--volume", installer.temporaryISOMountPointURL.path, "--nointeraction"]

            if installer.sierraOrOlder {
                arguments += ["--applicationpath", installer.temporaryInstallerURL.path]
            }

            !options.quiet ? PrettyPrint.print("Creating install media at mount point '\(installer.temporaryISOMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            _ = try Shell.execute(arguments)

            if !installer.bigSurOrNewer {
                for url in [
                    installer.temporaryInstallerWithAdHocCodeSignaturesURL,
                    installer.temporaryISOInstallerWithAdHocCodeSignaturesURL,
                    installer.temporaryISOInstallerURL
                ] where FileManager.default.fileExists(atPath: url.path) {
                    !options.quiet ? PrettyPrint.print("Deleting '\(url.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                    try FileManager.default.removeItem(at: url)
                }

                !options.quiet ? PrettyPrint.print("Copying '\(installer.temporaryInstallerURL.path)' to '\(installer.temporaryISOInstallerURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try FileManager.default.copyItem(at: installer.temporaryInstallerURL, to: installer.temporaryISOInstallerURL)
            }

            !options.quiet ? PrettyPrint.print("Unmounting disk image at mount point '\(installer.temporaryISOMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["hdiutil", "detach", installer.temporaryISOMountPointURL.path, "-force"]
            _ = try Shell.execute(arguments)

            !options.quiet ? PrettyPrint.print("Converting disk image '\(cdrURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["hdiutil", "convert", dmgURL.path, "-format", "UDTO", "-o", cdrURL.path]
            _ = try Shell.execute(arguments)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                !options.quiet ? PrettyPrint.print("Deleting old image '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try FileManager.default.removeItem(at: destinationURL)
            }

            !options.quiet ? PrettyPrint.print("Moving '\(cdrURL.path)' to '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.moveItem(at: cdrURL, to: destinationURL)

            !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)

            !options.quiet ? PrettyPrint.print("Created bootable disk image '\(destinationURL.path)'", noAnsi: options.noAnsi) : Mist.noop()
        } else {
            let installESDURL: URL = installer.temporaryInstallerURL.appendingPathComponent("Contents/SharedSupport/InstallESD.dmg")

            !options.quiet ? PrettyPrint.print("Converting disk image '\(installESDURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["hdiutil", "convert", installESDURL.path, "-format", "UDTO", "-o", cdrURL.path]
            _ = try Shell.execute(arguments)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                !options.quiet ? PrettyPrint.print("Deleting old image '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try FileManager.default.removeItem(at: destinationURL)
            }

            !options.quiet ? PrettyPrint.print("Moving '\(cdrURL.path)' to '\(destinationURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.moveItem(at: cdrURL, to: destinationURL)

            !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)

            !options.quiet ? PrettyPrint.print("Created bootable disk image '\(destinationURL.path)'", noAnsi: options.noAnsi) : Mist.noop()
        }
    }

    // swiftlint:enable cyclomatic_complexity function_body_length

    /// Generates a macOS Installer Package, optionally codesigning.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer Package fails to generate.
    private static func generatePackage(installer: Installer, options: DownloadInstallerOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("PACKAGE", noAnsi: options.noAnsi) : Mist.noop()

        let destinationURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.packagePath(for: installer, options: options))

        if installer.bigSurOrNewer {
            let temporaryURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: installer, options: options))
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
            let identifier: String = DownloadInstallerCommand.packageIdentifier(for: installer, options: options)
            let version: String = "\(installer.version)-\(installer.build)"
            var arguments: [String] = ["pkgbuild", "--component", installer.temporaryInstallerURL.path, "--identifier", identifier, "--install-location", "/Applications", "--version", version]

            if
                let identity: String = options.packageSigningIdentity,
                !identity.isEmpty {
                arguments += ["--sign", identity]

                if
                    let keychain: String = options.keychain,
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

    /// Generates a Bootable macOS Installer volume.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the Bootable macOS Installer volume fails to generate.
    private static func generateBootableInstaller(installer: Installer, options: DownloadInstallerOptions) throws {
        guard let volume: String = options.bootableInstallerVolume else {
            return
        }

        !options.quiet ? PrettyPrint.printHeader("BOOTABLE INSTALLER VOLUME", noAnsi: options.noAnsi) : Mist.noop()

        // Workaround to make macOS Sierra 10.12 createinstallmedia work
        if installer.version.hasPrefix("10.12") {
            let url: URL = installer.temporaryInstallerURL.appendingPathComponent("Contents/Info.plist")
            try updatePropertyList(url, key: "CFBundleShortVersionString", value: "12.6.03")
        }

        var arguments: [String] = ["\(installer.temporaryInstallerURL.path)/Contents/Resources/createinstallmedia"]

        if !installer.bigSurOrNewer {
            // swiftlint:disable:next line_length
            !options.quiet ? PrettyPrint.print("Copying '\(installer.temporaryInstallerURL.path)' to '\(installer.temporaryInstallerWithAdHocCodeSignaturesURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.copyItem(at: installer.temporaryInstallerURL, to: installer.temporaryInstallerWithAdHocCodeSignaturesURL)
            !options.quiet ? PrettyPrint.print("Ad-hoc code signing '\(installer.temporaryInstallerWithAdHocCodeSignaturesURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try adHocCodesign(installer.temporaryInstallerWithAdHocCodeSignaturesURL)
            arguments = ["\(installer.temporaryInstallerWithAdHocCodeSignaturesURL.path)/Contents/Resources/createinstallmedia"]
        }

        arguments += ["--volume", installer.temporaryISOMountPointURL.path, "--nointeraction"]

        if installer.sierraOrOlder {
            arguments += ["--applicationpath", installer.temporaryInstallerURL.path]
        }

        let destinationURL: URL = .init(fileURLWithPath: volume).deletingLastPathComponent().appendingPathComponent("Install \(installer.name)")

        !options.quiet ? PrettyPrint.print("Creating bootable macOS Installer at mount point '\(volume)'...", noAnsi: options.noAnsi) : Mist.noop()
        _ = try Shell.execute(arguments)
        !options.quiet ? PrettyPrint.print("Created bootable macOS installer at mount point '\(destinationURL.path)'", noAnsi: options.noAnsi) : Mist.noop()

        if !installer.bigSurOrNewer {
            // swiftlint:disable:next identifier_name
            let temporaryBootableInstallerWithAdHocCodeSignaturesURL: URL = destinationURL.appendingPathComponent("Install \(installer.name).ad-hoc-code-signatures.app")
            let temporaryBootableInstallerURL: URL = destinationURL.appendingPathComponent("Install \(installer.name).app")

            for url in [
                installer.temporaryInstallerWithAdHocCodeSignaturesURL,
                temporaryBootableInstallerWithAdHocCodeSignaturesURL,
                temporaryBootableInstallerURL
            ] where FileManager.default.fileExists(atPath: url.path) {
                !options.quiet ? PrettyPrint.print("Deleting '\(url.path)'...", noAnsi: options.noAnsi) : Mist.noop()
                try FileManager.default.removeItem(at: url)
            }

            !options.quiet ? PrettyPrint.print("Copying '\(installer.temporaryInstallerURL.path)' to '\(temporaryBootableInstallerURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.copyItem(at: installer.temporaryInstallerURL, to: temporaryBootableInstallerURL)
        }
    }

    /// Update a key-pair value in a Property List.
    ///
    /// - Parameters:
    ///   - url:   The URL of the property list to be updated.
    ///   - key:   The key in the property list to be updated.
    ///   - value: The value to update within the property list.
    ///
    /// - Throws: An `Error` if the command failed to execute.
    private static func updatePropertyList(_ url: URL, key: String, value: AnyHashable) throws {
        let input: String = try String(contentsOf: url, encoding: .utf8)

        guard var data: Data = input.data(using: .utf8) else {
            throw MistError.invalidData
        }

        var format: PropertyListSerialization.PropertyListFormat = .xml

        guard var propertyList: [String: Any] = try PropertyListSerialization.propertyList(from: data, options: [.mutableContainers], format: &format) as? [String: Any] else {
            throw MistError.invalidData
        }

        propertyList[key] = value
        data = try PropertyListSerialization.data(fromPropertyList: propertyList, format: .xml, options: .bitWidth)
        let output: String = .init(decoding: data, as: UTF8.self)
        try output.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Sign the provided URL with an ad-hoc code signature.
    ///
    /// - Parameters:
    ///   - url: The URL of the file or directory to sign with an ad-hoc code signature.
    ///
    /// - Throws: An `Error` if the command failed to execute.
    private static func adHocCodesign(_ url: URL) throws {
        guard
            let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else {
            throw MistError.invalidURL(url.path)
        }

        for case let url as URL in enumerator {
            let fileAttributes: URLResourceValues = try url.resourceValues(forKeys: [.isRegularFileKey])

            guard
                let isRegularFile: Bool = fileAttributes.isRegularFile,
                isRegularFile else {
                continue
            }

            do {
                let arguments: [String] = ["codesign", "--remove-signature", "--force", url.path]
                _ = try Shell.execute(arguments)
            } catch {
                // do nothing
            }

            do {
                let arguments: [String] = ["codesign", "--sign", "-", "--force", url.path]
                _ = try Shell.execute(arguments)
            } catch {
                // do nothing
            }
        }
    }
}

// swiftlint:enable type_body_length
