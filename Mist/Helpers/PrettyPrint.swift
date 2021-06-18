//
//  PrettyPrint.swift
//  Mist
//
//  Created by Nindi Gill on 12/3/21.
//

import Foundation

struct PrettyPrint {

    static func print(prefix: String = "", string: String) {
        let string: String = prefix.isEmpty ? string : "  \(prefix.color(.magenta)) \(string)"
        Swift.print(string)
    }
}
