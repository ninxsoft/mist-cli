//
//  [UInt8]+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 29/4/2022.
//

extension [UInt8] {
    /// Returns the `UInt8` at the provided offset.
    ///
    /// - Parameters:
    ///   - offset: The `[UInt8]` array offset.
    ///
    /// - Returns: The `UInt8` at the provided offset.
    func uInt8(at offset: Int) -> UInt8 {
        self[offset]
    }

    /// Returns the `UInt32` at the provided offset.
    ///
    /// - Parameters:
    ///   - offset: The `[UInt8]` array offset.
    ///
    /// - Returns: The `UInt32` at the provided offset.
    func uInt32(at offset: Int) -> UInt32 {
        self[offset ... offset + 0x03].reversed().reduce(0) {
            $0 << 0x08 + UInt32($1)
        }
    }

    /// Returns the `UInt64` at the provided offset.
    ///
    /// - Parameters:
    ///   - offset: The `[UInt8]` array offset.
    ///
    /// - Returns: The `UInt64` at the provided offset.
    func uInt64(at offset: Int) -> UInt64 {
        self[offset ... offset + 0x07].reversed().reduce(0) {
            $0 << 0x08 + UInt64($1)
        }
    }
}
