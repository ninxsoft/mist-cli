//
//  List.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation
import Yams

/// Struct used to perform **List** operations.
struct List {

    /// Searches and lists the macOS versions available for download, optionally exporting to a file.
    ///
    /// - Parameters:
    ///   - options: List options determining platform (ie. **Apple** or **Intel**) as well as export options (ie. **CSV**, **JSON**, **Property List**, **YAML**).
    ///
    /// - Throws: A `MistError` if macOS versions fail to be retrieved or exported.
    static func run(options: ListOptions) throws {
        try sanityChecks(options)

        !options.quiet ? PrettyPrint.printHeader("SEARCH") : Mist.noop()

        switch options.platform {
        case .apple:
            !options.quiet ? PrettyPrint.print("Searching for macOS Firmware versions...") : Mist.noop()

            var firmwares: [Firmware] = HTTP.retrieveFirmwares(quiet: options.quiet)

            if let searchString: String = options.searchString {
                firmwares = HTTP.firmwares(from: firmwares, searchString: searchString)
            }

            if options.latest {
                if let firmware: Firmware = firmwares.first {
                    firmwares = [firmware]
                }
            }

            try export(firmwares.map { $0.dictionary }, options: options)
            !options.quiet ? PrettyPrint.print("Found \(firmwares.count) macOS Firmware(s) available for download\n", prefix: "  └─") : Mist.noop()
            try list(firmwares.map { $0.dictionary }, options: options)

        case .intel:
            !options.quiet ? PrettyPrint.print("Searching for macOS Installer versions...") : Mist.noop()

            let catalogURL: String = options.catalogURL ?? Catalog.defaultURL
            var products: [Product] = HTTP.retrieveProducts(catalogURL: catalogURL, quiet: options.quiet)

            if let searchString: String = options.searchString {
                products = HTTP.products(from: products, searchString: searchString)
            }

            if options.latest {
                if let product: Product = products.first {
                    products = [product]
                }
            }

            try export(products.map { $0.dictionary }, options: options)
            !options.quiet ? PrettyPrint.print("Found \(products.count) macOS Installer(s) available for download\n", prefix: "  └─") : Mist.noop()
            try list(products.map { $0.dictionary }, options: options)
        }

        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        semaphore.wait()
    }

    /// Perform a series of sanity checks on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: List options determining platform (ie. **Apple** or **Intel**) as well as export options (ie. **CSV**, **JSON**, **Property List**, **YAML**).
    ///
    /// - Throws: A `MistError` if any of the sanity checks fail.
    private static func sanityChecks(_ options: ListOptions) throws {

        var sanityChecks: Bool = false

        if let _: String = options.searchString {
            sanityChecks = true
        }

        if options.latest {
            sanityChecks = true
        }

        if let _: String = options.exportPath {
            sanityChecks = true
        }

        if sanityChecks {
            !options.quiet ? PrettyPrint.printHeader("SANITY CHECKS") : Mist.noop()
        }

        if let string: String = options.searchString {

            guard !string.isEmpty else {
                throw MistError.missingListSearchString
            }

            !options.quiet ? PrettyPrint.print("List search string will be '\(string)'...") : Mist.noop()
        }

        if options.latest {
            !options.quiet ? PrettyPrint.print("Searching only for latest (first) result...") : Mist.noop()
        }

        if let path: String = options.exportPath {

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            !options.quiet ? PrettyPrint.print("Export path will be '\(path)'...") : Mist.noop()

            let url: URL = URL(fileURLWithPath: path)

            guard ["csv", "json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            !options.quiet ? PrettyPrint.print("Export path file extension is valid...") : Mist.noop()
        }
    }

    /// Export the macOS downloads list.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///   - options:      List options determining platform (ie. **Apple** or **Intel**) as well as export options (ie. **CSV**, **JSON**, **Property List**, **YAML**).
    ///
    /// - Throws: An `Error` if the dictionaries are unable to be written to disk.
    private static func export(_ dictionaries: [[String: Any]], options: ListOptions) throws {

        guard let path: String = options.exportPath else {
            return
        }

        let url: URL = URL(fileURLWithPath: path)
        let directory: URL = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            !options.quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...") : Mist.noop()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        switch url.pathExtension {
        case "csv":
            switch options.platform {
            case .apple:
                try dictionaries.firmwaresCSVString().write(toFile: path, atomically: true, encoding: .utf8)
            case .intel:
                try dictionaries.productsCSVString().write(toFile: path, atomically: true, encoding: .utf8)
            }

            !options.quiet ? PrettyPrint.print("Exported list as CSV: '\(path)'") : Mist.noop()
        case "json":
            try dictionaries.jsonString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as JSON: '\(path)'") : Mist.noop()
        case "plist":
            try dictionaries.propertyListString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as Property List: '\(path)'") : Mist.noop()
        case "yaml":
            try dictionaries.yamlString().write(toFile: path, atomically: true, encoding: .utf8)
            !options.quiet ? PrettyPrint.print("Exported list as YAML: '\(path)'") : Mist.noop()
        default:
            break
        }
    }

    /// List the macOS downloads to standard output.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of dictionaries to be printed to standard output.
    ///   - options:      List options determining platform (ie. **Apple** or **Intel**) as well as export options (ie. **CSV**, **JSON**, **Property List**, **YAML**).
    ///
    /// - Throws: A `MistError` if the list is unable to be printed to standard output.
    private static func list(_ dictionaries: [[String: Any]], options: ListOptions) throws {

        switch options.outputType {
        case .ascii:
            switch options.platform {
            case .apple:
                print(dictionaries.firmwaresASCIIString())
            case .intel:
                print(dictionaries.productsASCIIString())
            }
        case .csv:
            switch options.platform {
            case .apple:
                print(dictionaries.firmwaresCSVString())
            case .intel:
                print(dictionaries.productsCSVString())
            }
        case .json:
            try print(dictionaries.jsonString())
        case .plist:
            try print(dictionaries.propertyListString())
        case .yaml:
            try print(dictionaries.yamlString())
        }
    }
}
