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

    func formattedCapacity() -> String {
        var value: Double = Double(self)
        var suffix: String = ""

        if value < Double(Int64.kilobyte) {
            suffix = "B"
        } else if value < Double(Int64.megabyte) {
            value /= Double(Int64.kilobyte)
            suffix = "KB"
        } else if value < Double(Int64.gigabyte) {
            value /= Double(Int64.megabyte)
            suffix = "MB"
        } else {
            value /= Double(Int64.gigabyte)
            suffix = "GB"
        }

        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.maximumIntegerDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let number: NSNumber = NSNumber(value: value)

        guard let string: String = numberFormatter.string(from: number) else {
            return "00.00\(suffix)"
        }

        return String(format: "%@ %@", string, suffix)
    }
}
