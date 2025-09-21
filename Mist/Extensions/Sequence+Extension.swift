//
//  Sequence+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 1/9/21.
//

import Foundation
import Yams

extension Sequence where Iterator.Element == [String: Any] {
    // swiftlint:disable function_body_length

    /// Returns an ASCII-formatted table string for the provided array of `Firmware` dictionaries.
    ///
    /// - Parameters:
    ///   - noAnsi: Set to `true` to return the string without any color or formatting.
    ///
    /// - Returns: An ASCII-formatted table string for the provided array of `Firmware` dictionaries.
    func firmwaresASCIIString(noAnsi: Bool) -> String {
        let signedHeading: String = "SIGNED"
        let nameHeading: String = "NAME"
        let versionHeading: String = "VERSION"
        let buildHeading: String = "BUILD"
        let sizeHeading: String = "SIZE"
        let dateHeading: String = "DATE"
        let compatibleHeading: String = "COMPATIBLE"

        let maximumSignedLength: Int = compactMap { $0["signed"] as? Bool }.map { $0 ? "True" : "False" }.maximumStringLength(comparing: signedHeading)
        let maximumNameLength: Int = compactMap { $0["name"] as? String }.maximumStringLength(comparing: nameHeading)
        let maximumVersionLength: Int = compactMap { $0["version"] as? String }.maximumStringLength(comparing: versionHeading)
        let maximumBuildLength: Int = compactMap { $0["build"] as? String }.maximumStringLength(comparing: buildHeading)
        let maximumSizeLength: Int = compactMap { $0["size"] as? Int64 }.map { $0.bytesString() }.maximumStringLength(comparing: sizeHeading)
        let maximumDateLength: Int = compactMap { $0["date"] as? String }.maximumStringLength(comparing: dateHeading)
        let maximumCompatibleLength: Int = compactMap { $0["compatible"] as? Bool }.map { $0 ? "True" : "False" }.maximumStringLength(comparing: compatibleHeading)

        let signedPadding: Int = Swift.max(maximumSignedLength - signedHeading.count, 0)
        let namePadding: Int = Swift.max(maximumNameLength - nameHeading.count, 0)
        let versionPadding: Int = Swift.max(maximumVersionLength - versionHeading.count, 0)
        let buildPadding: Int = Swift.max(maximumBuildLength - buildHeading.count, 0)
        let sizePadding: Int = Swift.max(maximumSizeLength - sizeHeading.count, 0)
        let datePadding: Int = Swift.max(maximumDateLength - dateHeading.count, 0)
        let compatiblePadding: Int = Swift.max(maximumCompatibleLength - compatibleHeading.count, 0)

        let columns: [(string: String, padding: Int)] = [
            (string: signedHeading, padding: signedPadding),
            (string: nameHeading, padding: namePadding),
            (string: versionHeading, padding: versionPadding),
            (string: buildHeading, padding: buildPadding),
            (string: sizeHeading, padding: sizePadding),
            (string: dateHeading, padding: datePadding),
            (string: compatibleHeading, padding: compatiblePadding)
        ]

        var string: String = headerASCIIString(columns: columns, noAnsi: noAnsi)

        for item in self {
            let signed: String = (item["signed"] as? Bool ?? false) ? "True" : "False"
            let name: String = item["name"] as? String ?? ""
            let version: String = item["version"] as? String ?? ""
            let build: String = item["build"] as? String ?? ""
            let size: String = (item["size"] as? Int64 ?? 0).bytesString()
            let date: String = item["date"] as? String ?? ""
            let compatible: String = (item["compatible"] as? Bool ?? false) ? "True" : "False"

            let signedPadding: Int = Swift.max(maximumSignedLength - signed.count, 0)
            let namePadding: Int = Swift.max(maximumNameLength - name.count, 0)
            let versionPadding: Int = Swift.max(maximumVersionLength - version.count, 0)
            let buildPadding: Int = Swift.max(maximumBuildLength - build.count, 0)
            let sizePadding: Int = Swift.max(maximumSizeLength - size.count, 0)
            let datePadding: Int = Swift.max(maximumDateLength - date.count, 0)
            let compatiblePadding: Int = Swift.max(maximumCompatibleLength - compatible.count, 0)

            let columns: [(string: String, padding: Int)] = [
                (string: signed, padding: signedPadding),
                (string: name, padding: namePadding),
                (string: version, padding: versionPadding),
                (string: build, padding: buildPadding),
                (string: size, padding: sizePadding),
                (string: date, padding: datePadding),
                (string: compatible, padding: compatiblePadding)
            ]

            string += rowASCIIString(columns: columns, noAnsi: noAnsi)
        }

        string += footerASCIIString(columns: columns, noAnsi: noAnsi)
        return string
    }

    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length

