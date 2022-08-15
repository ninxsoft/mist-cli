//
//  URL+Extension.swift
//  mist
//
//  Created by Nindi Gill on 15/8/2022.
//

import CryptoKit
import Foundation

extension URL {

    func shasum() -> String? {

        let length: Int = 1_024 * 1_024 * 50 // 50 MB

        do {
            let fileHandle: FileHandle = try FileHandle(forReadingFrom: self)

            defer {
                fileHandle.closeFile()
            }

            var shasum: Insecure.SHA1 = Insecure.SHA1()

            while try autoreleasepool(invoking: {
                try Task.checkCancellation()
                let data: Data = fileHandle.readData(ofLength: length)

                if !data.isEmpty {
                    shasum.update(data: data)
                }

                return !data.isEmpty
            }) { }

            let data: Data = Data(shasum.finalize())
            return data.map { String(format: "%02hhx", $0) }.joined()
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
