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

    /// App name.
    static let appName: String = "mist"
    /// Project name.
    static let projectName: String = "mist-cli"
    /// App identifier.
    static let identifier: String = "com.ninxsoft.\(appName)"
    /// App abstract string.
    static let abstract: String = "macOS Installer Super Tool."
    /// App discussion string.
    static let discussion: String = "Automatically download macOS Firmwares / Installers."
    /// Default temporary directory.
    static let temporaryDirectory: String = "/private/tmp/com.ninxsoft.mist"
    /// Default Firmwares metadata cache path.
    static let firmwaresMetadataCachePath: String = "/Users/Shared/Mist/firmwares.json"
    /// Default output directory.
    static let outputDirectory: String = "/Users/Shared/Mist"
    /// Default filename template.
    static let filenameTemplate: String = "Install %NAME% %VERSION%-%BUILD%"
    /// Default package identifier template.
    static let packageIdentifierTemplate: String = "com.company.pkg.%NAME%.%VERSION%.%BUILD%"
    /// GitHub repository URL
    static let repositoryURL: String = "https://github.com/ninxsoft/\(projectName)"
    /// GitHub latest release URL
    static let latestReleaseURL: String = "https://api.github.com/repos/ninxsoft/\(projectName)/releases/latest"

    /// Returns a string wrapped with the provided color (ANSI codes).
    ///
    /// - Parameters:
    ///   - color: The color to wrap the string with.
    ///
    /// - Returns: The string wrapped in the provided color (ANSI codes).
    func color(_ color: Color) -> String {
        color.rawValue + self + Color.reset.rawValue
    }

    /// Returns a string with the `%NAME%`, `%VERSION%` and `%BUILD%` placeholders substituted with values from the provided `Firmware`.
    ///
    /// - Parameters:
    ///   - firmware: The `Firmware` to use as the basis of substitutions.
    ///
    /// - Returns: A string with the `%NAME%`, `%VERSION%` and `%BUILD%` placeholders substituted with values from the provided `Firmware`.
    func stringWithSubstitutions(using firmware: Firmware) -> String {
        replacingOccurrences(of: "%NAME%", with: firmware.name)
            .replacingOccurrences(of: "%VERSION%", with: firmware.version)
            .replacingOccurrences(of: "%BUILD%", with: firmware.build)
            .replacingOccurrences(of: "//", with: "/")
    }

    /// Returns a string with the `%NAME%`, `%VERSION%` and `%BUILD%` placeholders substituted with values from the provided `Installer`.
    ///
    /// - Parameters:
    ///   - installer: The `Installer` to use as the basis of substitutions.
    ///
    /// - Returns: A string with the `%NAME%`, `%VERSION%` and `%BUILD%` placeholders substituted with values from the provided `Installer`.
    func stringWithSubstitutions(using installer: Installer) -> String {
        replacingOccurrences(of: "%NAME%", with: installer.name)
            .replacingOccurrences(of: "%VERSION%", with: installer.version)
            .replacingOccurrences(of: "%BUILD%", with: installer.build)
            .replacingOccurrences(of: "//", with: "/")
    }
}
