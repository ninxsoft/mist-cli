//
//  MistError.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

enum MistError: Error {
    case invalidUser
    case invalidOutputOption
    case missingCSVPath
    case missingJSONPath
    case missingPLISTPath
    case missingYAMLPath
    case missingPackageIdentifier
    case notEnoughFreeSpace(free: Int64, required: Int64)
    case invalidData
    case invalidURL(url: String)
    case invalidExitStatus(code: Int32, arguments: [String])

    var description: String {
        switch self {
        case .invalidUser:
            return "This command requires to be run as 'root'."
        case .invalidOutputOption:
            return "Invalid output option."
        case .missingCSVPath:
            return "CSV path is missing."
        case .missingJSONPath:
            return "JSON path is missing."
        case .missingPLISTPath:
            return "PLIST path is missing."
        case .missingYAMLPath:
            return "YAML path is missing."
        case .missingPackageIdentifier:
            return "Package identifier is missing."
        case .notEnoughFreeSpace(let free, let required):
            return String(format: "Not enough free space: %0.1fGB free, %0.1fGB required", free.toGigabytes(), required.toGigabytes())
        case .invalidData:
            return "Invalid data."
        case .invalidURL(let url):
            return "Invalid URL: '\(url)'"
        case .invalidExitStatus(let code, let arguments):
            return "Invalid Exit Status Code: '\(code)', Arguments: \(arguments)"
        }
    }
}
