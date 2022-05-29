//
//  Validator.swift
//  mist
//
//  Created by Nindi Gill on 29/4/2022.
//

import CryptoKit
import Foundation

/// Helper Struct used to validate macOS Firmware and Installer downloads.
struct Validator {

    /// Validates the macOS Installer package that was downloaded.
    ///
    /// - Parameters:
    ///   - package:     The selected macOS Installer package that was downloaded.
    ///   - destination: The destination file URL of the downloaded package.
    ///
    /// - Throws: A `MistError` if the macOS Installer package fails validation.
    static func validate(_ package: Package, at destination: URL) throws {

        guard !package.url.hasSuffix("English.dist") else {
            return
        }

        let attributes: [FileAttributeKey: Any] = try FileManager.default.attributesOfItem(atPath: destination.path)

        guard let fileSize: UInt64 = attributes[.size] as? UInt64 else {
            throw MistError.generalError("Unble to retrieve file size from file '\(destination.path)'")
        }

        guard fileSize == package.size else {
            throw MistError.invalidFileSize(invalid: fileSize, valid: UInt64(package.size))
        }

        guard let string: String = package.integrityDataURL,
            let url: URL = URL(string: string),
            let size: Int = package.integrityDataSize else {
            return
        }

        let chunklist: Chunklist = try Chunklist(from: url, size: size)
        let fileHandle: FileHandle = try FileHandle(forReadingFrom: destination)
        var offset: UInt64 = 0

        for chunk in chunklist.chunks {
            try autoreleasepool {
                try fileHandle.seek(toOffset: offset)
                let data: Data = fileHandle.readData(ofLength: Int(chunk.size))
                let shasum: String = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined().uppercased()

                guard shasum == chunk.shasum else {
                    try fileHandle.close()
                    throw MistError.invalidShasum(invalid: shasum, valid: chunk.shasum)
                }

                offset += UInt64(chunk.size)
            }
        }

        try fileHandle.close()
    }
}
