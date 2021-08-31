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
    /// - Throws: A `MistError` if macOS versions fail to be retreived or exported.
    static func run(options: ListOptions) throws {
        try sanityChecks(options)

        PrettyPrint.printHeader("SEARCH")

        switch options.platform {
        case .apple:
            PrettyPrint.print("Searching for macOS Firmware versions...")
            let firmwares: [Firmware] = HTTP.retrieveFirmwares()
            try export(firmwares.map { $0.dictionary }, options: options)
            PrettyPrint.print("Found \(firmwares.count) macOS Firmwares available for download\n", prefix: "  └─")
            list(firmwares)

        case .intel:
            PrettyPrint.print("Searching for macOS Installer versions...")
            let catalogURL: String = options.catalogURL ?? Catalog.defaultURL
            let products: [Product] = HTTP.retrieveProducts(catalogURL: catalogURL)
            try export(products.map { $0.dictionary }, options: options)
            PrettyPrint.print("Found \(products.count) macOS Installers available for download\n", prefix: "  └─")
            list(products)
        }
    }

    /// Perform a series of sanity checks on input data, throwing an error if the input data is invalid.
    ///
    /// - Parameters:
    ///   - options: List options determining platform (ie. **Apple** or **Intel**) as well as export options (ie. **CSV**, **JSON**, **Property List**, **YAML**).
    ///
    /// - Throws: A `MistError` if any of the sanity checks fail.
    private static func sanityChecks(_ options: ListOptions) throws {

        if let path: String = options.exportPath {

            PrettyPrint.printHeader("SANITY CHECKS")

            guard !path.isEmpty else {
                throw MistError.missingExportPath
            }

            PrettyPrint.print("Export path will be '\(path)'...")

            let url: URL = URL(fileURLWithPath: path)

            guard ["csv", "json", "plist", "yaml"].contains(url.pathExtension) else {
                throw MistError.invalidExportFileExtension
            }

            PrettyPrint.print("Export path file extension is valid...")
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
            PrettyPrint.print("Creating parent directory '\(directory.path)'...")
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

            try exportCSV(path, using: string)
        case "json":
            try exportJSON(path, using: dictionaries)
        case "plist":
            try exportPropertyList(path, using: dictionaries)
        case "yaml":
            try exportYAML(path, using: dictionaries)
        default:
            break
        }
    }

    /// Export the macOS downloads list as a CSV file.
    ///
    /// - Parameters:
    ///   - path:   Path to write the file to disk.
    ///   - string: The string to be written to disk.
    ///
    /// - Throws: An `Error` if the CSV is unable to be written to disk.
    private static func exportCSV(_ path: String, using string: String) throws {
        try string.write(toFile: path, atomically: true, encoding: .utf8)
        PrettyPrint.print("Exported list as CSV: '\(path)'")
    }

    /// Export the macOS downloads list as a JSON file.
    ///
    /// - Parameters:
    ///   - path:         Path to write the file to disk.
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///
    /// - Throws: An `Error` if the JSON is unable to be written to disk.
    private static func exportJSON(_ path: String, using dictionaries: [[String: Any]]) throws {
        let data: Data = try JSONSerialization.data(withJSONObject: dictionaries, options: .prettyPrinted)

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        try string.write(toFile: path, atomically: true, encoding: .utf8)
        PrettyPrint.print("Exported list as JSON: '\(path)'")
    }

    /// Export the macOS downloads list as a Propery List file.
    ///
    /// - Parameters:
    ///   - path:         Path to write the file to disk.
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///
    /// - Throws: An `Error` if the Property List is unable to be written to disk.
    private static func exportPropertyList(_ path: String, using dictionaries: [[String: Any]]) throws {
        let data: Data = try PropertyListSerialization.data(fromPropertyList: dictionaries, format: .xml, options: .bitWidth)

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        try string.write(toFile: path, atomically: true, encoding: .utf8)
        PrettyPrint.print("Exported list as Property List: '\(path)'")
    }

    /// Export the macOS downloads list as a YAML file.
    ///
    /// - Parameters:
    ///   - path:         Path to write the file to disk.
    ///   - dictionaries: The array of dictionaries to be written to disk.
    ///
    /// - Throws: An `Error` if the YAML is unable to be written to disk.
    private static func exportYAML(_ path: String, using dictionaries: [[String: Any]]) throws {
        let string: String = try Yams.dump(object: dictionaries)
        try string.write(toFile: path, atomically: true, encoding: .utf8)
        PrettyPrint.print("Exported list as YAML: '\(path)'")
    }

    /// List the macOS firmware downloads in an ASCII-formatted table.
    ///
    /// - Parameters:
    ///   - firmwares: The array of macOS firmwares to list.
    private static func list(_ firmwares: [Firmware]) {

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

    /// List the macOS installer downloads in an ASCII-formatted table.
    ///
    /// - Parameters:
    ///   - products: The array of macOS installers to list.
    private static func list(_ products: [Product]) {

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
}
