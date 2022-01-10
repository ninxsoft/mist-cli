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
    private var currentBytes: Int64 = 0
    private var currentIndex: Int = 0
    private var totalBytes: Int64 = 0
    private var prefixString: String = ""
    private var mistError: MistError?
    private var downloadInfo:DownloadInfo?
    private var jsonOutput:Bool = false
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    /// Downloads a macOS Firmware.
    ///
    /// - Parameters:
    ///   - firmware: The selected macOS Firmware to be downloaded.
    ///   - options:  Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Firmware fails to download.
    func download(_ firmware: Firmware, options: DownloadOptions) throws {

        self.downloadInfo=try? DownloadInfo(from: firmware)

        jsonOutput=options.jsonOutput
        PrettyPrint.printHeader("DOWNLOAD",parsable: options.jsonOutput)
        temporaryURL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        guard let source: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(url: firmware.url)
        }

        sourceURL = source
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task: URLSessionDownloadTask = session.downloadTask(with: source)
        prefixString = source.lastPathComponent
        updateProgress(replacing: false, parsable: options.jsonOutput)
        task.resume()
        semaphore.wait()

        if let mistError: MistError = mistError {
            throw mistError
        }

        updateProgress(parsable: options.jsonOutput)

    }

    /// Downloads a macOS Installer.
    ///
    /// - Parameters:
    ///   - product: The selected macOS Installer that was downloaded.
    ///   - options: Download options determining platform (ie. **Apple** or **Intel**) as well as download type, output path etc.
    ///
    /// - Throws: A `MistError` if the macOS Installer fails to download.
    func download(_ product: Product, options: DownloadOptions) throws {
        jsonOutput=options.jsonOutput

        PrettyPrint.printHeader("DOWNLOAD",parsable: options.jsonOutput)
        temporaryURL = URL(fileURLWithPath: options.temporaryDirectory(for: product))
        let urls: [String] = [product.distribution] + product.packages.map { $0.url }.sorted { $0 < $1 }
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        self.downloadInfo = try? DownloadInfo(from: product)
        for (index, url) in urls.enumerated() {

            guard let source: URL = URL(string: url) else {
                throw MistError.invalidURL(url: url)
            }

            sourceURL = source
            let task: URLSessionDownloadTask = session.downloadTask(with: source)
            currentIndex = index + 1
            currentBytes=0;
            totalBytes=0;
            let currentString: String = "\(currentIndex < 10 && product.totalFiles >= 10 ? "0" : "")\(currentIndex)"
            prefixString = "[ \(currentString) / \(product.totalFiles) ] \(source.lastPathComponent)"
            updateProgress(replacing: false, parsable: options.jsonOutput)
            task.resume()
            semaphore.wait()

            if let mistError: MistError = mistError {
                throw mistError
            }

            updateProgress(parsable: options.jsonOutput)
        }
    }

    private func updateProgress(replacing: Bool = true, parsable: Bool = false ) {
        let currentString: String = currentBytes.bytesString()
        let totalString: String = totalBytes.bytesString()
        let percentage: Double = totalBytes > 0 ? Double(currentBytes) / Double(totalBytes) * 100 : 0
        if (parsable==true){
            let outputDict = [
                                                "currentStep":currentIndex,
                                                "totalSteps":downloadInfo?.totalFiles ?? 0,
                                                "currentBytes":currentBytes,
                                                "totalBytes":totalBytes,
                                                "currentFilename":downloadInfo?.name ?? "" ,
                                                "version":downloadInfo?.version ?? "",
                                                "build":downloadInfo?.build ?? "",
                                                "date":downloadInfo?.date ?? ""

            ] as [String : Any]
            do {
                PrettyPrint.print("", parsable: true, messagetype: "Progress", messageObject: outputDict)
            }
        }
        else {
            let format: String = percentage == 100 ? "%05.1f%%" : "%05.2f%%"
            let percentageString: String = String(format: format, percentage)
            let suffixString: String = "[ \(currentString) / \(totalString) (\(percentageString)) ]"
            let paddingSize: Int = Downloader.maximumWidth - PrettyPrint.Prefix.default.rawValue.count - prefixString.count - suffixString.count
            let paddingString: String = String(repeating: ".", count: paddingSize - 1) + " "
            PrettyPrint.print("\(prefixString)\(paddingString)\(suffixString)", replacing: replacing, parsable: false)
        }
    }
}

extension Downloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        currentBytes = totalBytesWritten
        totalBytes = totalBytesExpectedToWrite
        updateProgress(parsable: jsonOutput)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        if let expectedContentLength: Int64 = downloadTask.response?.expectedContentLength {
            currentBytes = expectedContentLength
            totalBytes = expectedContentLength
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
