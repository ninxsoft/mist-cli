//
//  DownloadOutputType.swift
//  Mist
//
//  Created by Nindi Gill on 29/5/2022.
//

import ArgumentParser

enum DownloadOutputType: String, ExpressibleByArgument {
    // swiftlint:disable redundant_string_enum_value
    case application = "application"
    case image = "image"
    case iso = "iso"
    case package = "package"

    var description: String {
        self.rawValue
    }
}
