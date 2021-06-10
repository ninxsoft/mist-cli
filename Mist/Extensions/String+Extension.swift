//
//  String+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation

extension String {

    enum Color: String, CaseIterable {
        case black = "\u{001B}[0;30m"
        case red = "\u{001B}[0;31m"
        case green = "\u{001B}[0;32m"
        case yellow = "\u{001B}[0;33m"
        case blue = "\u{001B}[0;34m"
        case magenta = "\u{001B}[0;35m"
        case cyan = "\u{001B}[0;36m"
        case white = "\u{001B}[0;37m"
        case brightBlack = "\u{001B}[0;90m"
        case brightRed = "\u{001B}[0;91m"
        case brightGreen = "\u{001B}[0;92m"
        case brightYellow = "\u{001B}[0;93m"
        case brightBlue = "\u{001B}[0;94m"
        case brightMagenta = "\u{001B}[0;95m"
        case brightCyan = "\u{001B}[0;96m"
        case brightWhite = "\u{001B}[0;97m"
        case reset = "\u{001B}[0;0m"
    }

    static let appName: String = "mist"
    static var identifier: String { "com.ninxsoft.\(appName)" }
    static let abstract: String = "macOS Installer Super Tool."
    static let discussion: String = "Automatically generate macOS Installers."
    static let temporaryDirectory: String = "/private/var/tmp"
    static let outputDirectory: String = "/Users/Shared/macOS Installers"
    static let filenameTemplate: String = "Install %NAME% %VERSION%-%BUILD%"

    mutating func wrapInPropertyList() {
        self = "<?xml version=\"1.0\"?>" +
            "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" +
            "<plist version=\"1.0\">" +
            self +
            "</plist>"
    }

    func color(_ color: Color) -> String {
        color.rawValue + self + Color.reset.rawValue
    }
}
