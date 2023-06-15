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
    case missingFirmwareMetadataCachePath
    case missingApplicationName
    case missingImageName
    case missingImageSigningIdentity
    case missingIsoName
    case missingPackageName
    case missingPackageIdentifier
    case missingPackageSigningIdentity
    case missingCreateInstallMediaVolume
    case createInstallMediaVolumeNotFound(_ volume: String)
    case createInstallMediaVolumeUnknownFormat(_ volume: String)
    case createInstallMediaVolumeInvalidFormat(volume: String, format: String)
    case createInstallMediaVolumeIsReadOnly(_ volume: String)
    case missingOutputDirectory
    case maximumRetriesReached
    case notEnoughFreeSpace(volume: String, free: Int64, required: Int64)
    case existingFile(path: String)
    case chunklistValidationFailed(_ string: String)
    case invalidChunklist(url: URL)
    case invalidData
    case invalidExitStatus(code: Int32, message: String)
    case invalidFileSize(invalid: UInt64, valid: UInt64)
    case invalidShasum(invalid: String, valid: String)
    case invalidURL(_ url: String)

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
        case .missingFirmwareMetadataCachePath:
            return "[--metadata-cache] macOS Firmware metadata cache path is missing or empty."
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
        case .missingCreateInstallMediaVolume:
            return "[--create-install-media-volume] Bootable macOS Installer volume is missing or empty."
        case .createInstallMediaVolumeNotFound(let volume):
            return "Unable to find Bootable macOS Installer volume '\(volume)'."
        case .createInstallMediaVolumeUnknownFormat(let volume):
            return "Unable to determine format of Bootable macOS Installer volume '\(volume)'."
        case .createInstallMediaVolumeInvalidFormat(let volume, let format):
            return "Bootable macOS Installer volume '\(volume)' has invalid format '\(format)'. Format to 'Mac OS Extended (Journaled)' using Disk Utility."
        case .createInstallMediaVolumeIsReadOnly(let volume):
            return "Bootable macOS Installer volume '\(volume)' is read-only. Format using Disk Utility."
        case .missingOutputDirectory:
            return "[-o, --output-directory] Output directory is missing or empty."
        case .maximumRetriesReached:
            return "Maximum number of retries reached."
        case .notEnoughFreeSpace(let volume, let free, let required):
            return "Not enough free space on volume '\(volume)': \(free.bytesString()) free, \(required.bytesString()) required"
        case .existingFile(let path):
            return "Existing file: '\(path)'. Use [--force] to overwrite."
        case .chunklistValidationFailed(let string):
            return "Chunklist validation failed: \(string)"
        case .invalidChunklist(let url):
            return "Unable to validate data integrity due to invalid chunklist: \(url.path)"
        case .invalidData:
            return "Invalid data."
        case .invalidExitStatus(let code, let message):
            return "Invalid Exit Status Code: '\(code)', Message: \(message)"
        case .invalidFileSize(let invalid, let valid):
            return "Invalid File Size: '\(invalid)', should be: '\(valid)'"
        case .invalidShasum(let invalid, let valid):
            return "Invalid Shasum: '\(invalid)', should be: '\(valid)'"
        case .invalidURL(let url):
            return "Invalid URL: '\(url)'"
        }
    }
}
