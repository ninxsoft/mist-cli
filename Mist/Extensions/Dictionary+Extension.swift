//
//  Dictionary+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 31/8/21.
//

import Foundation
import Yams

extension Dictionary where Key == String {
    /// Returns a CSV-formatted string for the provided `Firmware` dictionary.
    ///
    /// - Returns: A CSV-formatted string for the provided `Firmware` dictionary.
    func firmwareCSVString() -> String {
        guard
            let name: String = self["name"] as? String,
            let version: String = self["version"] as? String,
            let build: String = self["build"] as? String,
            let size: Int64 = self["size"] as? Int64,
            let url: String = self["url"] as? String,
            let date: String = self["date"] as? String,
            let compatible: Bool = self["compatible"] as? Bool,
            let signed: Bool = self["signed"] as? Bool,
            let beta: Bool = self["beta"] as? Bool else {
            return ""
        }

        let nameString: String = "\"\(name)\""
        let versionString: String = "\"=\"\"\(version)\"\"\""
        let buildString: String = "\"=\"\"\(build)\"\"\""
        let sizeString: String = "\(size)"
        let urlString: String = "\"=\"\"\(url)\"\"\""
        let dateString: String = "\(date)"
        let compatibleString: String = "\(compatible ? "YES" : "NO")"
        let signedString: String = "\(signed ? "YES" : "NO")"
        let betaString: String = "\(beta ? "YES" : "NO")"

        let string: String = [
            nameString,
            versionString,
            buildString,
            sizeString,
            urlString,
            dateString,
            compatibleString,
            signedString,
            betaString
        ].joined(separator: ",") + "\n"
        return string
    }

    /// Returns a CSV-formatted string for the provided `Installer` dictionary.
    ///
    /// - Returns: A CSV-formatted string for the provided `Installer` dictionary.
    func installerCSVString() -> String {
        guard
            let identifier: String = self["identifier"] as? String,
            let name: String = self["name"] as? String,
            let version: String = self["version"] as? String,
            let build: String = self["build"] as? String,
            let size: Int64 = self["size"] as? Int64,
            let date: String = self["date"] as? String,
            let compatible: Bool = self["compatible"] as? Bool,
            let beta: Bool = self["beta"] as? Bool else {
            return ""
        }

        let identifierString: String = "\"\(identifier)\""
        let nameString: String = "\"\(name)\""
        let versionString: String = "\"=\"\"\(version)\"\"\""
        let buildString: String = "\"=\"\"\(build)\"\"\""
        let sizeString: String = "\(size)"
        let dateString: String = "\(date)"
        let compatibleString: String = "\(compatible ? "YES" : "NO")"
        let betaString: String = "\(beta ? "YES" : "NO")"

        let string: String = [
            identifierString,
            nameString,
            versionString,
            buildString,
            sizeString,
            dateString,
            compatibleString,
            betaString
        ].joined(separator: ",") + "\n"
        return string
    }

    /// Returns a JSON string for the provided dictionary.
    ///
    /// - Throws: An error if the JSON string cannot be created.
    ///
    /// - Returns: A JSON string for the provided dictionary.
    func jsonString() throws -> String {
        let data: Data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys])
        let string: String = .init(decoding: data, as: UTF8.self)
        return string
    }

    /// Returns a Property List string for the provided dictionary.
    ///
    /// - Throws: An error if the Property List string cannot be created.
    ///
    /// - Returns: A Propery List string for the provided dictionary.
    func propertyListString() throws -> String {
        let data: Data = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: .bitWidth)
        let string: String = .init(decoding: data, as: UTF8.self)
        return string
    }

    /// Returns a YAML string for the provided dictionary.
    ///
    /// - Throws: An error if the YAML string cannot be created.
    ///
    /// - Returns: A YAML string for the provided dictionary.
    func yamlString() throws -> String {
        try Yams.dump(object: self)
    }
}
