//
//  HTTP.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct HTTP {

    static func retrieveFirmwares() -> [Firmware] {
        var firmwares: [Firmware] = []

        let devicesURLString: String = Firmware.devicesURL

        PrettyPrint.print("Retrieving list of compatible devices...")

        guard let devicesURL: URL = URL(string: devicesURLString) else {
            PrettyPrint.print("There was an error retrieving devices from \(devicesURLString)...")
            return []
        }

        do {
            let string: String = try String(contentsOf: devicesURL, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8) else {
                PrettyPrint.print("There was an error retrieving devices from \(devicesURLString)...")
                return []
            }

            if let devices: [[String: Any]] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                for device in devices {
                    guard let name: String = device["name"] as? String,
                        let identifier: String = device["identifier"] as? String,
                        identifier.contains("Mac") else {
                        continue
                    }

                    PrettyPrint.print("Retrieving firmware versions for '\(name)'...")

                    let deviceURLString: String = Firmware.deviceURL(for: identifier)

                    guard let deviceURL: URL = URL(string: deviceURLString) else {
                        PrettyPrint.print("There was an error retrieving firmware versions for '\(name)'...")
                        continue
                    }

                    let string: String = try String(contentsOf: deviceURL, encoding: .utf8)

                    guard let data: Data = string.data(using: .utf8) else {
                        PrettyPrint.print("There was an error retrieving firmware versions for '\(name)'...")
                        continue
                    }

                    if let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                        let firmwaresArray: [[String: Any]] = dictionary["firmwares"] as? [[String: Any]] {

                        for firmwareDictionary in firmwaresArray {
                            let firmwareData: Data = try JSONSerialization.data(withJSONObject: firmwareDictionary, options: .prettyPrinted)
                            let firmware: Firmware = try JSONDecoder().decode(Firmware.self, from: firmwareData)

                            if !firmwares.contains(where: { $0 == firmware }) {
                                firmwares.append(firmware)
                            }
                        }
                    }
                }
            } else {
                PrettyPrint.print("There was an error retrieving devices from \(devicesURLString)...")
            }
        } catch {
            PrettyPrint.print(error.localizedDescription)
        }

        firmwares.sort { $0.version == $1.version ? ($0.build.count == $1.build.count ? $0.build > $1.build : $0.build.count > $1.build.count) : $0.version > $1.version }
        return firmwares
    }

    static func firmware(from firmwares: [Firmware], download: String) -> Firmware? {
        let download: String = download.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredFirmwaresByName: [Firmware] = firmwares.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "") == download }
        let filteredFirmwaresByVersion: [Firmware] = firmwares.filter { $0.version == download }
        let filteredFirmwaresByBuild: [Firmware] = firmwares.filter { $0.build.lowercased() == download }
        return filteredFirmwaresByName.first ?? filteredFirmwaresByVersion.first ?? filteredFirmwaresByBuild.first ?? nil
    }

    static func retrieveProducts(catalogURL: String) -> [Product] {
        var products: [Product] = []

        for catalog in Catalog.CatalogType.allCases {

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

    static func product(from products: [Product], download: String) -> Product? {
        let download: String = download.lowercased().replacingOccurrences(of: "macos ", with: "")
        let filteredProductsByName: [Product] = products.filter { $0.name.lowercased().replacingOccurrences(of: "macos ", with: "") == download }
        let filteredProductsByVersion: [Product] = products.filter { $0.version == download }
        let filteredProductsByBuild: [Product] = products.filter { $0.build.lowercased() == download }
        return filteredProductsByName.first ?? filteredProductsByVersion.first ?? filteredProductsByBuild.first ?? nil
    }
}
