//
//  HTTP.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct HTTP {

    static func retrieveProducts() -> [Product] {

        var products: [Product] = []

        for catalogURL in String.catalogURLs {

            PrettyPrint.print(.info, string: "Downloading catalog \(catalogURL)...")

            guard let url: URL = URL(string: catalogURL) else {
                PrettyPrint.print(.warning, string: "There was an error retrieving the catalog \(catalogURL), skipping...")
                continue
            }

            do {
                let string: String = try String(contentsOf: url, encoding: .utf8)

                guard let data: Data = string.data(using: .utf8) else {
                    PrettyPrint.print(.warning, string: "Unable to get data from catalog, skipping...")
                    continue
                }

                var format: PropertyListSerialization.PropertyListFormat = .xml

                guard let catalog: [String: Any] = try PropertyListSerialization.propertyList(from: data, options: [.mutableContainers], format: &format) as? [String: Any],
                    let productsDictionary: [String: Any] = catalog["Products"] as? [String: Any] else {
                    PrettyPrint.print(.warning, string: "Unable to get 'Products' dictionary from catalog, skipping...")
                    continue
                }

                products.append(contentsOf: getProducts(from: productsDictionary).filter { !products.map { $0.identifier }.contains($0.identifier) })
            } catch {
                PrettyPrint.print(.warning, string: error.localizedDescription)
            }
        }

        products.sort { $0.version == $1.version ? ($0.build.count == $1.build.count ? $0.build > $1.build : $0.build.count > $1.build.count) : $0.version > $1.version }
        return products
    }

    private static func getProducts(from dictionary: [String: Any]) -> [Product] {

        var products: [Product] = []
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

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
                PrettyPrint.print(.warning, string: "No English distribution found, skipping...")
                continue
            }

            var format: PropertyListSerialization.PropertyListFormat = .xml

            do {
                var distributionString: String = try String(contentsOf: url, encoding: .utf8)
                distributionString = distributionString.replacingOccurrences(of: "(?m)^[\\s\\S]*<auxinfo>\\s*", with: "", options: .regularExpression)
                distributionString = distributionString.replacingOccurrences(of: "(?m)\\s*</auxinfo>[\\s\\S]*$", with: "", options: .regularExpression)
                distributionString.wrapInPropertyList()

                guard let distributionData: Data = distributionString.data(using: .utf8),
                    let distribution: [String: Any] = try PropertyListSerialization.propertyList(from: distributionData, options: [.mutableContainers], format: &format) as? [String: Any],
                    let version: String = distribution["VERSION"] as? String,
                    let build: String = distribution["BUILD"] as? String else {
                    PrettyPrint.print(.warning, string: "No 'Version' or 'Build' found, skipping...")
                    continue
                }

                value["Identifier"] = key
                value["Version"] = version
                value["Build"] = build
                value["PostDate"] = dateFormatter.string(from: date)
                value["DistributionURL"] = distributionURL

                let productData: Data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                let product: Product = try JSONDecoder().decode(Product.self, from: productData)
                products.append(product)
            } catch {
                PrettyPrint.print(.error, string: error.localizedDescription)
            }
        }

        return products
    }

    static func product(from products: [Product], name: String, version: String, build: String) -> Product? {

        guard name.lowercased() != "latest" else {
            return products.first
        }

        let productsFilteredByName: [Product] = products.filter { $0.name.lowercased().contains(name.lowercased()) }

        guard version.lowercased() != "latest" else {
            return productsFilteredByName.first
        }

        let productsFilteredByBuild: [Product] = productsFilteredByName.filter { $0.version.lowercased().contains(version.lowercased()) }

        guard build.lowercased() != "latest" else {
            return productsFilteredByBuild.first
        }

        return productsFilteredByBuild.first { $0.build.lowercased() == build.lowercased() }
    }
}