    /// Returns an ASCII-formatted table string for the provided array of `Installer` dictionaries.
    ///
    /// - Parameters:
    ///   - noAnsi: Set to `true` to return the string without any color or formatting.
    ///
    /// - Returns: An ASCII-formatted table string for the provided array of `Installer` dictionaries.
    func installersASCIIString(noAnsi: Bool) -> String {
        let identifierHeading: String = "IDENTIFIER"
        let nameHeading: String = "NAME"
        let versionHeading: String = "VERSION"
        let buildHeading: String = "BUILD"
        let sizeHeading: String = "SIZE"
        let dateHeading: String = "DATE"
        let compatibleHeading: String = "COMPATIBLE"

        let maximumIdentifierLength: Int = compactMap { $0["identifier"] as? String }.maximumStringLength(comparing: identifierHeading)
        let maximumNameLength: Int = compactMap { $0["name"] as? String }.maximumStringLength(comparing: nameHeading)
        let maximumVersionLength: Int = compactMap { $0["version"] as? String }.maximumStringLength(comparing: versionHeading)
        let maximumBuildLength: Int = compactMap { $0["build"] as? String }.maximumStringLength(comparing: buildHeading)
        let maximumSizeLength: Int = compactMap { $0["size"] as? Int64 }.map { $0.bytesString() }.maximumStringLength(comparing: sizeHeading)
        let maximumDateLength: Int = compactMap { $0["date"] as? String }.maximumStringLength(comparing: dateHeading)
        let maximumCompatibleLength: Int = compactMap { $0["compatible"] as? Bool }.map { $0 ? "True" : "False" }.maximumStringLength(comparing: compatibleHeading)

        let identifierPadding: Int = Swift.max(maximumIdentifierLength - identifierHeading.count, 0)
        let namePadding: Int = Swift.max(maximumNameLength - nameHeading.count, 0)
        let versionPadding: Int = Swift.max(maximumVersionLength - versionHeading.count, 0)
        let buildPadding: Int = Swift.max(maximumBuildLength - buildHeading.count, 0)
        let sizePadding: Int = Swift.max(maximumSizeLength - sizeHeading.count, 0)
        let datePadding: Int = Swift.max(maximumDateLength - dateHeading.count, 0)
        let compatiblePadding: Int = Swift.max(maximumCompatibleLength - compatibleHeading.count, 0)

        let columns: [(string: String, padding: Int)] = [
            (string: identifierHeading, padding: identifierPadding),
            (string: nameHeading, padding: namePadding),
            (string: versionHeading, padding: versionPadding),
            (string: buildHeading, padding: buildPadding),
            (string: sizeHeading, padding: sizePadding),
            (string: dateHeading, padding: datePadding),
            (string: compatibleHeading, padding: compatiblePadding)
        ]

        var string: String = headerASCIIString(columns: columns, noAnsi: noAnsi)

        for item in self {
            let identifier: String = item["identifier"] as? String ?? ""
            let name: String = item["name"] as? String ?? ""
            let version: String = item["version"] as? String ?? ""
            let build: String = item["build"] as? String ?? ""
            let size: String = (item["size"] as? Int64 ?? 0).bytesString()
            let date: String = item["date"] as? String ?? ""
            let compatible: String = (item["compatible"] as? Bool ?? false) ? "True" : "False"

            let identifierPadding: Int = Swift.max(maximumIdentifierLength - identifier.count, 0)
            let namePadding: Int = Swift.max(maximumNameLength - name.count, 0)
            let versionPadding: Int = Swift.max(Swift.max(maximumVersionLength, versionHeading.count) - version.count, 0)
            let buildPadding: Int = Swift.max(maximumBuildLength - build.count, 0)
            let sizePadding: Int = Swift.max(maximumSizeLength - size.count, 0)
            let datePadding: Int = Swift.max(maximumDateLength - date.count, 0)
            let compatiblePadding: Int = Swift.max(maximumCompatibleLength - compatible.count, 0)

            let columns: [(string: String, padding: Int)] = [
                (string: identifier, padding: identifierPadding),
                (string: name, padding: namePadding),
                (string: version, padding: versionPadding),
                (string: build, padding: buildPadding),
                (string: size, padding: sizePadding),
                (string: date, padding: datePadding),
                (string: compatible, padding: compatiblePadding)
            ]

            string += rowASCIIString(columns: columns, noAnsi: noAnsi)
        }

        string += footerASCIIString(columns: columns, noAnsi: noAnsi)
        return string
    }

    // swiftlint:enable function_body_length

