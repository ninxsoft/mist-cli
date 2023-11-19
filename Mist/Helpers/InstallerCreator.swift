//
//  InstallerCreator.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Struct used to install macOS Installers.
enum InstallerCreator {
    /// Creates a recently downloaded macOS Installer.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the downloaded macOS Installer fails to install.
    static func create(_ installer: Installer, options: DownloadInstallerOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("INSTALL", noAnsi: options.noAnsi) : Mist.noop()

        let imageURL: URL = DownloadInstallerCommand.temporaryImage(for: installer, options: options)
        let temporaryURL: URL = .init(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: installer, options: options))

        if FileManager.default.fileExists(atPath: imageURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting old image '\(imageURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: imageURL)
        }

        !options.quiet ? PrettyPrint.print("Creating image '\(imageURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        var arguments: [String] = ["hdiutil", "create", "-fs", "HFS+", "-layout", "SPUD", "-size", "\(installer.diskImageSize)g", "-volname", installer.identifier, imageURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Mounting disk image at mount point '\(installer.temporaryDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
        arguments = ["hdiutil", "attach", imageURL.path, "-noverify", "-nobrowse", "-mountpoint", installer.temporaryDiskImageMountPointURL.path]
        _ = try Shell.execute(arguments)

        if
            installer.sierraOrOlder,
            let package: Package = installer.packages.first {
            let legacyDiskImageURL: URL = temporaryURL.appendingPathComponent(package.filename)
            let legacyDiskImageMountPointURL: URL = .init(fileURLWithPath: "/Volumes/Install \(installer.name)")
            let packageURL: URL = .init(fileURLWithPath: "/Volumes/Install \(installer.name)").appendingPathComponent(package.filename.replacingOccurrences(of: ".dmg", with: ".pkg"))

            !options.quiet ? PrettyPrint.print("Mounting Installer disk image at mount point '\(legacyDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["hdiutil", "attach", legacyDiskImageURL.path, "-noverify", "-nobrowse", "-mountpoint", legacyDiskImageMountPointURL.path]
            _ = try Shell.execute(arguments)

            !options.quiet ? PrettyPrint.print("Creating Installer in disk image at mount point '\(legacyDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["installer", "-pkg", packageURL.path, "-target", installer.temporaryDiskImageMountPointURL.path]
            let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
            _ = try Shell.execute(arguments, environment: variables)

            !options.quiet ? PrettyPrint.print("Unmounting Installer disk image at mount point '\(legacyDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            let arguments: [String] = ["hdiutil", "detach", legacyDiskImageMountPointURL.path, "-force"]
            _ = try Shell.execute(arguments)
        } else {
            guard let url: URL = URL(string: installer.distribution) else {
                throw MistError.invalidURL(installer.distribution)
            }

            let distributionURL: URL = temporaryURL.appendingPathComponent(url.lastPathComponent)

            !options.quiet ? PrettyPrint.print("Creating new installer '\(installer.temporaryInstallerURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            arguments = ["installer", "-pkg", distributionURL.path, "-target", installer.temporaryDiskImageMountPointURL.path]
            let variables: [String: String] = ["CM_BUILD": "CM_BUILD"]
            _ = try Shell.execute(arguments, environment: variables)
        }

        if installer.catalinaOrNewer {
            arguments = ["ditto", "\(installer.temporaryDiskImageMountPointURL.path)Applications", "\(installer.temporaryDiskImageMountPointURL.path)/Applications"]
            _ = try Shell.execute(arguments)
            arguments = ["rm", "-r", "\(installer.temporaryDiskImageMountPointURL.path)Applications"]
            _ = try Shell.execute(arguments)
        }

        // temporary fix for applying correct posix permissions
        arguments = ["chmod", "-R", "755", installer.temporaryInstallerURL.path]
        _ = try Shell.execute(arguments)

        !options.quiet ? PrettyPrint.print("Created new installer '\(installer.temporaryInstallerURL.path)'", noAnsi: options.noAnsi) : Mist.noop()
    }
}
