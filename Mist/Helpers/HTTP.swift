//
//  HTTP.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

// swiftlint:disable file_length

/// Helper Struct used to perform HTTP queries.
struct HTTP {

    // swiftlint:disable cyclomatic_complexity

    /// Searches and retrieves a list of all macOS Firmwares that can be downloaded.
    ///
    /// - Parameters:
    ///   - includeBetas:      Set to `true` to prevent skipping of macOS Firmwares in search results.
    ///   - compatible:        Set to `true` to filter down compatible macOS Firmwares in search results.
    ///   - metadataCachePath: Path to cache the macOS Firmwares metadata JSON file.
    ///   - noAnsi:            Set to `true` to print the string without any color or formatting.
    ///   - quiet:             Set to `true` to suppress verbose output.
    ///
    /// - Returns: An array of macOS Firmwares.
    static func retrieveFirmwares(includeBetas: Bool, compatible: Bool, metadataCachePath: String, noAnsi: Bool, quiet: Bool = false) -> [Firmware] {
        var firmwares: [Firmware] = []

        do {
            var devices: [String: Any] = [:]
            let metadataURL: URL = URL(fileURLWithPath: metadataCachePath)

            if let url: URL = URL(string: Firmware.firmwaresURL),
                let (string, dictionary): (String, [String: Any]) = try retrieveMetadata(url, noAnsi: noAnsi, quiet: quiet) {
                devices = dictionary
                let directory: URL = metadataURL.deletingLastPathComponent()

                if !FileManager.default.fileExists(atPath: directory.path) {
                    !quiet ? PrettyPrint.print("Creating parent directory '\(directory.path)'...", noAnsi: noAnsi) : Mist.noop()
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                }

                !quiet ? PrettyPrint.print("Caching macOS Firmware metadata to '\(metadataCachePath)'...", noAnsi: noAnsi) : Mist.noop()
                try string.write(to: metadataURL, atomically: true, encoding: .utf8)
            } else if FileManager.default.fileExists(atPath: metadataURL.path) {
                !quiet ? PrettyPrint.print("Retrieving macOS Firmware metadata from '\(metadataCachePath)'...", noAnsi: noAnsi) : Mist.noop()

                if let (_, dictionary): (String, [String: Any]) = try retrieveMetadata(metadataURL, noAnsi: noAnsi, quiet: quiet) {
                    devices = dictionary
                }
            } else {
                !quiet ? PrettyPrint.print("Unable to retrieve macOS Firmware metadata from missing cache '\(metadataCachePath)'", noAnsi: noAnsi, prefixColor: .red) : Mist.noop()
            }

            let supportedBuilds: [String] = Firmware.supportedBuilds()

            for (identifier, device) in devices {

                guard identifier.contains("Mac"),
                    let device: [String: Any] = device as? [String: Any],
                    let firmwaresArray: [[String: Any]] = device["firmwares"] as? [[String: Any]] else {
                    continue
                }

                for var firmwareDictionary in firmwaresArray {
                    firmwareDictionary["compatible"] = supportedBuilds.contains(firmwareDictionary["buildid"] as? String ?? "")
                    let firmwareData: Data = try JSONSerialization.data(withJSONObject: firmwareDictionary, options: .prettyPrinted)
                    let firmware: Firmware = try JSONDecoder().decode(Firmware.self, from: firmwareData)

                    if !firmware.shasum.isEmpty,
                        !firmwares.contains(where: { $0 == firmware }) {
                        firmwares.append(firmware)
                    }
                }
            }
        } catch {
            !quiet ? PrettyPrint.print(error.localizedDescription, noAnsi: noAnsi, prefixColor: .red) : Mist.noop()
        }

        if !includeBetas {
            firmwares = firmwares.filter { !$0.beta }
        }

        if compatible {
            firmwares = firmwares.filter { $0.compatible }
        }

        firmwares.sort { $0.version == $1.version ? $0.date > $1.date : $0.version > $1.version }
        return firmwares
    }

    // swiftlint:enable cyclomatic_complexity

