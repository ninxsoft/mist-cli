//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

/// Helper Class used to download macOS Firmwares and Installers.
class Downloader: NSObject {

    private var temporaryURL: URL?
    private var sourceURL: URL?
    private var total: Int64 = 0
    private var mistError: MistError?
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    /// Downloads a macOS Firmware.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Firmware fails to download.
    func download(_ firmware: Firmware, options: DownloadOptions) throws {

        PrettyPrint.printHeader("DOWNLOAD")
        temporaryURL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        guard let source: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(url: firmware.url)
        }

        sourceURL = source
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task: URLSessionDownloadTask = session.downloadTask(with: source)
        PrettyPrint.print("Downloading file - \(source.lastPathComponent)...", prefix: .parent)
        PrettyPrint.print("\(Int64(0).bytesString()) of \(Int64(0).bytesString()) [ 00.00 % ]", prefix: .child)
        task.resume()
        semaphore.wait()

        if let mistError: MistError = mistError {
            throw mistError
        }

        let totalString: String = total.bytesString()
        PrettyPrint.print("\(totalString) of \(totalString) [ 100.00 % ]", prefix: .child, replacing: true)
    }

    /// Downloads a macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer fails to download.
    func download(_ product: Product, options: DownloadOptions) throws {

        PrettyPrint.printHeader("DOWNLOAD")
        temporaryURL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let urls: [String] = [product.distribution] + product.packages.map { $0.url }.sorted { $0 < $1 }
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        for (index, url) in urls.enumerated() {

            guard let source: URL = URL(string: url) else {
                throw MistError.invalidURL(url: url)
            }

            sourceURL = source
            let current: Int = index + 1
            let currentString: String = "\(current < 10 && product.totalFiles >= 10 ? "0" : "")\(current)"
            let task: URLSessionDownloadTask = session.downloadTask(with: source)
            PrettyPrint.print("Downloading file \(currentString) of \(product.totalFiles) - \(source.lastPathComponent)...", prefix: .parent)
            PrettyPrint.print("00.00 GB of 00.00 GB [ 00.00 % ]", prefix: .child)
            task.resume()
            semaphore.wait()

            if let mistError: MistError = mistError {
                throw mistError
            }

            let totalString: String = total.bytesString()
            PrettyPrint.print("\(totalString) of \(totalString) [ 100.00 % ]", prefix: .child, replacing: true)
        }
    }
}

extension Downloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let currentString: String = totalBytesWritten.bytesString()
        let totalString: String = totalBytesExpectedToWrite.bytesString()
        let percentageString: String = String(format: "%05.2f %%", Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100)
        PrettyPrint.print("\(currentString) of \(totalString) [ \(percentageString) ]", prefix: .child, replacing: true)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        if let expectedContentLength: Int64 = downloadTask.response?.expectedContentLength {
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
