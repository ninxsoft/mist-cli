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
    case missingExportPath
    case missingExportFormat
    case missingPackageIdentifier
    case notEnoughFreeSpace(free: Int64, required: Int64)
    case invalidData
    case invalidURL(string: String)
    case invalidURLResponse
    case invalidHTTPStatusCode(code: Int)
    case invalidExitStatus(code: Int32, arguments: [String])

    var description: String {
        switch self {
        case .invalidUser:
            return "This command requires to be run as 'root'."
        case .invalidOutputOption:
            return "Invalid output option."
        case .missingExportPath:
            return "Export path is missing."
        case .missingExportFormat:
            return "Export format is missing."
        case .missingPackageIdentifier:
            return "Package identifier is missing."
        case .notEnoughFreeSpace(let free, let required):
            return String(format: "Not enough free space: %0.1fGB free, %0.1fGB required", free.toGigabytes(), required.toGigabytes())
        case .invalidData:
            return "Invalid data."
        case .invalidURL(let string):
            return "Invalid URL: '\(string)'"
        case .invalidURLResponse:
            return "Invalid URL Response"
        case .invalidHTTPStatusCode(let code):
            return "Invalid HTTP Status Code: '\(code)'"
        case .invalidExitStatus(let code, let arguments):
            return "Invalid Exit Status Code: '\(code)', Arguments: \(arguments)"
        }
    }
}
