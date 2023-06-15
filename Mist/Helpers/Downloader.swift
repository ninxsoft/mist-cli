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
    private var urlError: URLError?
    private var mistError: MistError?
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private var noAnsi: Bool = false
    private var quiet: Bool = false
    private var previousPercentage: Int = 0

    /// Downloads a macOS Firmware.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options for macOS Firmwares.
    ///
    /// - Throws: A `MistError` if the macOS Firmware fails to download.
    func download(_ firmware: Firmware, options: DownloadFirmwareOptions) throws {
        noAnsi = options.noAnsi
        quiet = options.quiet
        !quiet ? PrettyPrint.printHeader("DOWNLOAD", noAnsi: noAnsi) : Mist.noop()
        temporaryURL = URL(fileURLWithPath: DownloadFirmwareCommand.temporaryDirectory(for: firmware, options: options))

        guard let source: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(firmware.url)
        }

        sourceURL = source
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let resumeDataURL: URL = DownloadFirmwareCommand.resumeDataURL(for: firmware, options: options)
        let task: URLSessionDownloadTask

        if FileManager.default.fileExists(atPath: resumeDataURL.path) {
            do {
                let resumeData: Data = try Data(contentsOf: resumeDataURL)
                task = session.downloadTask(withResumeData: resumeData)
                !quiet ? PrettyPrint.print("Resuming download...", noAnsi: noAnsi) : Mist.noop()
            } catch {
                task = session.downloadTask(with: source)
            }

            try FileManager.default.removeItem(at: resumeDataURL)
        } else {
            task = session.downloadTask(with: source)
        }

        prefixString = source.lastPathComponent
        updateProgress(replacing: false)
        task.resume()
        semaphore.wait()
        var retries: Int = 0

        while urlError != nil {

            if retries >= options.retries {

                if let error: URLError = urlError,
                    let data: Data = error.downloadTaskResumeData {
                    !quiet ? PrettyPrint.print("Saving resume data to '\(resumeDataURL.path)'...", noAnsi: noAnsi) : Mist.noop()
                    try data.write(to: resumeDataURL)
                }

                throw MistError.maximumRetriesReached
            }

            retries += 1
            retry(attempt: retries, of: options.retries, with: options.retryDelay, using: session)
        }

        if let mistError: MistError = mistError {
            throw mistError
        }

        updateProgress()
    }

    // swiftlint:disable cyclomatic_complexity function_body_length

    /// Downloads a macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options for macOS Installers.
    ///
    /// - Throws: A `MistError` if the macOS Installer fails to download.
    func download(_ product: Product, options: DownloadInstallerOptions) throws {

        noAnsi = options.noAnsi
        quiet = options.quiet
        !quiet ? PrettyPrint.printHeader("DOWNLOAD", noAnsi: noAnsi) : Mist.noop()
        temporaryURL = URL(fileURLWithPath: DownloadInstallerCommand.temporaryDirectory(for: product, options: options))
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        guard let temporaryURL: URL = temporaryURL else {
            throw MistError.generalError("There was an error retrieving the temporary URL")
        }

        var index: Int = 0

        while index < product.allDownloads.count {

            let package: Package = product.allDownloads[index]

            guard let source: URL = URL(string: package.url) else {
                throw MistError.invalidURL(package.url)
            }

            sourceURL = source
            let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)
            let currentString: String = "\(index + 1 < 10 && product.allDownloads.count >= 10 ? "0" : "")\(index + 1)"
            prefixString = "[ \(currentString) / \(product.allDownloads.count) ] \(source.lastPathComponent)"
            current = 0
            previousPercentage = 0

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
                let resumeDataURL: URL = DownloadInstallerCommand.resumeDataURL(for: package, in: product, options: options)
                let task: URLSessionDownloadTask

                if FileManager.default.fileExists(atPath: resumeDataURL.path) {
                    do {
                        let resumeData: Data = try Data(contentsOf: resumeDataURL)
                        task = session.downloadTask(withResumeData: resumeData)
                        !quiet ? PrettyPrint.print("Resuming download...", noAnsi: noAnsi, replacing: true) : Mist.noop()
                        !quiet ? PrettyPrint.print("", noAnsi: noAnsi) : Mist.noop()
                    } catch {
                        task = session.downloadTask(with: source)
                    }

                    try FileManager.default.removeItem(at: resumeDataURL)
                } else {
                    task = session.downloadTask(with: source)
                }

                task.resume()
                semaphore.wait()
                var retries: Int = 0

                while urlError != nil {

                    if retries >= options.retries {

                        if let error: URLError = urlError,
                            let data: Data = error.downloadTaskResumeData {
                            !quiet ? PrettyPrint.print("Saving resume data to '\(resumeDataURL.path)'...", noAnsi: noAnsi) : Mist.noop()
                            try data.write(to: resumeDataURL)
                        }

                        throw MistError.maximumRetriesReached
                    }

                    retries += 1
                    retry(attempt: retries, of: options.retries, with: options.retryDelay, using: session)
                }

                if let mistError: MistError = mistError {
                    throw mistError
                }
            }

            current = total
            updateProgress()

            if verify(package, at: destination, current: currentString, total: product.allDownloads.count) {
                index += 1
            }
        }
    }

    // swiftlint:enable cyclomatic_complexity function_body_length

    private func verify(_ package: Package, at destination: URL, current: String, total: Int) -> Bool {

        let paddingLength: Int = "[ \(current) / \(total) ]".count
        let padding: String = String(repeating: " ", count: paddingLength)
        !quiet ? PrettyPrint.print("\(padding) Verifying...", noAnsi: noAnsi, prefix: .continuing) : Mist.noop()

        do {
            try Validator.validate(package, at: destination)
            !quiet ? PrettyPrint.print("\(padding) Verifying... \("✓✓✓".color(.green))", noAnsi: noAnsi, prefix: .continuing, replacing: true) : Mist.noop()
            return true
        } catch {
            !quiet ? PrettyPrint.print("\(padding) Verifying... \("xxx".color(.red))", noAnsi: noAnsi, prefix: .continuing, replacing: true) : Mist.noop()

            if let error: MistError = error as? MistError {
                !quiet ? PrettyPrint.print("\(padding) \(error.description)", noAnsi: noAnsi, prefix: .continuing) : Mist.noop()
            }

            !quiet ? PrettyPrint.print("\(padding) Trying again...", noAnsi: noAnsi, prefix: .continuing) : Mist.noop()

            if FileManager.default.fileExists(atPath: destination.path) {
                try? FileManager.default.removeItem(at: destination)
            }

            return false
        }
    }

    private func retry(attempt retry: Int, of maximumRetries: Int, with delay: Int, using session: URLSession) {

        guard let urlError: URLError = urlError,
            let data: Data = urlError.downloadTaskResumeData else {
            mistError = MistError.generalError("Unable to retrieve URL Error data")
            return
        }

        self.urlError = nil

        !quiet ? PrettyPrint.print(urlError.localizedDescription, noAnsi: noAnsi, prefixColor: .red) : Mist.noop()
        !quiet ? PrettyPrint.print("Retrying attempt [ \(retry) / \(maximumRetries) ] in \(delay) seconds...", noAnsi: noAnsi) : Mist.noop()
        sleep(UInt32(delay))

        let task: URLSessionDownloadTask = session.downloadTask(withResumeData: data)
        updateProgress(replacing: false)
        task.resume()
        semaphore.wait()
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
        !quiet ? PrettyPrint.print("\(prefixString)\(paddingString)\(suffixString)", noAnsi: noAnsi, replacing: replacing) : Mist.noop()
    }
}

extension Downloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        current = totalBytesWritten
        total = totalBytesExpectedToWrite

        if noAnsi {
            let percentage: Int = Int(total > 0 ? Double(current) / Double(total) * 100 : 0)

            if percentage > previousPercentage {
                updateProgress()
                previousPercentage = percentage
            }
        } else {
            updateProgress()
        }
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

        if let error: URLError = error as? URLError {
            urlError = error
            semaphore.signal()
            return
        }

        urlError = nil

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

        guard [200, 206].contains(response.statusCode) else {
            mistError = MistError.generalError("Invalid HTTP status code: \(response.statusCode)")
            semaphore.signal()
            return
        }

        semaphore.signal()
    }
}
