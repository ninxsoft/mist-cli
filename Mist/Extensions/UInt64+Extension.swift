//
//  UInt64+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 29/4/2022.
//

import Foundation

extension UInt64 {
    /// Returns a hex-formatted string for the provided `UInt64`.
    ///
    /// - Returns: A hex-formatted string for `UInt64`.
    func hexString() -> String {
        String(format: "0x%016X", self)
    }
}
