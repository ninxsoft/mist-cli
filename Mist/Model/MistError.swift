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
    case missingBootableInstallerVolume
    case bootableInstallerVolumeNotFound(_ volume: String)
    case bootableInstallerVolumeUnknownFormat(_ volume: String)
    case bootableInstallerVolumeInvalidFormat(volume: String, format: String)
    case bootableInstallerVolumeIsReadOnly(_ volume: String)
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
    case invalidCachingServerProtocol(_ url: URL)

    var description: String {
        switch self {
        case .generalError(let string):
            "Error: \(string)"
        case .missingListSearchString:
            "List <search-string> is missing or empty."
        case .missingExportPath:
            "[-e, --export] Export path is missing or empty."
        case .invalidExportFileExtension:
            "Export file extension is invalid."
        case .invalidUser:
            "This command requires to be run as 'root'."
        case .missingDownloadSearchString:
            "Download <search-string> is missing or empty."
        case .missingFirmwareName:
            "[--firmware-name] macOS Restore Firmware output filename is missing or empty."
        case .missingFirmwareMetadataCachePath:
            "[--metadata-cache] macOS Firmware metadata cache path is missing or empty."
        case .missingApplicationName:
            "[--application-name] macOS Installer output filename is missing or empty."
        case .missingImageName:
            "[--image-name] macOS Disk Image output filename is missing or empty."
        case .missingImageSigningIdentity:
            "[--image-signing-identity] macOS Disk Image signing identity is missing or empty."
        case .missingIsoName:
            "[--iso-name] Bootable macOS Disk Image output filename is missing or empty."
        case .missingPackageName:
            "[--package-name] macOS Installer Package output filename is missing or empty."
        case .missingPackageIdentifier:
            "[--package-identifier] macOS Installer Package identifier is missing or empty."
        case .missingPackageSigningIdentity:
            "[--package-signing-identity] macOS Installer Package signing identity is missing or empty."
        case .missingBootableInstallerVolume:
            "[--bootable-installer-volume] Bootable macOS Installer volume is missing or empty."
        case .bootableInstallerVolumeNotFound(let volume):
            "Unable to find Bootable macOS Installer volume '\(volume)'."
        case .bootableInstallerVolumeUnknownFormat(let volume):
            "Unable to determine format of Bootable macOS Installer volume '\(volume)'."
        case .bootableInstallerVolumeInvalidFormat(let volume, let format):
            "Bootable macOS Installer volume '\(volume)' has invalid format '\(format)'. Format to 'Mac OS Extended (Journaled)' using Disk Utility."
        case .bootableInstallerVolumeIsReadOnly(let volume):
            "Bootable macOS Installer volume '\(volume)' is read-only. Format using Disk Utility."
        case .missingOutputDirectory:
            "[-o, --output-directory] Output directory is missing or empty."
        case .maximumRetriesReached:
            "Maximum number of retries reached."
        case .notEnoughFreeSpace(let volume, let free, let required):
            "Not enough free space on volume '\(volume)': \(free.bytesString()) free, \(required.bytesString()) required"
        case .existingFile(let path):
            "Existing file: '\(path)'. Use [--force] to overwrite."
        case .chunklistValidationFailed(let string):
            "Chunklist validation failed: \(string)"
        case .invalidChunklist(let url):
            "Unable to validate data integrity due to invalid chunklist: \(url.path)"
        case .invalidData:
            "Invalid data."
        case .invalidExitStatus(let code, let message):
            "Invalid Exit Status Code: '\(code)', Message: \(message)"
        case .invalidFileSize(let invalid, let valid):
            "Invalid File Size: '\(invalid)', should be: '\(valid)'"
        case .invalidShasum(let invalid, let valid):
            "Invalid Shasum: '\(invalid)', should be: '\(valid)'"
        case .invalidURL(let url):
            "Invalid URL: '\(url)'"
        case .invalidCachingServerProtocol(let url):
            "Invalid Content Caching Server protocol in URL: '\(url.absoluteString)', should be HTTP."
        }
    }
}
