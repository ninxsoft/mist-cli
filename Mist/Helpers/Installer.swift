//
//  Installer.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Struct used to install macOS Installers.
struct Installer {

    /// Installs a recently downloaded macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the downloaded macOS Installer fails to install.
    static func install(_ product: Product, options: DownloadInstallerOptions) throws {

        guard let url: URL = URL(string: product.distribution) else {
            throw MistError.invalidURL(url: product.distribution)
        }

        let temporaryURL: URL = URL(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: product, options: options))
        let imageURL: URL = DownloadInstallerCommand.temporaryImage(for: product, options: options)
        let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

        !options.quiet ? PrettyPrint.printHeader("INSTALL") : Mist.noop()

        if FileManager.default.fileExists(atPath: imageURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old image '\(imageURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: imageURL)
        }

        !options.quiet ? PrettyPrint.print("Creating image '\(imageURL.path)'...") : Mist.noop()
        var arguments: [String] = ["hdiutil", "create", "-fs", "HFS+", "-layout", "SPUD", "-size", "\(product.diskImageSize)g", "-volname", product.identifier, imageURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Mounting disk image at mount point '\(product.temporaryDiskImageMountPointURL.path)'...") : Mist.noop()
        arguments = ["hdiutil", "attach", imageURL.path, "-noverify", "-mountpoint", product.temporaryDiskImageMountPointURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Creating new installer '\(product.temporaryInstallerURL.path)'...") : Mist.noop()
        arguments = ["installer", "-pkg", distributionURL.path, "-target", product.temporaryDiskImageMountPointURL.path]
        let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
        _ = try Shell.execute(arguments, environment: variables)

        if product.catalinaOrNewer {
            arguments = ["ditto", "\(product.temporaryDiskImageMountPointURL.path)Applications", "\(product.temporaryDiskImageMountPointURL.path)/Applications"]
            _ = try Shell.execute(arguments)
            arguments = ["rm", "-r", "\(product.temporaryDiskImageMountPointURL.path)Applications"]
            _ = try Shell.execute(arguments)
        }

        !options.quiet ? PrettyPrint.print("Created new installer '\(product.temporaryInstallerURL.path)'") : Mist.noop()
    }
}
