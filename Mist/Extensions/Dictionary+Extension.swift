//
//  Dictionary+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 31/8/21.
//

import Foundation
import Yams

extension Dictionary where Key == String {
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

    func installerCSVString() -> String {
        guard
            let identifier: String = self["identifier"] as? String,
            let name: String = self["name"] as? String,
            let version: String = self["version"] as? String,
            let build: String = self["build"] as? String,
            let size: Int64 = self["size"] as? Int64,
            let date: String = self["date"] as? String else {
            return ""
        }

        let string: String = "\"\(identifier)\",\"\(name)\",\"=\"\"\(version)\"\"\",\"=\"\"\(build)\"\"\",\(size),\(date)\n"
        return string
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
