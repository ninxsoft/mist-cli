//
//  Int64+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 16/3/21.
//

import Foundation

extension Int64 {

    static let kilobyte: Int64 = 1000
    static let megabyte: Int64 = .kilobyte * 1000
    static let gigabyte: Int64 = .megabyte * 1000

    func toGigabytes() -> Double {
        Double(self) / Double(Int64.gigabyte)
    }
}
