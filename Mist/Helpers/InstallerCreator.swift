//
//  InstallerCreator.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Struct used to install macOS Installers.
struct InstallerCreator {

    /// Creates a recently downloaded macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the downloaded macOS Installer fails to install.
    static func create(_ product: Product, options: DownloadInstallerOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("INSTALL", noAnsi: options.noAnsi) : Mist.noop()

        let imageURL: URL = DownloadInstallerCommand.temporaryImage(for: product, options: options)
        let temporaryURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: product, options: options))

        if FileManager.default.fileExists(atPath: imageURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old image '\(imageURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: imageURL)
        }

        !options.quiet ? PrettyPrint.print("Creating image '\(imageURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        var arguments: [String] = ["hdiutil", "create", "-fs", "HFS+", "-layout", "SPUD", "-size", "\(product.diskImageSize)g", "-volname", product.identifier, imageURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Mounting disk image at mount point '\(product.temporaryDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        arguments = ["hdiutil", "attach", imageURL.path, "-noverify", "-nobrowse", "-mountpoint", product.temporaryDiskImageMountPointURL.path]
        _ = try Shell.execute(arguments)

        if product.sierraOrOlder,
            let package: Package = product.packages.first {
            let legacyDiskImageURL: URL = temporaryURL.appendingPathComponent(package.filename)
            let legacyDiskImageMountPointURL: URL = URL(fileURLWithPath: "/Volumes/Install \(product.name)")
            let packageURL: URL = URL(fileURLWithPath: "/Volumes/Install \(product.name)").appendingPathComponent(package.filename.replacingOccurrences(of: ".dmg", with: ".pkg"))

            !options.quiet ? PrettyPrint.print("Mounting Installer disk image at mount point '\(legacyDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["hdiutil", "attach", legacyDiskImageURL.path, "-noverify", "-nobrowse", "-mountpoint", legacyDiskImageMountPointURL.path]
            _ = try Shell.execute(arguments)

            !options.quiet ? PrettyPrint.print("Creating Installer in disk image at mount point '\(legacyDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["installer", "-pkg", packageURL.path, "-target", product.temporaryDiskImageMountPointURL.path]
            let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
            _ = try Shell.execute(arguments, environment: variables)

            !options.quiet ? PrettyPrint.print("Unmounting Installer disk image at mount point '\(legacyDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            let arguments: [String] = ["hdiutil", "detach", legacyDiskImageMountPointURL.path, "-force"]
            _ = try Shell.execute(arguments)
        } else {
            guard let url: URL = URL(string: product.distribution) else {
                throw MistError.invalidURL(product.distribution)
            }

            let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

            !options.quiet ? PrettyPrint.print("Creating new installer '\(product.temporaryInstallerURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["installer", "-pkg", distributionURL.path, "-target", product.temporaryDiskImageMountPointURL.path]
            let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
            _ = try Shell.execute(arguments, environment: variables)
        }

        if product.catalinaOrNewer {
            arguments = ["ditto", "\(product.temporaryDiskImageMountPointURL.path)Applications", "\(product.temporaryDiskImageMountPointURL.path)/Applications"]
            _ = try Shell.execute(arguments)
            arguments = ["rm", "-r", "\(product.temporaryDiskImageMountPointURL.path)Applications"]
            _ = try Shell.execute(arguments)
        }

        !options.quiet ? PrettyPrint.print("Created new installer '\(product.temporaryInstallerURL.path)'", noAnsi: options.noAnsi) : Mist.noop()
    }
}
