//
//  ExportFormat.swift
//  Mist
//
//  Created by Nindi Gill on 15/3/21.
//

import ArgumentParser
import Foundation

enum ExportFormat: String, ExpressibleByArgument {
    case csv = "csv"
    case json = "json"
    case propertyList = "plist"
    case yaml = "yaml"
}
