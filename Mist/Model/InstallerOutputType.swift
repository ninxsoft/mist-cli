//
//  InstallerOutputType.swift
//  Mist
//
//  Created by Nindi Gill on 29/5/2022.
//

import ArgumentParser

enum InstallerOutputType: String, ExpressibleByArgument {
    case application
    case image
    case iso
    case package
    case bootableInstaller = "bootableinstaller"

    var description: String {
        rawValue
    }
}
