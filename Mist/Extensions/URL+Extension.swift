//
//  URL+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 15/8/2022.
//

import CryptoKit
import Foundation

extension URL {
    /// Returns a SHA1 checksum for the file at the provided URL.
    ///
    /// - Returns: A SHA1 checksum string if the hash was successfully calculated, otherwise `nil`.
    func shasum() -> String? {
        let length: Int = 1_024 * 1_024 * 50 // 50 MB

        do {
            let fileHandle: FileHandle = try FileHandle(forReadingFrom: self)

            defer {
                fileHandle.closeFile()
            }

            var shasum: Insecure.SHA1 = .init()

            while
                try autoreleasepool(invoking: {
                    try Task.checkCancellation()
                    let data: Data = fileHandle.readData(ofLength: length)

                    if !data.isEmpty {
                        shasum.update(data: data)
                    }

                    return !data.isEmpty
                }) {}

            let data: Data = .init(shasum.finalize())
            return data.map { String(format: "%02hhx", $0) }.joined()
        } catch {
            return nil
        }
    }
}
