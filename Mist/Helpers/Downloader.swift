//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Struct used to download macOS Firmwares and Installers.
struct Downloader {

    /// Downloads a macOS Firmware.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Firmware fails to download.
    static func download(_ firmware: Firmware, options: DownloadOptions) throws {

        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        PrettyPrint.printHeader("DOWNLOAD")

        guard let source: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(url: firmware.url)
        }

        PrettyPrint.print("Downloading file - \(source.lastPathComponent)...")
        var mistError: MistError?

        let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: source) { url, response, error in

            if let error: Error = error {
                mistError = MistError.generalError(error.localizedDescription)
                semaphore.signal()
                return
            }

            guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                mistError = MistError.generalError("There was an error retrieving \(source.lastPathComponent)")
                semaphore.signal()
                return
            }

            guard response.statusCode == 200 else {
                mistError = MistError.generalError("Invalid HTTP status code: \(response.statusCode)")
                semaphore.signal()
                return
            }

            guard let location: URL = url else {
                mistError = MistError.generalError("Invalid temporary URL")
                semaphore.signal()
                return
            }

            let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)

            do {
                try FileManager.default.moveItem(at: location, to: destination)
            } catch {
                mistError = MistError.generalError(error.localizedDescription)
            }

            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        guard let mistError: MistError = mistError else {
            return
        }

        throw mistError
    }

    /// Downloads a macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer fails to download.
    static func download(_ product: Product, options: DownloadOptions) throws {

        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let urls: [String] = [product.distribution] + product.packages.map { $0.url }.sorted { $0 < $1 }

        PrettyPrint.printHeader("DOWNLOAD")

        for (index, url) in urls.enumerated() {
            guard let source: URL = URL(string: url) else {
                throw MistError.invalidURL(url: url)
            }

            let current: Int = index + 1
            let currentString: String = "\(current < 10 && product.totalFiles >= 10 ? "0" : "")\(current)"
            PrettyPrint.print("Downloading file \(currentString) of \(product.totalFiles) - \(source.lastPathComponent)...")
            var mistError: MistError?

            let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: source) { url, response, error in

                if let error: Error = error {
                    mistError = MistError.generalError(error.localizedDescription)
                    semaphore.signal()
                    return
                }

                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    mistError = MistError.generalError("There was an error retrieving \(source.lastPathComponent)")
                    semaphore.signal()
                    return
                }

                guard response.statusCode == 200 else {
                    mistError = MistError.generalError("Invalid HTTP status code: \(response.statusCode)")
                    semaphore.signal()
                    return
                }

                guard let location: URL = url else {
                    mistError = MistError.generalError("Invalid temporary URL")
                    semaphore.signal()
                    return
                }

                let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)

                do {
                    try FileManager.default.moveItem(at: location, to: destination)
                } catch {
                    mistError = MistError.generalError(error.localizedDescription)
                }

                semaphore.signal()
            }

            task.resume()
            semaphore.wait()

            guard let mistError: MistError = mistError else {
                continue
            }

            throw mistError
        }
    }
}
