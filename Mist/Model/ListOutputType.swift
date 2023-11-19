//
//  ListOutputType.swift
//  Mist
//
//  Created by Nindi Gill on 1/9/21.
//

import ArgumentParser

enum ListOutputType: String, ExpressibleByArgument {
    case ascii
    case csv
    case json
    case plist
    case yaml
}
