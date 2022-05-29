//
//  UInt8+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 29/4/2022.
//

import Foundation

extension UInt8 {

    func hexString() -> String {
        String(format: "0x%02X", self)
    }
}