    /// Generates a Header ASCII string based on the provided columns.
    ///
    /// - Parameters:
    ///   - columns: An array of column tuples, each containing a column string and padding integer.
    ///   - noAnsi:  Set to `true` to print the string without any color or formatting.
    ///
    /// - Returns: The Header ASCII string.
    private func headerASCIIString(columns: [(string: String, padding: Int)], noAnsi: Bool) -> String {
        var string: String = "┌─"

        for (index, column) in columns.enumerated() {
            string += [String](repeating: "─", count: column.string.count + column.padding).joined()
            string += index < columns.count - 1 ? "─┬─" : "─┐\n"
        }

        string += "│ "

        for (index, column) in columns.enumerated() {
            string += column.string + [String](repeating: " ", count: column.padding).joined()
            string += index < columns.count - 1 ? " │ " : " │\n"
        }

        string += "├─"

        for (index, column) in columns.enumerated() {
            string += [String](repeating: "─", count: column.string.count + column.padding).joined()
            string += index < columns.count - 1 ? "─┼─" : "─┤\n"
        }

        return string.color(noAnsi ? .reset : .blue)
    }

    /// Generates a Row ASCII string based on the provided columns.
    ///
    /// - Parameters:
    ///   - columns: An array of column tuples, each containing a column string and padding integer.
    ///   - noAnsi:  Set to `true` to print the string without any color or formatting.
    ///
    /// - Returns: The Row ASCII string.
    private func rowASCIIString(columns: [(string: String, padding: Int)], noAnsi: Bool) -> String {
        var string: String = "│ ".color(noAnsi ? .reset : .blue)

        for (index, column) in columns.enumerated() {
            // size column should be right-aligned
            if column.string.lowercased().contains("gb") {
                string += [String](repeating: " ", count: column.padding).joined() + column.string
            } else {
                string += column.string + [String](repeating: " ", count: column.padding).joined()
            }

            string += (index < columns.count - 1 ? " │ " : " │\n").color(noAnsi ? .reset : .blue)
        }

        return string
    }

    /// Generates a Footer ASCII string based on the provided columns.
    ///
    /// - Parameters:
    ///   - columns: An array of column tuples, each containing a column string and padding integer.
    ///   - noAnsi:  Set to `true` to print the string without any color or formatting.
    ///
    /// - Returns: The Header ASCII string.
    private func footerASCIIString(columns: [(string: String, padding: Int)], noAnsi: Bool) -> String {
        var string: String = "└─"

        for (index, column) in columns.enumerated() {
            string += [String](repeating: "─", count: column.string.count + column.padding).joined()
            string += index < columns.count - 1 ? "─┴─" : "─┘\n"
        }

        return string.color(noAnsi ? .reset : .blue)
    }

    /// Returns a CSV-formatted string for the provided array of `Firmware` objects.
    ///
    /// - Returns: A CSV-formatted string for the provided array of `Firmware` objects.
    func firmwaresCSVString() -> String {
        "Name,Version,Build,Size,URL,Date,Compatible,Signed,Beta\n" + map { $0.firmwareCSVString() }.joined()
    }

    /// Returns a CSV-formatted string for the provided array of `Installer` objects.
    ///
    /// - Returns: A CSV-formatted string for the provided array of `Installer` objects.
    func installersCSVString() -> String {
        "Identifier,Name,Version,Build,Size,Date,Compatible,Beta\n" + map { $0.installerCSVString() }.joined()
    }

    /// Returns a JSON string for the provided array.
    ///
    /// - Throws: An error if the JSON string cannot be created.
    ///
    /// - Returns: A JSON string for the provided array.
    func jsonString() throws -> String {
        let data: Data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys])
        let string: String = .init(decoding: data, as: UTF8.self)
        return string
    }

    /// Returns a Property List string for the provided array.
    ///
    /// - Throws: An error if the Property List string cannot be created.
    ///
    /// - Returns: A Property List string for the provided array.
    func propertyListString() throws -> String {
        let data: Data = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: .bitWidth)
        let string: String = .init(decoding: data, as: UTF8.self)
        return string
    }

    /// Returns a YAML string for the provided array.
    ///
    /// - Throws: An error if the YAML string cannot be created.
    ///
    /// - Returns: A YAML string for the provided array.
    func yamlString() throws -> String {
        try Yams.dump(object: self)
    }
}

extension Sequence where Iterator.Element == String {
    /// Returns the maximum string length, comparing an array of strings against the passed in string.
    ///
    /// - Parameters:
    ///   - string: The string to compare against the array of strings.
    ///
    /// - Returns: The maximum string length.
    func maximumStringLength(comparing string: String) -> Int {
        Swift.max(self.max { $0.count < $1.count }?.count ?? 0, string.count)
    }
}
