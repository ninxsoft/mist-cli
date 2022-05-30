//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Class used to download macOS Firmwares and Installers.
class Downloader: NSObject {

    private static let maximumWidth: Int = 80
    private var temporaryURL: URL?
    private var sourceURL: URL?
    private var current: Int64 = 0
    private var total: Int64 = 0
    private var prefixString: String = ""
    private var mistError: MistError?
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private var quiet: Bool = false

    /// Downloads a macOS Firmware.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if the macOS Firmware fails to download.
    func download(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {

        quiet = options.quiet
        !quiet ? PrettyPrint.printHeader("DOWNLOAD") : Mist.noop()
        temporaryURL = URL(fileURLWithPath: DownloadFirmwareCommand.temporaryDirectory(for: firmware, options: options))

        guard let source: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(url: firmware.url)
        }

        sourceURL = source
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task: URLSessionDownloadTask = session.downloadTask(with: source)
        prefixString = source.lastPathComponent
        updateProgress(replacing: false)
        task.resume()
        semaphore.wait()

        if let mistError: MistError = mistError {
            throw mistError
        }

        updateProgress()
    }

    /// Downloads a macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer fails to download.
    func download(_ product: Product, options: DownloadInstallerOptions) throws {

        quiet = options.quiet
        !quiet ? PrettyPrint.printHeader("DOWNLOAD") : Mist.noop()
        temporaryURL = URL(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: product, options: options))
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        guard let temporaryURL: URL = temporaryURL else {
            throw MistError.generalError("There was an error retrieving the temporary URL")
        }

        for (index, package) in product.allDownloads.enumerated() {

            guard let source: URL = URL(string: package.url) else {
                throw MistError.invalidURL(url: package.url)
            }

            sourceURL = source
            let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)
            let currentIndex: Int = index + 1
            let currentString: String = "\(currentIndex < 10 && product.allDownloads.count >= 10 ? "0" : "")\(currentIndex)"
            prefixString = "[ \(currentString) / \(product.allDownloads.count) ] \(source.lastPathComponent)"
            current = 0

            if FileManager.default.fileExists(atPath: destination.path) && package.size == 0 {
                let attributes: [FileAttributeKey: Any] = try FileManager.default.attributesOfItem(atPath: destination.path)

                if let size: Int64 = attributes[FileAttributeKey.size] as? Int64 {
                    total = size
                }
            } else {
                total = Int64(package.size)
            }

            updateProgress(replacing: false)

            if !FileManager.default.fileExists(atPath: destination.path) {
                let task: URLSessionDownloadTask = session.downloadTask(with: source)
                task.resume()
                semaphore.wait()

                if let mistError: MistError = mistError {
                    throw mistError
                }
            }

            current = total
            updateProgress()
            let indexString: String = "[ \(currentString) / \(product.allDownloads.count) ]"
            let verifyingString: String = "Verifying"
            var spaceString: String = String(repeating: " ", count: indexString.count - verifyingString.count)
            !quiet ? PrettyPrint.print("\(verifyingString)\(spaceString) \(source.lastPathComponent)....") : Mist.noop()
            try Validator.validate(package, at: destination)
            let verifiedString: String = "Verified"
            spaceString = String(repeating: " ", count: indexString.count - verifiedString.count)
            !quiet ? PrettyPrint.print("\(verifiedString)\(spaceString) \(source.lastPathComponent) \("✓✓✓".color(.green))", replacing: true) : Mist.noop()
        }
    }

    private func updateProgress(replacing: Bool = true) {
        let currentString: String = current.bytesString()
        let totalString: String = total.bytesString()
        let percentage: Double = total > 0 ? Double(current) / Double(total) * 100 : 0
        let format: String = percentage == 100 ? "%05.1f%%" : "%05.2f%%"
        let percentageString: String = String(format: format, percentage)
        let suffixString: String = "[ \(currentString) / \(totalString) (\(percentageString)) ]"
        let paddingSize: Int = Downloader.maximumWidth - PrettyPrint.Prefix.default.rawValue.count - prefixString.count - suffixString.count
        let paddingString: String = String(repeating: ".", count: paddingSize - 1) + " "
        !quiet ? PrettyPrint.print("\(prefixString)\(paddingString)\(suffixString)", replacing: replacing) : Mist.noop()
    }
}

extension Downloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        current = totalBytesWritten
        total = totalBytesExpectedToWrite
        updateProgress()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        if let expectedContentLength: Int64 = downloadTask.response?.expectedContentLength {
            current = expectedContentLength
            total = expectedContentLength
        }

        guard let temporaryURL: URL = temporaryURL else {
            mistError = MistError.generalError("There was an error retrieving the temporary URL")
            semaphore.signal()
            return
        }

        guard let sourceURL: URL = sourceURL else {
            mistError = MistError.generalError("There was an error retrieving the source URL")
            semaphore.signal()
            return
        }

        let destination: URL = temporaryURL.appendingPathComponent(sourceURL.lastPathComponent)

        do {
            try FileManager.default.moveItem(at: location, to: destination)
        } catch {
            mistError = MistError.generalError(error.localizedDescription)
            semaphore.signal()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        if let error: Error = error {
            mistError = MistError.generalError(error.localizedDescription)
            semaphore.signal()
            return
        }

        guard let file: String = task.currentRequest?.url?.lastPathComponent else {
            mistError = MistError.generalError("There was an error retrieving the URL")
            semaphore.signal()
            return
        }

        guard let response: HTTPURLResponse = task.response as? HTTPURLResponse else {
            mistError = MistError.generalError("There was an error retrieving \(file))")
            semaphore.signal()
            return
        }

        guard response.statusCode == 200 else {
            mistError = MistError.generalError("Invalid HTTP status code: \(response.statusCode)")
            semaphore.signal()
            return
        }

        semaphore.signal()
    }
}
