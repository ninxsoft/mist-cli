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
        try inputValidation(options)
        !options.quiet ? PrettyPrint.printHeader("SEARCH") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Searching for macOS download '\(options.searchString)'...") : Mist.noop()
        var catalogURLs: [String] = Catalog.urls

        if let catalogURL: String = options.catalogURL {
            catalogURLs = [catalogURL]
        }

        let retrievedProducts: [Product] = HTTP.retrieveProducts(from: catalogURLs, includeBetas: options.includeBetas, compatible: options.compatible)

        guard let product: Product = HTTP.product(from: retrievedProducts, searchString: options.searchString) else {
            !options.quiet ? PrettyPrint.print("No macOS Installer found with '\(options.searchString)', exiting...", prefix: .ending) : Mist.noop()
            return
        }

        !options.quiet ? PrettyPrint.print("Found [\(product.identifier)] \(product.name) \(product.version) (\(product.build)) [\(product.date)]") : Mist.noop()
        try verifyExistingFiles(product, options: options)
        try setup(product, options: options)
        try verifyFreeSpace(product, options: options)
        try Downloader().download(product, options: options)
        try Installer.install(product, options: options)
        try Generator.generate(product, options: options)
        try teardown(product, options: options)
        try export(product, options: options)
    }

    /// Performs a series of validations on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if any of the input validations fail.
    private static func inputValidation(_ options: DownloadInstallerOptions) throws {

        !options.quiet ? PrettyPrint.printHeader("INPUT VALIDATION") : Mist.noop()

        guard NSUserName() == "root" else {
            throw MistError.invalidUser
        }

        !options.quiet ? PrettyPrint.print("User is 'root'...") : Mist.noop()

        guard !options.searchString.isEmpty else {
            throw MistError.missingDownloadSearchString
        }

        !options.quiet ? PrettyPrint.print("Download search string will be '\(options.searchString)'...") : Mist.noop()

        guard !options.outputDirectory.isEmpty else {
            throw MistError.missingOutputDirectory
        }

        !options.quiet ? PrettyPrint.print("Include betas in search results will be '\(options.includeBetas)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Only include compatible installers will be '\(options.compatible)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Cache downloads will be '\(options.cacheDownloads)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Output directory will be '\(options.outputDirectory)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Temporary directory will be '\(options.temporaryDirectory)'...") : Mist.noop()
        !options.quiet ? PrettyPrint.print("Force flag\(options.force ? " " : " has not been ")set, existing files will\(options.force ? " " : " not ")be overwritten...") : Mist.noop()

        if let path: String = options.exportPath {

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            !options.quiet ? PrettyPrint.print("Export path will be '\(path)'...") : Mist.noop()

            let url: URL = URL(fileURLWithPath: path)

            guard ["json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            !options.quiet ? PrettyPrint.print("Export path file extension is valid...") : Mist.noop()
        }

        try inputValidationApplication(options)
        try inputValidationImage(options)
        try inputValidationISO(options)
        try inputValidationPackage(options)
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

            !options.quiet ? PrettyPrint.print("Application name will be '\(options.applicationName)'...") : Mist.noop()
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

            !options.quiet ? PrettyPrint.print("Disk Image name will be '\(options.imageName)'...") : Mist.noop()

            if let identity: String = options.imageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingImageSigningIdentity
                }

                !options.quiet ? PrettyPrint.print("Disk Image signing identity will be '\(identity)'...") : Mist.noop()
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

            !options.quiet ? PrettyPrint.print("Bootable Disk Image name will be '\(options.isoName)'...") : Mist.noop()
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

            !options.quiet ? PrettyPrint.print("Package name will be '\(options.packageName)'...") : Mist.noop()

            guard let identifier: String = options.packageIdentifier,
                !identifier.isEmpty else {
                throw MistError.missingPackageIdentifier
            }

            !options.quiet ? PrettyPrint.print("Package identifier will be '\(identifier)'...") : Mist.noop()

            if let identity: String = options.packageSigningIdentity {

                guard !identity.isEmpty else {
                    throw MistError.missingPackageSigningIdentity
                }

                !options.quiet ? PrettyPrint.print("Package signing identity will be '\(identity)'...") : Mist.noop()
            }
        }
    }

    /// Verifies if macOS Installer files already exist.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer to be downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if an existing file is found.
    private static func verifyExistingFiles(_ product: Product, options: DownloadInstallerOptions) throws {

        guard !options.force else {
            return
        }

        if options.outputType.contains(.application) {
            let path: String = applicationPath(for: product, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.outputType.contains(.image) {
            let path: String = imagePath(for: product, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.outputType.contains(.iso) {
            let path: String = isoPath(for: product, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }

        if options.outputType.contains(.package) {
            let path: String = packagePath(for: product, options: options)

            guard !FileManager.default.fileExists(atPath: path) else {
                throw MistError.existingFile(path: path)
            }
        }
    }

    /// Sets up directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer to be downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func setup(_ product: Product, options: DownloadInstallerOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: outputDirectory(for: product, options: options))
        let temporaryURL: URL = URL(fileURLWithPath: temporaryDirectory(for: product, options: options))
        var processing: Bool = false

        !options.quiet ? PrettyPrint.printHeader("SETUP") : Mist.noop()

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            !options.quiet ? PrettyPrint.print("Creating output directory '\(outputURL.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(atPath: outputURL.path, withIntermediateDirectories: true, attributes: nil)
            processing = true
        }

        if FileManager.default.fileExists(atPath: temporaryURL.path) && !options.cacheDownloads {
            !options.quiet ? PrettyPrint.print("Deleting old temporary directory '\(temporaryURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
            processing = true
        }

        if !FileManager.default.fileExists(atPath: temporaryURL.path) {
            !options.quiet ? PrettyPrint.print("Creating new temporary directory '\(temporaryURL.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true, attributes: nil)
            processing = true
        }

        if !processing {
            !options.quiet ? PrettyPrint.print("Nothing to do!") : Mist.noop()
        }
    }

    /// Verifies free space for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer to be downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if there is not enough free space.
    private static func verifyFreeSpace(_ product: Product, options: DownloadInstallerOptions) throws {

        let outputURL: URL = URL(fileURLWithPath: outputDirectory(for: product, options: options))
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

            guard let attributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfFileSystem(forPath: volume.path),
                let number: NSNumber = attributes[.systemFreeSize] as? NSNumber else {
                throw MistError.notEnoughFreeSpace(volume: "", free: -1, required: -1)
            }

            let required: Int64 = product.size * volume.count
            let free: Int64 = number.int64Value

            guard required < free else {
                throw MistError.notEnoughFreeSpace(volume: volume.path, free: free, required: required)
            }
        }
    }

    /// Tears down temporary directory structure for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func teardown(_ product: Product, options: DownloadInstallerOptions) throws {
        !options.quiet ? PrettyPrint.printHeader("TEARDOWN") : Mist.noop()

        let temporaryURL: URL = URL(fileURLWithPath: temporaryDirectory(for: product, options: options))

        if FileManager.default.fileExists(atPath: temporaryURL.path) && !options.cacheDownloads {
            !options.quiet ? PrettyPrint.print("Deleting temporary directory '\(temporaryURL.path)'...") : Mist.noop()
            try FileManager.default.removeItem(at: temporaryURL)
        }

        !options.quiet ? PrettyPrint.print("Deleting installer '\(product.installerURL.path)'...", prefix: options.exportPath != nil ? .default : .ending) : Mist.noop()
        try FileManager.default.removeItem(at: product.installerURL)
    }

    /// Exports the results for macOS Installer downloads.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: An `Error` if any of the directory operations fail.
    private static func export(_ product: Product, options: DownloadInstallerOptions) throws {

        guard let path: String = exportPath(for: product, options: options) else {
            return
        }

        !options.quiet ? PrettyPrint.printHeader("EXPORT RESULTS") : Mist.noop()

        let url: URL = URL(fileURLWithPath: path)
        let directory: URL = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        let dictionary: [String: Any] = [
            "installer": product.exportDictionary,
            "options": exportDictionary(for: product, options: options)
        ]

        switch url.pathExtension {
        case "json":
            try dictionary.jsonString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as JSON: '\(path)'", prefix: .ending) : Mist.noop()
        case "plist":
            try dictionary.propertyListString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as Property List: '\(path)'", prefix: .ending) : Mist.noop()
        case "yaml":
            try dictionary.yamlString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported download results as YAML: '\(path)'", prefix: .ending) : Mist.noop()
        default:
            break
        }
    }

    private static func exportDictionary(for product: Product, options: DownloadInstallerOptions) -> [String: Any] {
        [
            "outputTypes": options.outputType.map { $0.description },
            "includeBetas": options.includeBetas,
            "catalogURL": options.catalogURL ?? "",
            "force": options.force,
            "applicationPath": applicationPath(for: product, options: options),
            "imagePath": imagePath(for: product, options: options),
            "imageSigningIdentity": options.imageSigningIdentity ?? "",
            "isoPath": isoPath(for: product, options: options),
            "packagePath": packagePath(for: product, options: options),
            "packageIdentifier": packageIdentifier(for: product, options: options),
            "packageSigningIdentity": options.packageSigningIdentity ?? "",
            "keychain": options.keychain ?? "",
            "outputDirectory": outputDirectory(for: product, options: options),
            "temporaryDirectory": temporaryDirectory(for: product, options: options),
            "exportPath": exportPath(for: product, options: options) ?? "",
            "quiet": options.quiet
        ]
    }

    static func applicationPath(for product: Product, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.applicationName)".stringWithSubstitutions(using: product)
    }

    private static func exportPath(for product: Product, options: DownloadInstallerOptions) -> String? {

        guard let path: String = options.exportPath else {
            return nil
        }

        return path.stringWithSubstitutions(using: product)
    }

    static func imagePath(for product: Product, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.imageName)".stringWithSubstitutions(using: product)
    }

    static func isoPath(for product: Product, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.isoName)".stringWithSubstitutions(using: product)
    }

    static func packagePath(for product: Product, options: DownloadInstallerOptions) -> String {
        "\(options.outputDirectory)/\(options.packageName)".stringWithSubstitutions(using: product)
    }

    static func packageIdentifier(for product: Product, options: DownloadInstallerOptions) -> String {

        guard let identifier: String = options.packageIdentifier else {
            return ""
        }

        return identifier
            .stringWithSubstitutions(using: product)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }

    private static func outputDirectory(for product: Product, options: DownloadInstallerOptions) -> String {
        options.outputDirectory.stringWithSubstitutions(using: product)
    }

    static func temporaryDirectory(for product: Product, options: DownloadInstallerOptions) -> String {
        "\(options.temporaryDirectory)/\(product.identifier)"
            .replacingOccurrences(of: "//", with: "/")
    }

    static func temporaryScriptsDirectory(for product: Product, options: DownloadInstallerOptions) -> String {
        "\(options.temporaryDirectory)/\(product.identifier)-Scripts"
            .replacingOccurrences(of: "//", with: "/")
    }

    mutating func run() throws {

        do {
            try DownloadInstallerCommand.run(options: options)
        } catch {
            guard let mistError: MistError = error as? MistError else {
                throw error
            }

            PrettyPrint.print(mistError.description, prefix: .ending, prefixColor: .red)
            throw mistError
        }
    }
}
