//
//  Sequence+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 1/9/21.
//

import Foundation
import Yams

extension Sequence where Iterator.Element == [String: Any] {

    // swiftlint:disable:next function_body_length
    func firmwaresASCIIString(noAnsi: Bool) -> String {

        let signedHeading: String = "Signed"
        let nameHeading: String = "Name"
        let versionHeading: String = "Version"
        let buildHeading: String = "Build"
        let sizeHeading: String = "Size"
        let dateHeading: String = "Date"
        let compatibleHeading: String = "Compatible"

        let maximumSignedLength: Int = self.compactMap { $0["signed"] as? Bool }.map { $0 ? "True" : "False" }.maximumStringLength(comparing: signedHeading)
        let maximumNameLength: Int = self.compactMap { $0["name"] as? String }.maximumStringLength(comparing: nameHeading)
        let maximumVersionLength: Int = self.compactMap { $0["version"] as? String }.maximumStringLength(comparing: versionHeading)
        let maximumBuildLength: Int = self.compactMap { $0["build"] as? String }.maximumStringLength(comparing: buildHeading)
        let maximumSizeLength: Int = self.compactMap { $0["size"] as? Int64 }.map { $0.bytesString() }.maximumStringLength(comparing: sizeHeading)
        let maximumDateLength: Int = self.compactMap { $0["date"] as? String }.maximumStringLength(comparing: dateHeading)
        let maximumCompatibleLength: Int = self.compactMap { $0["compatible"] as? Bool }.map { $0 ? "True" : "False" }.maximumStringLength(comparing: compatibleHeading)

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

        return string
    }

    // swiftlint:disable:next function_body_length
    func installersASCIIString(noAnsi: Bool) -> String {

        let identifierHeading: String = "Identifier"
        let nameHeading: String = "Name"
        let versionHeading: String = "Version"
        let buildHeading: String = "Build"
        let sizeHeading: String = "Size"
        let dateHeading: String = "Date"
        let compatibleHeading: String = "Compatible"

        let maximumIdentifierLength: Int = self.compactMap { $0["identifier"] as? String }.maximumStringLength(comparing: identifierHeading)
        let maximumNameLength: Int = self.compactMap { $0["name"] as? String }.maximumStringLength(comparing: nameHeading)
        let maximumVersionLength: Int = self.compactMap { $0["version"] as? String }.maximumStringLength(comparing: versionHeading)
        let maximumBuildLength: Int = self.compactMap { $0["build"] as? String }.maximumStringLength(comparing: buildHeading)
        let maximumSizeLength: Int = self.compactMap { $0["size"] as? Int64 }.map { $0.bytesString() }.maximumStringLength(comparing: sizeHeading)
        let maximumDateLength: Int = self.compactMap { $0["date"] as? String }.maximumStringLength(comparing: dateHeading)
        let maximumCompatibleLength: Int = self.compactMap { $0["compatible"] as? Bool }.map { $0 ? "True" : "False" }.maximumStringLength(comparing: compatibleHeading)

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

        return string
    }

    /// Generates a Header ASCII string based on the provided columns.
    ///
    /// - Parameters:
    ///   - columns: An array of column tuples, each containing a column string and padding integer.
    ///   - noAnsi:  Set to `true` to print the string without any color or formatting.
    ///
    /// - Returns: The Header ASCII string.
    private func headerASCIIString(columns: [(string: String, padding: Int)], noAnsi: Bool) -> String {

        var string: String = ""

        for (index, column) in columns.enumerated() {
            string += column.string + [String](repeating: " ", count: column.padding).joined()
            string += index < columns.count - 1 ? " │ ".color(noAnsi ? .reset : .blue) : "\n"
        }

        for (index, column) in columns.enumerated() {
            string += [String](repeating: "─".color(noAnsi ? .reset : .blue), count: column.string.count + column.padding).joined()
            string += index < columns.count - 1 ? "─┼─".color(noAnsi ? .reset : .blue) : "\n"
        }

        return string
    }

    /// Generates a Row ASCII string based on the provided columns.
    ///
    /// - Parameters:
    ///   - columns: An array of column tuples, each containing a column string and padding integer.
    ///   - noAnsi:  Set to `true` to print the string without any color or formatting.
    ///
    /// - Returns: The Row ASCII string.
    private func rowASCIIString(columns: [(string: String, padding: Int)], noAnsi: Bool) -> String {

        var string: String = ""

        for (index, column) in columns.enumerated() {

            // size column should be right-aligned
            if column.string.lowercased().contains("gb") {
                string += [String](repeating: " ", count: column.padding).joined() + column.string
            } else {
                string += column.string + [String](repeating: " ", count: column.padding).joined()
            }

            string += index < columns.count - 1 ? " │ ".color(noAnsi ? .reset : .blue) : "\n"
        }

        return string
    }

    func firmwaresCSVString() -> String {
        "Signed,Name,Version,Build,Size,Date,Compatible\n" + self.map { $0.firmwareCSVString() }.joined()
    }

    func installersCSVString() -> String {
        "Identifier,Name,Version,Build,Size,Date,Compatible\n" + self.map { $0.installerCSVString() }.joined()
    }

    func jsonString() throws -> String {
        let data: Data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys])

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        return string
    }

    func propertyListString() throws -> String {
        let data: Data = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: .bitWidth)

        guard let string: String = String(data: data, encoding: .utf8) else {
            throw MistError.invalidData
        }

        return string
    }

    func yamlString() throws -> String {
        try Yams.dump(object: self)
    }
}

extension Sequence where Iterator.Element == String {

    func maximumStringLength(comparing string: String) -> Int {
        Swift.max(self.max { $0.count < $1.count }?.count ?? 0, string.count)
    }
}
