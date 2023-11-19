//
//  Int64+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 16/3/21.
//

import Foundation

extension Int64 {
    /// kilobytes constant
    static let kilobyte: Int64 = 1_000
    /// megabytes constant
    static let megabyte: Int64 = .kilobyte * 1_000
    /// gigabytes constant
    static let gigabyte: Int64 = .megabyte * 1_000

    func bytesString() -> String {
        if self < .kilobyte {
            String(format: " %04d  B", self)
        } else if self < .megabyte {
            String(format: "%05.2f KB", Double(self) / Double(Int64.kilobyte))
        } else if self < .gigabyte {
            String(format: "%05.2f MB", Double(self) / Double(Int64.megabyte))
        } else {
            String(format: "%05.2f GB", Double(self) / Double(Int64.gigabyte))
        }
    }
}