    /// Retrieves a dictionary containing macOS Firmwares metadata.
    ///
    /// - Parameters:
    ///   - url:    URL to the macOS Firmwares metadata JSON file.
    ///   - noAnsi: Set to `true` to print the string without any color or formatting.
    ///   - quiet:  Set to `true` to suppress verbose output.
    ///
    /// - Throws: An error if the macOS Firmwares metadata cannot be retrieved.
    ///
    /// - Returns: A dictionary of macOS Firmwares metadata.
    private static func retrieveMetadata(_ url: URL, noAnsi: Bool, quiet: Bool) throws -> (String, [String: Any])? {
        let string: String = try String(contentsOf: url, encoding: .utf8)

        guard let data: Data = string.data(using: .utf8),
            let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let devices: [String: Any] = dictionary["devices"] as? [String: Any] else {
            let path: String = url.absoluteString.replacingOccurrences(of: "file://", with: "")
            !quiet ? PrettyPrint.print("There was an error retrieving macOS Firmware metadata from '\(path)'", noAnsi: noAnsi, prefixColor: .red) : Mist.noop()

            if url.scheme == "https" {
                !quiet ? PrettyPrint.print("This may indicate the API is being updated, please try again shortly...", noAnsi: noAnsi) : Mist.noop()
            }

            return nil
        }

        return (string, devices)
    }

