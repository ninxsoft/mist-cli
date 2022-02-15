//
//  MistError.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import Foundation

enum MistError: Error {
    case generalError(_ string: String)
    case missingListSearchString
    case missingExportPath
    case invalidExportFileExtension
    case invalidUser
    case missingDownloadSearchString
    case missingFirmwareName
    case missingOutputType
    case missingApplicationName
    case missingImageName
    case missingImageSigningIdentity
    case missingIsoName
    case missingPackageName
    case missingPackageIdentifier
    case missingPackageSigningIdentity
    case missingOutputDirectory
    case notEnoughFreeSpace(volume: String, free: Int64, required: Int64)
    case existingFile(path: String)
    case invalidData
    case invalidExitStatus(code: Int32, message: String)
    case invalidShasum(invalid: String, valid: String)
    case invalidURL(url: String)

    var description: String {
        switch self {
        case .generalError(let string):
            return "Error: \(string)"
        case .missingListSearchString:
            return "List <search-string> is missing or empty."
        case .missingExportPath:
            return "[-e, --export] Export path is missing or empty."
        case .invalidExportFileExtension:
            return "Export file extension is invalid."
        case .invalidUser:
            return "This command requires to be run as 'root'."
        case .missingDownloadSearchString:
            return "Download <search-string> is missing or empty."
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
        case .missingIsoName:
            return "[--iso-name] Bootable macOS Disk Image output filename is missing or empty."
        case .missingPackageName:
            return "[--package-name] macOS Installer Package output filename is missing or empty."
        case .missingPackageIdentifier:
            return "[--package-identifier] macOS Installer Package identifier is missing or empty."
        case .missingPackageSigningIdentity:
            return "[--package-signing-identity] macOS Installer Package signing identity is missing or empty."
        case .missingOutputDirectory:
            return "[-o, --output-directory] Output directory is missing or empty."
        case .notEnoughFreeSpace(let volume, let free, let required):
            return "Not enough free space on volume '\(volume)': \(free.bytesString()) free, \(required.bytesString()) required"
        case .existingFile(let path):
            return "Existing file: '\(path)'. Use [--force] to overwrite."
        case .invalidData:
            return "Invalid data."
        case .invalidExitStatus(let code, let message):
            return "Invalid Exit Status Code: '\(code)', Message: \(message)"
        case .invalidShasum(let invalid, let valid):
            return "Invalid Shasum: '\(invalid)', should be: '\(valid)'"
        case .invalidURL(let url):
            return "Invalid URL: '\(url)'"
        }
    }
}
