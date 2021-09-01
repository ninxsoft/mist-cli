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

        if !options.quiet {
            PrettyPrint.printHeader("SEARCH")
        }

        switch options.platform {
        case .apple:
            if !options.quiet {
                PrettyPrint.print("Searching for macOS Firmware versions...")
            }

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

            if !options.quiet {
                PrettyPrint.print("Found \(firmwares.count) macOS Firmware(s) available for download\n", prefix: "  └─")
            }

            if options.outputType == .ascii {
                listASCII(firmwares)
            } else {
                try list(firmwares.map { $0.dictionary }, options: options)
            }

        case .intel:
            if !options.quiet {
                PrettyPrint.print("Searching for macOS Installer versions...")
            }

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

            if !options.quiet {
                PrettyPrint.print("Found \(products.count) macOS Installer(s) available for download\n", prefix: "  └─")
            }

            if options.outputType == .ascii {
                listASCII(products)
            } else {
                try list(products.map { $0.dictionary }, options: options)
            }
        }
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

        if sanityChecks && !options.quiet {
            PrettyPrint.printHeader("SANITY CHECKS")
        }

        if let string: String = options.searchString {

            guard !string.isEmpty else {
                throw MistError.missingListSearchString
            }

            if !options.quiet {
                PrettyPrint.print("List search string will be '\(string)'...")
            }
        }

        if options.latest && !options.quiet {
            PrettyPrint.print("Searching only for latest (first) result...")
        }

        if let path: String = options.exportPath {

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            if !options.quiet {
                PrettyPrint.print("Export path will be '\(path)'...")
            }

            let url: URL = URL(fileURLWithPath: path)

            guard ["csv", "json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            if !options.quiet {
                PrettyPrint.print("Export path file extension is valid...")
            }
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
            if !options.quiet {
                PrettyPrint.print("Creating parent directory '\(directory.path)'...")
            }

            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        switch url.pathExtension {
        case "csv":

            var string: String

            switch options.platform {
            case .apple:
                string = "Signed,Name,Version,Build,Size,Date\n" + dictionaries.map { $0.firmwareCSVString() }.joined()
            case .intel:
                string = "Identifier,Name,Version,Build,Size,Date\n" + dictionaries.map { $0.productCSVString() }.joined()
            }

            try exportCSV(path, using: string, quiet: options.quiet)
        case "json":
            try exportJSON(path, using: dictionaries, quiet: options.quiet)
        case "plist":
            try exportPropertyList(path, using: dictionaries, quiet: options.quiet)
        case "yaml":
            try exportYAML(path, using: dictionaries, quiet: options.quiet)
        default:
            break
        }
    }

    /// Export the macOS downloads list as a CSV file.
    ///
    /// - Parameters:
    ///   - path:   Path to write the file to disk.
    ///   - string: The string to be written to disk.
    ///   - quiet:  Set to `true` to suppress verbose output.
    ///
    /// - Throws: An `Error` if the CSV is unable to be written to disk.
    private static func exportCSV(_ path: String, using string: String, quiet: Bool) throws {
        try string.write(toFile: path, atomically: true, encoding: .utf8)

        if !quiet {
            PrettyPrint.print("Exported list as CSV: '\(path)'")
        }
    }

    /// Export the macOS downloads list as a JSON file.
    ///
    /// - Parameters:
    ///   - path:         Path to write the file to disk.
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///   - quiet:        Set to `true` to suppress verbose output.
    ///
    /// - Throws: An `Error` if the JSON is unable to be written to disk.
    private static func exportJSON(_ path: String, using dictionaries: [[String: Any]], quiet: Bool) throws {
        let data: Data = try JSONSerialization.data(withJSONObject: dictionaries, options: .prettyPrinted)

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        try string.write(toFile: path, atomically: true, encoding: .utf8)

        if !quiet {
            PrettyPrint.print("Exported list as JSON: '\(path)'")
        }
    }

    /// Export the macOS downloads list as a Propery List file.
    ///
    /// - Parameters:
    ///   - path:         Path to write the file to disk.
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///   - quiet:        Set to `true` to suppress verbose output.
    ///
    /// - Throws: An `Error` if the Property List is unable to be written to disk.
    private static func exportPropertyList(_ path: String, using dictionaries: [[String: Any]], quiet: Bool) throws {
        let data: Data = try PropertyListSerialization.data(fromPropertyList: dictionaries, format: .xml, options: .bitWidth)

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        try string.write(toFile: path, atomically: true, encoding: .utf8)

        if !quiet {
            PrettyPrint.print("Exported list as Property List: '\(path)'")
        }
    }

    /// Export the macOS downloads list as a YAML file.
    ///
    /// - Parameters:
    ///   - path:         Path to write the file to disk.
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///   - quiet:        Set to `true` to suppress verbose output.
    ///
    /// - Throws: An `Error` if the YAML is unable to be written to disk.
    private static func exportYAML(_ path: String, using dictionaries: [[String: Any]], quiet: Bool) throws {
        let string: String = try Yams.dump(object: dictionaries)
        try string.write(toFile: path, atomically: true, encoding: .utf8)

        if !quiet {
            PrettyPrint.print("Exported list as YAML: '\(path)'")
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
            break
        case .csv:
            var string: String

            switch options.platform {
            case .apple:
                string = "Signed,Name,Version,Build,Size,Date\n" + dictionaries.map { $0.firmwareCSVString() }.joined()
            case .intel:
                string = "Identifier,Name,Version,Build,Size,Date\n" + dictionaries.map { $0.productCSVString() }.joined()
            }

            listCSV(string)
        case .json:
            try listJSON(dictionaries)
        case .plist:
            try listPropertyList(dictionaries)
        case .yaml:
            try listYAML(dictionaries)
        }
    }

    /// List the macOS Firmware downloads in an ASCII-formatted table.
    ///
    /// - Parameters:
    ///   - firmwares: The array of macOS Firmwares to list.
    private static func listASCII(_ firmwares: [Firmware]) {

        guard let maxSignedLength: Int = firmwares.map({ $0.signedDescription }).max(by: { $0.count < $1.count })?.count,
            let maxNameLength: Int = firmwares.map({ $0.name }).max(by: { $0.count < $1.count })?.count,
            let maxVersionLength: Int = firmwares.map({ $0.version }).max(by: { $0.count < $1.count })?.count,
            let maxBuildLength: Int = firmwares.map({ $0.build }).max(by: { $0.count < $1.count })?.count,
            let maxSizeLength: Int = firmwares.map({ $0.sizeDescription }).max(by: { $0.count < $1.count })?.count else {
            return
        }

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let signedHeading: String = "Signed"
        let nameHeading: String = "Name"
        let versionHeading: String = "Version"
        let buildHeading: String = "Build"
        let sizeHeading: String = "Size"
        let dateHeading: String = "Date"
        let signedPadding: Int = max(maxSignedLength - signedHeading.count, 0)
        let namePadding: Int = max(maxNameLength - nameHeading.count, 0)
        let versionPadding: Int = max(maxVersionLength - versionHeading.count, 0)
        let buildPadding: Int = max(maxBuildLength - buildHeading.count, 0)
        let sizePadding: Int = max(maxSizeLength - sizeHeading.count, 0)
        let datePadding: Int = max(dateFormatter.dateFormat.count - dateHeading.count, 0)

        var string: String = signedHeading + [String](repeating: " ", count: signedPadding).joined()
        string += " │ " + nameHeading + [String](repeating: " ", count: namePadding).joined()
        string += " │ " + versionHeading + [String](repeating: " ", count: versionPadding).joined()
        string += " │ " + buildHeading + [String](repeating: " ", count: buildPadding).joined()
        string += " │ " + sizeHeading + [String](repeating: " ", count: sizePadding).joined()
        string += " │ " + dateHeading + [String](repeating: " ", count: datePadding).joined()
        string += "\n" + [String](repeating: "─", count: signedHeading.count + signedPadding).joined()
        string += "─┼─" + [String](repeating: "─", count: nameHeading.count + namePadding).joined()
        string += "─┼─" + [String](repeating: "─", count: versionHeading.count + versionPadding).joined()
        string += "─┼─" + [String](repeating: "─", count: buildHeading.count + buildPadding).joined()
        string += "─┼─" + [String](repeating: "─", count: sizeHeading.count + sizePadding).joined()
        string += "─┼─" + [String](repeating: "─", count: dateHeading.count + datePadding).joined()
        string += "\n"

        for firmware in firmwares {
            let signedPadding: Int = max(signedHeading.count - firmware.signedDescription.count, 0)
            let namePadding: Int = max(maxNameLength - firmware.name.count, 0)
            let versionPadding: Int = max(max(maxVersionLength, versionHeading.count) - firmware.version.count, 0)
            let buildPadding: Int = max(maxBuildLength - firmware.build.count, 0)
            let sizePadding: Int = max(maxSizeLength - firmware.sizeDescription.count, 0)
            let datePadding: Int = max(dateFormatter.dateFormat.count - firmware.dateDescription.count, 0)

            var line: String = firmware.signedDescription + [String](repeating: " ", count: signedPadding).joined()
            line += " │ " + firmware.name + [String](repeating: " ", count: namePadding).joined()
            line += " │ " + firmware.version + [String](repeating: " ", count: versionPadding).joined()
            line += " │ " + firmware.build + [String](repeating: " ", count: buildPadding).joined()
            line += " │ " + [String](repeating: " ", count: sizePadding).joined() + firmware.sizeDescription
            line += " │ " + firmware.dateDescription + [String](repeating: " ", count: datePadding).joined()
            string += line + "\n"
        }

        print(string)
    }

    /// List the macOS Installer downloads in an ASCII-formatted table.
    ///
    /// - Parameters:
    ///   - products: The array of macOS Installers to list.
    private static func listASCII(_ products: [Product]) {

        guard let maxIdentifierLength: Int = products.map({ $0.identifier }).max(by: { $0.count < $1.count })?.count,
            let maxNameLength: Int = products.map({ $0.name }).max(by: { $0.count < $1.count })?.count,
            let maxVersionLength: Int = products.map({ $0.version }).max(by: { $0.count < $1.count })?.count,
            let maxBuildLength: Int = products.map({ $0.build }).max(by: { $0.count < $1.count })?.count,
            let maxSizeLength: Int = products.map({ $0.sizeDescription }).max(by: { $0.count < $1.count })?.count else {
            return
        }

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let identifierHeading: String = "Identifier"
        let nameHeading: String = "Name"
        let versionHeading: String = "Version"
        let buildHeading: String = "Build"
        let sizeHeading: String = "Size"
        let dateHeading: String = "Date"
        let identifierPadding: Int = max(maxIdentifierLength - identifierHeading.count, 0)
        let namePadding: Int = max(maxNameLength - nameHeading.count, 0)
        let versionPadding: Int = max(maxVersionLength - versionHeading.count, 0)
        let buildPadding: Int = max(maxBuildLength - buildHeading.count, 0)
        let sizePadding: Int = max(maxSizeLength - sizeHeading.count, 0)
        let datePadding: Int = max(dateFormatter.dateFormat.count - dateHeading.count, 0)

        var string: String = identifierHeading + [String](repeating: " ", count: identifierPadding).joined()
        string += " │ " + nameHeading + [String](repeating: " ", count: namePadding).joined()
        string += " │ " + versionHeading + [String](repeating: " ", count: versionPadding).joined()
        string += " │ " + buildHeading + [String](repeating: " ", count: buildPadding).joined()
        string += " │ " + sizeHeading + [String](repeating: " ", count: sizePadding).joined()
        string += " │ " + dateHeading + [String](repeating: " ", count: datePadding).joined()
        string += "\n" + [String](repeating: "─", count: identifierHeading.count + identifierPadding).joined()
        string += "─┼─" + [String](repeating: "─", count: nameHeading.count + namePadding).joined()
        string += "─┼─" + [String](repeating: "─", count: versionHeading.count + versionPadding).joined()
        string += "─┼─" + [String](repeating: "─", count: buildHeading.count + buildPadding).joined()
        string += "─┼─" + [String](repeating: "─", count: sizeHeading.count + sizePadding).joined()
        string += "─┼─" + [String](repeating: "─", count: dateHeading.count + datePadding).joined()
        string += "\n"

        for product in products {
            let identifierPadding: Int = max(identifierHeading.count - product.identifier.count, 0)
            let namePadding: Int = max(maxNameLength - product.name.count, 0)
            let versionPadding: Int = max(max(maxVersionLength, versionHeading.count) - product.version.count, 0)
            let buildPadding: Int = max(maxBuildLength - product.build.count, 0)
            let sizePadding: Int = max(maxSizeLength - product.sizeDescription.count, 0)
            let datePadding: Int = max(dateFormatter.dateFormat.count - product.date.count, 0)

            var line: String = product.identifier + [String](repeating: " ", count: identifierPadding).joined()
            line += " │ " + product.name + [String](repeating: " ", count: namePadding).joined()
            line += " │ " + product.version + [String](repeating: " ", count: versionPadding).joined()
            line += " │ " + product.build + [String](repeating: " ", count: buildPadding).joined()
            line += " │ " + [String](repeating: " ", count: sizePadding).joined() + product.sizeDescription
            line += " │ " + product.date + [String](repeating: " ", count: datePadding).joined()
            string += line + "\n"
        }

        print(string)
    }

    /// List the macOS downloads in an CSV string.
    ///
    /// - Parameters:
    ///   - string: The CSV string to print.
    private static func listCSV(_ string: String) {
        print(string)
    }

    /// List the macOS downloads in an JSON string.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of macOS downloads to list.
    ///
    /// - Throws: A `MistError` if the JSON data is unable to be converted to a string.
    private static func listJSON(_ dictionaries: [[String: Any]]) throws {

        let data: Data = try JSONSerialization.data(withJSONObject: dictionaries, options: .prettyPrinted)

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        print(string)
    }

    /// List the macOS downloads in an Property List string.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of macOS downloads to list.
    ///
    /// - Throws: A `MistError` if the Property List data is unable to be converted to a string.
    private static func listPropertyList(_ dictionaries: [[String: Any]]) throws {

        let data: Data = try PropertyListSerialization.data(fromPropertyList: dictionaries, format: .xml, options: .bitWidth)

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        print(string)
    }

    /// List the macOS downloads in an YAML string.
    ///
    /// - Parameters:
    ///   - dictionaries: The array of macOS downloads to list.
    ///
    /// - Throws: A `MistError` if the YAML data is unable to be converted to a string.
    private static func listYAML(_ dictionaries: [[String: Any]]) throws {
        let string: String = try Yams.dump(object: dictionaries)
        print(string)
    }
}