    /// Retrieves the first macOS Firmware download match for the provided search string.
    ///
    /// - Parameters:
    ///   - firmwares:    The array of possible macOS Firmwares that can be downloaded.
    ///   - searchString: The download search string.
    ///
    /// - Returns: The first match of a macOS Firmware, otherwise nil.
    static func firmware(from firmwares: [Firmware], searchString: String) -> Firmware? {
        let searchString: String = searchString.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredFirmwaresByName: [Firmware] = firmwares.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "").contains(searchString) }
        let filteredFirmwaresByVersion: [Firmware] = firmwares.filter { searchString.contains(".") ? $0.version.lowercased() == searchString : $0.version.lowercased().contains(searchString) }
        let filteredFirmwaresByBuild: [Firmware] = firmwares.filter { $0.build.lowercased().contains(searchString) }
        return filteredFirmwaresByName.first ?? filteredFirmwaresByVersion.first ?? filteredFirmwaresByBuild.first
    }

    /// Retrieves macOS Firmware downloads matching the provided search string.
    ///
    /// - Parameters:
    ///   - firmwares:    The array of possible macOS Firmwares that can be downloaded.
    ///   - searchString: The download search string.
    ///
    /// - Returns: An array of macOS Firmware matches.
    static func firmwares(from firmwares: [Firmware], searchString: String) -> [Firmware] {
        let searchString: String = searchString.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredFirmwaresByName: [Firmware] = firmwares.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "").contains(searchString) }
        let filteredFirmwaresByVersion: [Firmware] = firmwares.filter { $0.version.lowercased().contains(searchString) }
        let filteredFirmwaresByBuild: [Firmware] = firmwares.filter { $0.build.lowercased().contains(searchString) }
        return filteredFirmwaresByName + filteredFirmwaresByVersion + filteredFirmwaresByBuild
    }

    /// Searches and retrieves a list of all macOS Installers that can be downloaded.
    ///
    /// - Parameters:
    ///   - catalogURLs:  The Apple Software Update catalog URLs to base the search queries against.
    ///   - includeBetas: Set to `true` to prevent skipping of macOS Installers in search results.
    ///   - compatible:   Set to `true` to filter down compatible macOS Installers in search results.
    ///   - noAnsi:       Set to `true` to print the string without any color or formatting.
    ///   - quiet:        Set to `true` to suppress verbose output.
    ///
    /// - Returns: An array of macOS Installers.
    static func retrieveInstallers(from catalogURLs: [String], includeBetas: Bool, compatible: Bool, noAnsi: Bool, quiet: Bool = false) -> [Installer] {
        var installers: [Installer] = []

        for catalogURL in catalogURLs {

            guard let url: URL = URL(string: catalogURL) else {
                !quiet ? PrettyPrint.print("There was an error retrieving the catalog from \(catalogURL), skipping...", noAnsi: noAnsi) : Mist.noop()
                continue
            }

            do {
                let string: String = try String(contentsOf: url, encoding: .utf8)

                guard let data: Data = string.data(using: .utf8) else {
                    !quiet ? PrettyPrint.print("Unable to get data from catalog, skipping...", noAnsi: noAnsi) : Mist.noop()
                    continue
                }

                var format: PropertyListSerialization.PropertyListFormat = .xml

                guard let catalog: [String: Any] = try PropertyListSerialization.propertyList(from: data, options: [.mutableContainers], format: &format) as? [String: Any],
                    let installersDictionary: [String: Any] = catalog["Products"] as? [String: Any] else {
                    !quiet ? PrettyPrint.print("Unable to get 'Products' dictionary from catalog, skipping...", noAnsi: noAnsi) : Mist.noop()
                    continue
                }

                installers.append(contentsOf: getInstallers(from: installersDictionary, noAnsi: noAnsi, quiet: quiet).filter { !installers.map { $0.identifier }.contains($0.identifier) })
            } catch {
                !quiet ? PrettyPrint.print(error.localizedDescription, noAnsi: noAnsi, prefixColor: .red) : Mist.noop()
            }
        }

        installers.append(contentsOf: Installer.legacyInstallers)

        if !includeBetas {
            installers = installers.filter { !$0.beta }
        }

        if compatible {
            installers = installers.filter { $0.compatible }
        }

        installers.sort { $0.version == $1.version ? $0.date > $1.date : $0.version.compare($1.version, options: .numeric) == .orderedDescending }
        return installers
    }

    /// Filters and extracts a list of macOS Installers from the Apple Software Update Catalog Property List.
    ///
    /// - Parameters:
    ///   - dictionary: The dictionary values obtained from the Apple Software Update Catalog Property List.
    ///   - noAnsi:     Set to `true` to print the string without any color or formatting.
    ///   - quiet:      Set to `true` to suppress verbose output.
    ///
    /// - Returns: The filtered list of macOS Installers.
    private static func getInstallers(from dictionary: [String: Any], noAnsi: Bool, quiet: Bool) -> [Installer] {

        var installers: [Installer] = []
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for (key, value) in dictionary {

            guard var value: [String: Any] = value as? [String: Any],
                let date: Date = value["PostDate"] as? Date,
                let extendedMetaInfo: [String: Any] = value["ExtendedMetaInfo"] as? [String: Any],
                extendedMetaInfo["InstallAssistantPackageIdentifiers"] as? [String: Any] != nil,
                let distributions: [String: Any] = value["Distributions"] as? [String: Any],
                let distributionURL: String = distributions["English"] as? String,
                let url: URL = URL(string: distributionURL) else {
                continue
            }

            do {
                let string: String = try String(contentsOf: url, encoding: .utf8)

                guard let name: String = nameFromDistribution(string),
                    let version: String = versionFromDistribution(string),
                    let build: String = buildFromDistribution(string),
                    !name.isEmpty && !version.isEmpty && !build.isEmpty else {
                    !quiet ? PrettyPrint.print("No 'Name', 'Version' or 'Build' found, skipping...", noAnsi: noAnsi) : Mist.noop()
                    continue
                }

                let boardIDs: [String] = boardIDsFromDistribution(string)
                let deviceIDs: [String] = deviceIDsFromDistribution(string)
                let unsupportedModelIdentifiers: [String] = unsupportedModelIdentifiersFromDistribution(string)

                value["Identifier"] = key
                value["Name"] = name
                value["Version"] = version
                value["Build"] = build
                value["BoardIDs"] = boardIDs
                value["DeviceIDs"] = deviceIDs
                value["UnsupportedModelIdentifiers"] = unsupportedModelIdentifiers
                value["PostDate"] = dateFormatter.string(from: date)
                value["DistributionURL"] = distributionURL

                // JSON object creation freaks out with the default DeferredSUEnablementDate date format
                value.removeValue(forKey: "DeferredSUEnablementDate")

                let installerData: Data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                let installer: Installer = try JSONDecoder().decode(Installer.self, from: installerData)
                installers.append(installer)
            } catch {
                !quiet ? PrettyPrint.print(error.localizedDescription, noAnsi: noAnsi, prefixColor: .red) : Mist.noop()
            }
        }

        return installers
    }

    /// Returns the macOS Installer **Name** value from the provided distribution file string.
    ///
    /// - Parameters:
    ///   - string: The distribution string.
    ///
    /// - Returns: The macOS Installer **Name** string if present, otherwise `nil`.
    private static func nameFromDistribution(_ string: String) -> String? {

        guard string.contains("suDisabledGroupID") else {
            return nil
        }

        return string.replacingOccurrences(of: "^[\\s\\S]*suDisabledGroupID=\"", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\"[\\s\\S]*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "Install ", with: "")
    }

    /// Returns the macOS Installer **Version** value from the provided distribution file string.
    ///
    /// - Parameters:
    ///   - string: The distribution string.
    ///
    /// - Returns: The macOS Installer **Version** string if present, otherwise `nil`.
    private static func versionFromDistribution(_ string: String) -> String? {

        guard string.contains("<key>VERSION</key>") else {
            return nil
        }

        return string.replacingOccurrences(of: "^[\\s\\S]*<key>VERSION<\\/key>\\s*<string>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<\\/string>[\\s\\S]*$", with: "", options: .regularExpression)
    }

    /// Returns the macOS Installer **Build** value from the provided distribution file string.
    ///
    /// - Parameters:
    ///   - string: The distribution string.
    ///
    /// - Returns: The macOS Installer **Build** string if present, otherwise `nil`.
    private static func buildFromDistribution(_ string: String) -> String? {

        guard string.contains("<key>BUILD</key>") else {
            return nil
        }

        return string.replacingOccurrences(of: "^[\\s\\S]*<key>BUILD<\\/key>\\s*<string>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<\\/string>[\\s\\S]*$", with: "", options: .regularExpression)
    }

    /// Returns the macOS Installer **Board ID** values from the provided distribution file string.
    ///
    /// - Parameters:
    ///   - string: The distribution string.
    ///
    /// - Returns: An array of **Board ID** strings.
    private static func boardIDsFromDistribution(_ string: String) -> [String] {

        guard string.contains("supportedBoardIDs") || string.contains("boardIds") else {
            return []
        }

        return string.replacingOccurrences(of: "^[\\s\\S]*(supportedBoardIDs|boardIds) = \\[", with: "", options: .regularExpression)
            .replacingOccurrences(of: ",?\\];[\\s\\S]*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
            .sorted()
    }

    /// Returns the macOS Installer **Device ID** values from the provided distribution file string.
    ///
    /// - Parameters:
    ///   - string: The distribution string.
    ///
    /// - Returns: An array of **Device ID** strings.
    private static func deviceIDsFromDistribution(_ string: String) -> [String] {

        guard string.contains("supportedDeviceIDs") else {
            return []
        }

        return string.replacingOccurrences(of: "^[\\s\\S]*supportedDeviceIDs = \\[", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\];[\\s\\S]*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: " ", with: "")
            .uppercased()
            .components(separatedBy: ",")
            .sorted()
    }

    /// Returns the macOS Installer **Unsupported Model Identifier** values from the provided distribution file string.
    ///
    /// - Parameters:
    ///   - string: The distribution string.
    ///
    /// - Returns: An array of **Unsupported Model Identifier** strings.
    private static func unsupportedModelIdentifiersFromDistribution(_ string: String) -> [String] {

        guard string.contains("nonSupportedModels") else {
            return []
        }

        return string.replacingOccurrences(of: "^[\\s\\S]*nonSupportedModels = \\[", with: "", options: .regularExpression)
            .replacingOccurrences(of: ",?\\];[\\s\\S]*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "','", with: "'|'")
            .replacingOccurrences(of: "'", with: "")
            .components(separatedBy: "|")
            .sorted()
    }

    /// Retrieves the first macOS Installer download match for the provided search string.
    ///
    /// - Parameters:
    ///   - installers:   The array of possible macOS Installers that can be downloaded.
    ///   - searchString: The download search string.
    ///
    /// - Returns: The first match of a macOS Installer, otherwise `nil`.
    static func installer(from installers: [Installer], searchString: String) -> Installer? {
        let searchString: String = searchString.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredInstallersByName: [Installer] = installers.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "").contains(searchString) }
        let filteredInstallersByVersion: [Installer] = installers.filter { searchString.contains(".") ? $0.version.lowercased() == searchString : $0.version.lowercased().contains(searchString) }
        let filteredInstallersByBuild: [Installer] = installers.filter { $0.build.lowercased().contains(searchString) }
        return filteredInstallersByName.first ?? filteredInstallersByVersion.first ?? filteredInstallersByBuild.first
    }

    /// Retrieves macOS Installer downloads matching the provided search string.
    ///
    /// - Parameters:
    ///   - installers:   The array of possible macOS Installers that can be downloaded.
    ///   - searchString: The download search string.
    ///
    /// - Returns: An array of macOS Installer matches.
    static func installers(from installers: [Installer], searchString: String) -> [Installer] {
        let searchString: String = searchString.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredInstallersByName: [Installer] = installers.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "").contains(searchString) }
        let filteredInstallersByVersion: [Installer] = installers.filter { $0.version.lowercased().contains(searchString) }
        let filteredInstallersByBuild: [Installer] = installers.filter { $0.build.lowercased().contains(searchString) }
        return filteredInstallersByName + filteredInstallersByVersion + filteredInstallersByBuild
    }
}
