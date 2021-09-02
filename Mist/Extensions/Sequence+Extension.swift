//
//  Sequence+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 1/9/21.
//

import Foundation
import Yams

extension Sequence where Iterator.Element == [String: Any] {

    func firmwaresASCIIString() -> String {

        guard let maxSignedLength: Int = self.compactMap({ $0["signed"] as? Bool }).map({ $0 ? "Yes" : "No" }).max(by: { $0.count < $1.count })?.count,
            let maxNameLength: Int = self.compactMap({ $0["name"] as? String }).max(by: { $0.count < $1.count })?.count,
            let maxVersionLength: Int = self.compactMap({ $0["version"] as? String }).max(by: { $0.count < $1.count })?.count,
            let maxBuildLength: Int = self.compactMap({ $0["build"] as? String }).max(by: { $0.count < $1.count })?.count,
            let maxSizeLength: Int = self.compactMap({ $0["size"] as? Int64 }).map({ String(format: "%.2f GB", $0.toGigabytes()) }).max(by: { $0.count < $1.count })?.count,
            let maxDateLength: Int = self.map({ $0["date"] as? String ?? "" }).max(by: { $0.count < $1.count })?.count else {
            return ""
        }

        let signedHeading: String = "Signed"
        let nameHeading: String = "Name"
        let versionHeading: String = "Version"
        let buildHeading: String = "Build"
        let sizeHeading: String = "Size"
        let dateHeading: String = "Date"
        let signedPadding: Int = Swift.max(maxSignedLength - signedHeading.count, 0)
        let namePadding: Int = Swift.max(maxNameLength - nameHeading.count, 0)
        let versionPadding: Int = Swift.max(maxVersionLength - versionHeading.count, 0)
        let buildPadding: Int = Swift.max(maxBuildLength - buildHeading.count, 0)
        let sizePadding: Int = Swift.max(maxSizeLength - sizeHeading.count, 0)
        let datePadding: Int = Swift.max(maxDateLength - dateHeading.count, 0)

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

        for item in self {

            guard let signed: Bool = item["signed"] as? Bool,
                let name: String = item["name"] as? String,
                let version: String = item["version"] as? String,
                let build: String = item["build"] as? String,
                let size: Int64 = item["size"] as? Int64,
                let date: String = item["date"] as? String else {
                continue
            }

            let signedDescription: String = signed ? "Yes": "No"
            let signedPadding: Int = Swift.max(signedHeading.count - signedDescription.count, 0)
            let namePadding: Int = Swift.max(maxNameLength - name.count, 0)
            let versionPadding: Int = Swift.max(Swift.max(maxVersionLength, versionHeading.count) - version.count, 0)
            let buildPadding: Int = Swift.max(maxBuildLength - build.count, 0)
            let sizeDescription: String = String(format: "%.2f GB", size.toGigabytes())
            let sizePadding: Int = Swift.max(maxSizeLength - sizeDescription.count, 0)
            let datePadding: Int = Swift.max(maxDateLength - date.count, 0)

            var line: String = signedDescription + [String](repeating: " ", count: signedPadding).joined()
            line += " │ " + name + [String](repeating: " ", count: namePadding).joined()
            line += " │ " + version + [String](repeating: " ", count: versionPadding).joined()
            line += " │ " + build + [String](repeating: " ", count: buildPadding).joined()
            line += " │ " + [String](repeating: " ", count: sizePadding).joined() + sizeDescription
            line += " │ " + date + [String](repeating: " ", count: datePadding).joined()
            string += line + "\n"
        }

        return string
    }

    func productsASCIIString() -> String {

        guard let maxIdentifierLength: Int = self.compactMap({ $0["identifier"] as? String }).max(by: { $0.count < $1.count })?.count,
            let maxNameLength: Int = self.compactMap({ $0["name"] as? String }).max(by: { $0.count < $1.count })?.count,
            let maxVersionLength: Int = self.compactMap({ $0["version"] as? String }).max(by: { $0.count < $1.count })?.count,
            let maxBuildLength: Int = self.compactMap({ $0["build"] as? String }).max(by: { $0.count < $1.count })?.count,
            let maxSizeLength: Int = self.compactMap({ $0["size"] as? Int64 }).map({ String(format: "%.2f GB", $0.toGigabytes()) }).max(by: { $0.count < $1.count })?.count,
            let maxDateLength: Int = self.map({ $0["date"] as? String ?? "" }).max(by: { $0.count < $1.count })?.count else {
            return ""
        }

        let identifierHeading: String = "Identifier"
        let nameHeading: String = "Name"
        let versionHeading: String = "Version"
        let buildHeading: String = "Build"
        let sizeHeading: String = "Size"
        let dateHeading: String = "Date"
        let identifierPadding: Int = Swift.max(maxIdentifierLength - identifierHeading.count, 0)
        let namePadding: Int = Swift.max(maxNameLength - nameHeading.count, 0)
        let versionPadding: Int = Swift.max(maxVersionLength - versionHeading.count, 0)
        let buildPadding: Int = Swift.max(maxBuildLength - buildHeading.count, 0)
        let sizePadding: Int = Swift.max(maxSizeLength - sizeHeading.count, 0)
        let datePadding: Int = Swift.max(maxDateLength - dateHeading.count, 0)

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

        for item in self {

            guard let identifier: String = item["identifier"] as? String,
                let name: String = item["name"] as? String,
                let version: String = item["version"] as? String,
                let build: String = item["build"] as? String,
                let size: Int64 = item["size"] as? Int64,
                let date: String = item["date"] as? String else {
                continue
            }

            let identifierPadding: Int = Swift.max(maxIdentifierLength - identifier.count, 0)
            let namePadding: Int = Swift.max(maxNameLength - name.count, 0)
            let versionPadding: Int = Swift.max(Swift.max(maxVersionLength, versionHeading.count) - version.count, 0)
            let buildPadding: Int = Swift.max(maxBuildLength - build.count, 0)
            let sizeDescription: String = String(format: "%.2f GB", size.toGigabytes())
            let sizePadding: Int = Swift.max(maxSizeLength - sizeDescription.count, 0)
            let datePadding: Int = Swift.max(maxDateLength - date.count, 0)

            var line: String = identifier + [String](repeating: " ", count: identifierPadding).joined()
            line += " │ " + name + [String](repeating: " ", count: namePadding).joined()
            line += " │ " + version + [String](repeating: " ", count: versionPadding).joined()
            line += " │ " + build + [String](repeating: " ", count: buildPadding).joined()
            line += " │ " + [String](repeating: " ", count: sizePadding).joined() + sizeDescription
            line += " │ " + date + [String](repeating: " ", count: datePadding).joined()
            string += line + "\n"
        }

        return string
    }

    func firmwaresCSVString() -> String {
        "Signed,Name,Version,Build,Size,Date\n" + self.map { $0.firmwareCSVString() }.joined()
    }

    func productsCSVString() -> String {
        "Identifier,Name,Version,Build,Size,Date\n" + self.map { $0.productCSVString() }.joined()
    }

    func jsonString() throws -> String {
        let data: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)

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
