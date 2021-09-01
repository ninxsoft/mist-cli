//
//  HTTP.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Struct used to perform HTTP queries.
struct HTTP {

    /// Searches and retrieves a list of all macOS Firmwares that can be downloaded.
    ///
    /// - Returns: An array of macOS Firmwares.
    static func retrieveFirmwares() -> [Firmware] {
        var firmwares: [Firmware] = []

        let firmwaresURLString: String = Firmware.firmwaresURL

        guard let firmwaresURL: URL = URL(string: firmwaresURLString) else {
            PrettyPrint.print("There was an error retrieving firmwares from \(firmwaresURLString)...")
            return []
        }

        do {
            let string: String = try String(contentsOf: firmwaresURL, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let devices: [String: Any] = dictionary["devices"] as? [String: Any] else {
                PrettyPrint.print("There was an error retrieving firmwares from \(firmwaresURLString)...")
                return []
            }

            for (identifier, device) in devices {

                guard identifier.contains("Mac"),
                    let device: [String: Any] = device as? [String: Any],
                    let firmwaresArray: [[String: Any]] = device["firmwares"] as? [[String: Any]] else {
                    continue
                }

                for firmwareDictionary in firmwaresArray {
                    let firmwareData: Data = try JSONSerialization.data(withJSONObject: firmwareDictionary, options: .prettyPrinted)
                    let firmware: Firmware = try JSONDecoder().decode(Firmware.self, from: firmwareData)

                    if !firmwares.contains(where: { $0 == firmware }) {
                        firmwares.append(firmware)
                    }
                }
            }
        } catch {
            PrettyPrint.print(error.localizedDescription)
        }

        firmwares.sort { $0.version == $1.version ? ($0.build.count == $1.build.count ? $0.build > $1.build : $0.build.count > $1.build.count) : $0.version > $1.version }
        return firmwares
    }

    /// Retrieves the first macOS Firmware download match for the provided search string.
    ///
    /// - Parameters:
    ///   - firmwares: The array of possible macOS Firmwares that can be downloaded.
    ///   - download:  The download search string.
    ///
    /// - Returns: The first match of a macOS Firmware, otherwise nil.
    static func firmware(from firmwares: [Firmware], download: String) -> Firmware? {
        let download: String = download.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredFirmwaresByName: [Firmware] = firmwares.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "") == download }
        let filteredFirmwaresByVersion: [Firmware] = firmwares.filter { $0.version == download }
        let filteredFirmwaresByBuild: [Firmware] = firmwares.filter { $0.build.lowercased() == download }
        return filteredFirmwaresByName.first ?? filteredFirmwaresByVersion.first ?? filteredFirmwaresByBuild.first
    }

    /// Searches and retrieves a list of all macOS Installers that can be downloaded.
    ///
    /// - Parameters:
    ///   - catalogURL: The Apple Software Update catalog URL to base the search queriest against.
    ///
    /// - Returns: An array of macOS Installers.
    static func retrieveProducts(catalogURL: String) -> [Product] {
        var products: [Product] = []

        for catalog in Catalog.allCases {

            let catalogURL: String = catalog.url(for: catalogURL)

            PrettyPrint.print("Searching \(catalog.description) catalog...")

            guard let url: URL = URL(string: catalogURL) else {
                PrettyPrint.print("There was an error retrieving the catalog from \(catalogURL), skipping...")
                continue
            }

            do {
                let string: String = try String(contentsOf: url, encoding: .utf8)

                guard let data: Data = string.data(using: .utf8) else {
                    PrettyPrint.print("Unable to get data from catalog, skipping...")
                    continue
                }

                var format: PropertyListSerialization.PropertyListFormat = .xml

                guard let catalog: [String: Any] = try PropertyListSerialization.propertyList(from: data, options: [.mutableContainers], format: &format) as? [String: Any],
                    let productsDictionary: [String: Any] = catalog["Products"] as? [String: Any] else {
                    PrettyPrint.print("Unable to get 'Products' dictionary from catalog, skipping...")
                    continue
                }

                products.append(contentsOf: getProducts(from: productsDictionary).filter { !products.map { $0.identifier }.contains($0.identifier) })
            } catch {
                PrettyPrint.print(error.localizedDescription)
            }
        }

        products.sort { $0.version == $1.version ? ($0.build.count == $1.build.count ? $0.build > $1.build : $0.build.count > $1.build.count) : $0.version > $1.version }
        return products
    }

    /// Filters and extracts a list of macOS Installers from the Apple Software Update Catalog Property List.
    ///
    /// - Parameters:
    ///   - dictionary: The dictionary values obtained from the Apple Software Update Catalog Property List.
    ///
    /// - Returns: The filtered list of macOS Installers.
    private static func getProducts(from dictionary: [String: Any]) -> [Product] {

        var products: [Product] = []
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var format: PropertyListSerialization.PropertyListFormat = .xml

        for (key, value) in dictionary {

            guard var value: [String: Any] = value as? [String: Any],
                let date: Date = value["PostDate"] as? Date,
                let extendedMetaInfo: [String: Any] = value["ExtendedMetaInfo"] as? [String: Any],
                extendedMetaInfo["InstallAssistantPackageIdentifiers"] as? [String: Any] != nil else {
                continue
            }

            guard let distributions: [String: Any] = value["Distributions"] as? [String: Any],
                let distributionURL: String = distributions["English"] as? String,
                let url: URL = URL(string: distributionURL) else {
                PrettyPrint.print("No English distribution found, skipping...")
                continue
            }

            do {
                let string: String = try productPropertyList(from: url)

                guard let distributionData: Data = string.data(using: .utf8),
                    let distribution: [String: Any] = try PropertyListSerialization.propertyList(from: distributionData, options: [.mutableContainers], format: &format) as? [String: Any],
                    let name: String = distribution["NAME"] as? String,
                    let version: String = distribution["VERSION"] as? String,
                    let build: String = distribution["BUILD"] as? String else {
                    PrettyPrint.print("No 'Name', 'Version' or 'Build' found, skipping...")
                    continue
                }

                value["Identifier"] = key
                value["Name"] = name
                value["Version"] = version
                value["Build"] = build
                value["PostDate"] = dateFormatter.string(from: date)
                value["DistributionURL"] = distributionURL

                // JSON object creation freaks out with the default DeferredSUEnablementDate date format
                value.removeValue(forKey: "DeferredSUEnablementDate")

                let productData: Data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                let product: Product = try JSONDecoder().decode(Product.self, from: productData)
                products.append(product)
            } catch {
                PrettyPrint.print(error.localizedDescription)
            }
        }

        return products
    }

    /// Converts the contents of a macOS Installer distribution URL into a workable Property List format.
    ///
    /// - Parameters:
    ///   - url: The macOS Installer distribution URL.
    ///
    /// - Throws: An `Error` if the contents of the macOS Installer distribution URL are invalid.
    ///
    /// - Returns: A macOS Installer Property List.
    private static func productPropertyList(from url: URL) throws -> String {
        let distributionString: String = try String(contentsOf: url, encoding: .utf8)

        let name: String = distributionString.replacingOccurrences(of: "^[\\s\\S]*suDisabledGroupID=\"", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\"[\\s\\S]*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "Install ", with: "")

        let string: String = distributionString.replacingOccurrences(of: "^[\\s\\S]*<auxinfo>\\s*", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s*</auxinfo>[\\s\\S]*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "</dict>", with: "<key>NAME</key><string>\(name)</string></dict>")
            .wrappedInPropertyList()

        return string
    }

    /// Retrieves the first macOS Installer download match for the provided search string.
    ///
    /// - Parameters:
    ///   - products: The array of possible macOS Installers that can be downloaded.
    ///   - download: The download search string.
    ///
    /// - Returns: The first match of a macOS Installer, otherwise `nil`.
    static func product(from products: [Product], download: String) -> Product? {
        let download: String = download.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredProductsByName: [Product] = products.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "") == download }
        let filteredProductsByVersion: [Product] = products.filter { $0.version == download }
        let filteredProductsByBuild: [Product] = products.filter { $0.build.lowercased() == download }
        return filteredProductsByName.first ?? filteredProductsByVersion.first ?? filteredProductsByBuild.first
    }
}
