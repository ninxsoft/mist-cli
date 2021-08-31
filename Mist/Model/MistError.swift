//
//  MistError.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

enum MistError: Error {
    case invalidUser
    case missingExportPath
    case invalidExportFileExtension
    case missingDownloadType
    case missingFirmwareName
    case missingOutputType
    case missingApplicationName
    case missingImageName
    case missingImageSigningIdentity
    case missingPackageName
    case missingPackageIdentifier
    case missingPackageSigningIdentity
    case missingOutputDirectory
    case notEnoughFreeSpace(volume: String, free: Int64, required: Int64)
    case invalidData
    case invalidExitStatus(code: Int32, arguments: [String])
    case invalidShasum(invalid: String, valid: String)
    case invalidURL(url: String)

    var description: String {
        switch self {
        case .invalidUser:
            return "This command requires to be run as 'root'."
        case .missingExportPath:
            return "[-e, --export] Export path is missing or empty."
        case .invalidExportFileExtension:
            return "Export file extension is invalid."
        case .missingDownloadType:
            return "Download type is missing or empty."
        case .missingFirmwareName:
            return "[--firmware-name] macOS Restore Firmware output filename is missing or empty."
        case .missingOutputType:
            return "[--application || --image || --package] Output type is missing."
        case .missingApplicationName:
            return "[--application-name] macOS Installer output filename is missing or empty."
        case .missingImageName:
            return "[--image-name] macOS Disk Image output filename is missing or empty."
        case .missingImageSigningIdentity:
            return "[--image-signing-identity] macOS Disk Image signing identity is missing or empty."
        case .missingPackageName:
            return "[--package-name] macOS Installer Package output filename is missing or empty."
        case .missingPackageIdentifier:
            return "[--package-identifier] macOS Installer Package identifier is missing or empty."
        case .missingPackageSigningIdentity:
            return "[--package-signing-identity] macOS Installer Package signing identity is missing or empty."
        case .missingOutputDirectory:
            return "[-o, --output-directory] Output directory is missing or empty."
        // swiftlint:disable:next explicit_type_interface
        case .notEnoughFreeSpace(let volume, let free, let required):
            return String(format: "Not enough free space on volume '\(volume)': %0.1fGB free, %0.1fGB required", free.toGigabytes(), required.toGigabytes())
        case .invalidData:
            return "Invalid data."
        // swiftlint:disable:next explicit_type_interface
        case .invalidExitStatus(let code, let arguments):
            return "Invalid Exit Status Code: '\(code)', Arguments: \(arguments)"
        // swiftlint:disable:next explicit_type_interface
        case .invalidShasum(let invalid, let valid):
            return "Invalid Shasum: '\(invalid)', should be: '\(valid)'"
        // swiftlint:disable:next explicit_type_interface
        case .invalidURL(let url):
            return "Invalid URL: '\(url)'"
        }
    }
}
