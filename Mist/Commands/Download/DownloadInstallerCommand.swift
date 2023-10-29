//
//  DownloadInstallerCommand.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import ArgumentParser
import Foundation

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Struct used to perform **Download Installer** operations.
struct DownloadInstallerCommand: ParsableCommand {

    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "installer",
        abstract: """
        Download a macOS Installer.
        * macOS Installers for macOS Catalina 10.15 and older are for Intel based Macs only.
        * macOS Installers for macOS Big Sur 11 and newer are Universal - for both Apple Silicon and Intel based Macs.
        """
    )
    @OptionGroup var options: DownloadInstallerOptions

    /// Searches for and downloads a particular macOS version.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if a macOS version fails to download.
    static func run(options: DownloadInstallerOptions) throws {
        Mist.checkForNewVersion(noAnsi: options.noAnsi)
        try inputValidation(options)
        !options.quiet ? PrettyPrint.printHeader("SEARCH", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Searching for macOS download '\(options.searchString)'...", noAnsi: options.noAnsi) : Mist.noop()
        var catalogURLs: [String] = options.includeBetas ? Catalog.urls : [Catalog.standard.url]

        if let catalogURL: String = options.catalogURL {
            catalogURLs = [catalogURL]
        }

        let retrievedInstallers: [Installer] = HTTP.retrieveInstallers(from: catalogURLs, includeBetas: options.includeBetas, compatible: options.compatible, noAnsi: options.noAnsi)

        guard let installer: Installer = HTTP.installer(from: retrievedInstallers, searchString: options.searchString) else {
            !options.quiet ? PrettyPrint.print("No macOS Installer found with '\(options.searchString)', exiting...", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()
            return
        }

        !options.quiet ? PrettyPrint.print("Found [\(installer.identifier)] \(installer.name) \(installer.version) (\(installer.build)) [\(installer.date)]", noAnsi: options.noAnsi) : Mist.noop()

        if let architecture: Architecture = Hardware.architecture,
            architecture == .appleSilicon && !installer.bigSurOrNewer && options.outputType.contains(.iso) {
            !options.quiet ? PrettyPrint.print("macOS Catalina 10.15 and older cannot generate Bootable Disk Images on \(architecture.description) Macs...", noAnsi: options.noAnsi) : Mist.noop()
            !options.quiet ? PrettyPrint.print("Replace 'iso' with another output type or select a newer version of macOS, exiting...", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()
            return
        }

        try verifyExistingFiles(installer, options: options)
        try setup(installer, options: options)
        try verifyFreeSpace(installer, options: options)
        try Downloader().download(installer, options: options)

        if !installer.bigSurOrNewer || options.outputType != [.package] {
            try InstallerCreator.create(installer, options: options)
        }

        try Generator.generate(installer, options: options)
        try teardown(installer, options: options)
        try export(installer, options: options)
    }

    /// Performs a series of validations on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidation(_ options: DownloadInstallerOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("INPUT VALIDATION", noAnsi: options.noAnsi) : Mist.noop()

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        !options.quiet ? PrettyPrint.print("User is 'root'...", noAnsi: options.noAnsi) : Mist.noop()

        guard !options.searchString.isEmpty else {
            throw MistError.missingDownloadSearchString
        }

        !options.quiet ? PrettyPrint.print("Download search string will be '\(options.searchString)'...", noAnsi: options.noAnsi) : Mist.noop()

        guard !options.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        !options.quiet ? PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Only include compatible installers will be '\(options.compatible)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Cache downloads will be '\(options.cacheDownloads)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Output directory will be '\(options.outputDirectory)'...", noAnsi: options.noAnsi) : Mist.noop()
        !options.quiet ? PrettyPrint.print("Temporary directory will be '\(options.temporaryDirectory)'...", noAnsi: options.noAnsi) : Mist.noop()

        if let cachingServer: String = options.cachingServer {

            guard let url: URL = URL(string: cachingServer) else {
                throw MistError.invalidURL(cachingServer)
            }

            guard let scheme: String = url.scheme,
                scheme == "http" else {
                throw MistError.invalidCachingServerProtocol(url)
            }

            !options.quiet ? PrettyPrint.print("Content Caching Server URL will be '\(url.absoluteString)'...", noAnsi: options.noAnsi) : Mist.noop()
        }

        let string: String = "Force flag\(options.force ? " " : " has not been ")set, existing files will\(options.force ? " " : " not ")be overwritten..."
        !options.quiet ? PrettyPrint.print(string, noAnsi: options.noAnsi) : Mist.noop()

        if let path: String = options.exportPath {

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            !options.quiet ? PrettyPrint.print("Export path will be '\(path)'...", noAnsi: options.noAnsi) : Mist.noop()

            let url: URL = URL(fileURLWithPath: path)

            guard ["json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            !options.quiet ? PrettyPrint.print("Export path file extension is valid...", noAnsi: options.noAnsi) : Mist.noop()
        }

        try inputValidationApplication(options)
        try inputValidationImage(options)
        try inputValidationISO(options)
        try inputValidationPackage(options)
        try inputValidationBootableInstaller(options)
    }

    /// Performs a series of input validations specific to macOS Application output.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationApplication(_ options: DownloadInstallerOptions) throws {

        if options.outputType.contains(.application) {

            guard !options.applicationName.isEmpty else {
                throw MistError.missingApplicationName
            }

            !options.quiet ? PrettyPrint.print("Application name will be '\(options.applicationName)'...", noAnsi: options.noAnsi) : Mist.noop()
        }
    }

    /// Performs a series of input validations specific to macOS Disk Image output.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationImage(_ options: DownloadInstallerOptions) throws {

        if options.outputType.contains(.image) {

            guard !options.imageName.isEmpty else {
                throw MistError.missingImageName
            }

            !options.quiet ? PrettyPrint.print("Disk Image name will be '\(options.imageName)'...", noAnsi: options.noAnsi) : Mist.noop()

            if let identity: String = options.imageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingImageSigningIdentity
                }

                !options.quiet ? PrettyPrint.print("Disk Image signing identity will be '\(identity)'...", noAnsi: options.noAnsi) : Mist.noop()
            }
        }
    }

    /// Performs a series of input validations specific to Bootable macOS Disk Image output.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationISO(_ options: DownloadInstallerOptions) throws {

        if options.outputType.contains(.iso) {

            guard !options.isoName.isEmpty else {
                throw MistError.missingIsoName
            }

            !options.quiet ? PrettyPrint.print("Bootable Disk Image name will be '\(options.isoName)'...", noAnsi: options.noAnsi) : Mist.noop()
        }
    }

    /// Performs a series of input validations specific to macOS Installer Package output.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationPackage(_ options: DownloadInstallerOptions) throws {

        if options.outputType.contains(.package) {

            guard !options.packageName.isEmpty else {
                throw MistError.missingPackageName
            }

            !options.quiet ? PrettyPrint.print("Package name will be '\(options.packageName)'...", noAnsi: options.noAnsi) : Mist.noop()

            guard !options.packageIdentifier.isEmpty else {
                throw MistError.missingPackageIdentifier
            }

            !options.quiet ? PrettyPrint.print("Package identifier will be '\(options.packageIdentifier)'...", noAnsi: options.noAnsi) : Mist.noop()

            if let identity: String = options.packageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingPackageSigningIdentity
                }

                !options.quiet ? PrettyPrint.print("Package signing identity will be '\(identity)'...", noAnsi: options.noAnsi) : Mist.noop()
            }
        }
    }

    /// Performs a series of input validations specific to Bootable macOS Installer output.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidationBootableInstaller(_ options: DownloadInstallerOptions) throws {

        guard options.outputType.contains(.bootableInstaller) else {
            return
        }

        guard let bootableInstallerVolume = options.bootableInstallerVolume,
            !bootableInstallerVolume.isEmpty else {
            throw MistError.missingBootableInstallerVolume
        }

        let keys: [URLResourceKey] = [.volumeLocalizedFormatDescriptionKey, .volumeIsReadOnlyKey]

        guard let urls: [URL] = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [.skipHiddenVolumes]),
            let url: URL = urls.first(where: { $0.path == bootableInstallerVolume }) else {
            throw MistError.bootableInstallerVolumeNotFound(bootableInstallerVolume)
        }

        let resourceValues: URLResourceValues = try url.resourceValues(forKeys: Set(keys))

        guard let volumeLocalizedFormatDescription: String = resourceValues.volumeLocalizedFormatDescription else {
            throw MistError.bootableInstallerVolumeUnknownFormat(bootableInstallerVolume)
        }

        guard volumeLocalizedFormatDescription == "Mac OS Extended (Journaled)" else {
            throw MistError.bootableInstallerVolumeInvalidFormat(volume: bootableInstallerVolume, format: volumeLocalizedFormatDescription)
        }

        guard let volumeIsReadOnly: Bool = resourceValues.volumeIsReadOnly,
            !volumeIsReadOnly else {
            throw MistError.bootableInstallerVolumeIsReadOnly(bootableInstallerVolume)
        }

        !options.quiet ? PrettyPrint.print("Bootable macOS Installer will be created on volume '\(bootableInstallerVolume)'...", noAnsi: options.noAnsi) : Mist.noop()
    }

    /// Verifies if macOS Installer files already exist.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer to be downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if an existing file is found.
    private static func verifyExistingFiles(_ installer: Installer, options: DownloadInstallerOptions) throws {

        guard !options.force else {
            return
        }

        if options.outputType.contains(.application) {
            let path: String = applicationPath(for: installer, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.outputType.contains(.image) {
            let path: String = imagePath(for: installer, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.outputType.contains(.iso) {
            let path: String = isoPath(for: installer, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.outputType.contains(.package) {
            let path: String = packagePath(for: installer, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }
    }

    /// Sets up directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer to be downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func setup(_ installer: Installer, options: DownloadInstallerOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: outputDirectory(for: installer, options: options))
        let temporaryURL: URL = URL(fileURLWithPath: temporaryDirectory(for: installer, options: options))
        var processing: Bool = false

        !options.quiet ? PrettyPrint.printHeader("SETUP", noAnsi: options.noAnsi) : Mist.noop()

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            !options.quiet ? PrettyPrint.print("Creating output directory '\(outputURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.createDirectory(atPath: outputURL.path, withIntermediateDirectories: true, attributes: nil)
            processing = true
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) && !options.cacheDownloads {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
            processing = true
        }

        if !FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)
            processing = true
        }

        if !processing {
            !options.quiet ? PrettyPrint.print("Nothing to do!", noAnsi: options.noAnsi) : Mist.noop()
        }
    }

    /// Verifies free space for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer to be downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if there is not enough free space.
    private static func verifyFreeSpace(_ installer: Installer, options: DownloadInstallerOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: outputDirectory(for: installer, options: options))
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory)

        guard let bootVolumePath: String = FileManager.default.componentsToDisplay(forPath: "/")?.first,
            let temporaryVolumePath: String = FileManager.default.componentsToDisplay(forPath: temporaryURL.path)?.first,
            let outputVolumePath: String = FileManager.default.componentsToDisplay(forPath: outputURL.path)?.first else {
            throw MistError.notEnoughFreeSpace(volume: "", free: -1, required: -1)
        }

        var volumes: [(path: String, count: Int64)] = []
        var bootVolume: (path: String, count: Int64) = (path: "/", count: 1)
        var temporaryVolume: (path: String, count: Int64) = (path: temporaryURL.path, count: 1)
        var outputVolume: (path: String, count: Int64) = (path: outputURL.path, count: 0)

        if outputVolumePath == bootVolumePath {
            bootVolume.count += Int64(options.outputType.count)
        } else if outputVolumePath == temporaryVolumePath {
            temporaryVolume.count += Int64(options.outputType.count)
        } else {
            outputVolume.count += Int64(options.outputType.count)
            volumes.insert(outputVolume, at: 0)
        }

        if temporaryVolumePath == bootVolumePath {
            bootVolume.count += 1
        } else {
            volumes.insert(temporaryVolume, at: 0)
        }

        volumes.insert(bootVolume, at: 0)

        for volume in volumes {
            let required: Int64 = installer.size * volume.count
            let url: URL = URL(fileURLWithPath: volume.path)
            let values: URLResourceValues = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeAvailableCapacityKey])
            let free: Int64

            if let volumeAvailableCapacityForImportantUsage: Int64 = values.volumeAvailableCapacityForImportantUsage,
                volumeAvailableCapacityForImportantUsage > 0 {
                free = volumeAvailableCapacityForImportantUsage
            } else if let volumeAvailableCapacity: Int = values.volumeAvailableCapacity {
                free = Int64(volumeAvailableCapacity)
            } else {
                throw MistError.notEnoughFreeSpace(volume: url.path, free: 0, required: required)
            }

            guard required < free else {
                throw MistError.notEnoughFreeSpace(volume: url.path, free: free, required: required)
            }
        }
    }

    /// Tears down temporary directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func teardown(_ installer: Installer, options: DownloadInstallerOptions) throws {

        let temporaryURL: URL = URL(fileURLWithPath: temporaryDirectory(for: installer, options: options))
        let imageURL: URL = temporaryImage(for: installer, options: options)
        var processing: Bool = false

        !options.quiet ? PrettyPrint.printHeader("TEARDOWN", noAnsi: options.noAnsi) : Mist.noop()

        if !installer.bigSurOrNewer || options.outputType != [.package] {
            !options.quiet ? PrettyPrint.print("Unmounting disk image at mount point '\(installer.temporaryDiskImageMountPointURL.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            let arguments: [String] = ["hdiutil", "detach", installer.temporaryDiskImageMountPointURL.path, "-force"]
            _ = try Shell.execute(arguments)
            processing = true
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) && !options.cacheDownloads {
            !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...", noAnsi: options.noAnsi, prefix: options.exportPath != nil ? .default : .ending) : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
            processing = true
        } else if FileManager.default.fileExists(atPath: imageURL.path) {
            !options.quiet ? PrettyPrint.print("Deleting image '\(imageURL.path)'...", noAnsi: options.noAnsi, prefix: options.exportPath != nil ? .default : .ending) : Mist.noop()
            try FileManager.default.removeItem(at: imageURL)
            processing = true
        }

        if !processing {
            !options.quiet ? PrettyPrint.print("Nothing to do!", noAnsi: options.noAnsi, prefix: options.exportPath != nil ? .default : .ending) : Mist.noop()
        }
    }

    /// Exports the results for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - installer: The selected macOS Installer that was downloaded.
    ///   - options:   Download options for macOS Installers.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func export(_ installer: Installer, options: DownloadInstallerOptions) throws {

        guard let path: String = exportPath(for: installer, options: options) else {
            return
        }

        !options.quiet ? PrettyPrint.printHeader("EXPORT RESULTS", noAnsi: options.noAnsi) : Mist.noop()

        let url: URL = URL(fileURLWithPath: path)
        let directory: URL = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...", noAnsi: options.noAnsi) : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        let dictionary: [String: Any] = [
            "installer": installer.exportDictionary,
            "options": exportDictionary(for: installer, options: options)
        ]

        switch url.pathExtension {
        case "json":
            try dictionary.jsonString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as JSON: '\(path)'", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()
        case "plist":
            try dictionary.propertyListString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as Property List: '\(path)'", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()
        case "yaml":
            try dictionary.yamlString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as YAML: '\(path)'", noAnsi: options.noAnsi, prefix: .ending) : Mist.noop()
        default:
            break
        }
    }

    private static func exportDictionary(for installer: Installer, options: DownloadInstallerOptions) -> [String: Any] {
        [
            "outputTypes": options.outputType.map { $0.description },
            "includeBetas": options.includeBetas,
            "catalogURL": options.catalogURL ?? "",
            "force": options.force,
            "applicationPath": applicationPath(for: installer, options: options),
            "imagePath": imagePath(for: installer, options: options),
            "imageSigningIdentity": options.imageSigningIdentity ?? "",
            "isoPath": isoPath(for: installer, options: options),
            "packagePath": packagePath(for: installer, options: options),
            "packageIdentifier": packageIdentifier(for: installer, options: options),
            "packageSigningIdentity": options.packageSigningIdentity ?? "",
            "bootableInstallerVolume": options.bootableInstallerVolume ?? "",
            "keychain": options.keychain ?? "",
            "outputDirectory": outputDirectory(for: installer, options: options),
            "temporaryDirectory": temporaryDirectory(for: installer, options: options),
            "exportPath": exportPath(for: installer, options: options) ?? "",
            "quiet": options.quiet
        ]
    }

    static func applicationPath(for installer: Installer, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.applicationName)".stringWithSubstitutions(using: installer)
    }

    private static func exportPath(for installer: Installer, options: DownloadInstallerOptions) -> String? {

        guard let path: String = options.exportPath else {
            return nil
        }

        return path.stringWithSubstitutions(using: installer)
    }

    static func imagePath(for installer: Installer, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.imageName)".stringWithSubstitutions(using: installer)
    }

    static func isoPath(for installer: Installer, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.isoName)".stringWithSubstitutions(using: installer)
    }

    static func packagePath(for installer: Installer, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.packageName)".stringWithSubstitutions(using: installer)
    }

    static func packageIdentifier(for installer: Installer, options: DownloadInstallerOptions) -> String {
        options.packageIdentifier
            .stringWithSubstitutions(using: installer)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }

    private static func outputDirectory(for installer: Installer, options: DownloadInstallerOptions) -> String {
        options.outputDirectory.stringWithSubstitutions(using: installer)
    }

    static func temporaryDirectory(for installer: Installer, options: DownloadInstallerOptions) -> String {
        "\(options.temporaryDirectory)/\(installer.identifier)"
            .replacingOccurrences(of: "//", with: "/")
    }

    static func temporaryImage(for installer: Installer, options: DownloadInstallerOptions) -> URL {
        URL(fileURLWithPath: "\(temporaryDirectory(for: installer, options: options))/\(installer.identifier).dmg")
    }

    static func cachingServerURL(for source: URL, options: DownloadInstallerOptions) -> URL? {

        guard let cachingServerHost: String = options.cachingServer,
            let sourceHost: String = source.host else {
            return nil
        }

        let cachingServerPath: String = source.path.replacingOccurrences(of: sourceHost, with: "")
        let cachingServerString: String = "\(cachingServerHost)\(cachingServerPath)?source=\(sourceHost)&sourceScheme=https"

        guard let cachingServerURL: URL = URL(string: cachingServerString) else {
            return nil
        }

        return cachingServerURL
    }

    static func resumeDataURL(for package: Package, in installer: Installer, options: DownloadInstallerOptions) -> URL {
        let temporaryDirectory: String = temporaryDirectory(for: installer, options: options)
        let string: String = "\(temporaryDirectory)/\(package.filename).resumeData"
        let url: URL = URL(fileURLWithPath: string)
        return url
    }

    mutating func run() {

        do {
            try DownloadInstallerCommand.run(options: options)
        } catch {
            if let mistError: MistError = error as? MistError {
                PrettyPrint.print(mistError.description, noAnsi: options.noAnsi, prefix: .ending, prefixColor: .red)
            } else {
                PrettyPrint.print(error.localizedDescription, noAnsi: options.noAnsi, prefix: .ending, prefixColor: .red)
            }
        }
    }
}
// swiftlint:enable type_body_length
