//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

class Downloader: NSObject {

    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private var temporaryURL: URL = URL(fileURLWithPath: "")
    private var source: URL = URL(fileURLWithPath: "")
    private var prefix: String = ""
    private var totalBytesWritten: Int64 = 0
    private var totalBytesExpectedToWrite: Int64 = 0
    private var formattedTotalBytesWritten: String {
        totalBytesWritten.formattedCapacity()
    }
    private var formattedTotalBytesExpectedToWrite: String {
        let value: Int64 = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : totalBytesWritten
        return value.formattedCapacity()
    }
    private var percent: String {

        let blank: String = "      "

        guard totalBytesExpectedToWrite > 0 else {
            return blank
        }

        let value: Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100

        guard value < 100 else {
            return "100.0%"
        }

        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.maximumIntegerDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let number: NSNumber = NSNumber(value: value)

        guard let string: String = numberFormatter.string(from: number) else {
            return blank
        }

        return "\(string)%"
    }

    func download(_ product: Product) throws {

        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        temporaryURL = URL(fileURLWithPath: "\(String.baseTemporaryDirectory)/\(product.identifier)")
        let urls: [String] = [product.distribution] + product.packages.map { $0.url }.sorted { $0 < $1 }

        try FileManager.default.remove(temporaryURL, description: "old temporary directory")
        try FileManager.default.create(temporaryURL, description: "new temporary directory")

        for (index, url) in urls.enumerated() {
            guard let sourceURL: URL = URL(string: url) else {
                throw MistError.invalidURL(url: url)
            }

            source = sourceURL

            let type: String = PrettyPrint.PrintType.info.descriptionWithColor
            let date: Date = Date()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            prefix = String(format: "[%@] %@ - [%02d / %02d] Downloading %@...", type, dateFormatter.string(from: date), index + 1, product.totalFiles, source.lastPathComponent)
            PrettyPrint.print(.info, prefix: false, string: prefix, carriageReturn: true, newLine: false)

            let task: URLSessionDownloadTask = session.downloadTask(with: source)
            totalBytesWritten = 0
            totalBytesExpectedToWrite = 0
            task.resume()
            semaphore.wait()
        }
    }
}

extension Downloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        if let error: Error = error {
            PrettyPrint.print(.error, string: error.localizedDescription)
            exit(1)
        }

        let suffix: String = "[\(formattedTotalBytesWritten) of \(formattedTotalBytesExpectedToWrite) - 100.0%]".color(.green)
        let string: String = prefix + suffix
        PrettyPrint.print(.info, prefix: false, string: string)
        semaphore.signal()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.totalBytesWritten = totalBytesWritten
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        let suffix: String = "[\(formattedTotalBytesWritten) of \(formattedTotalBytesExpectedToWrite) - \(percent)]".color(.blue)
        let string: String = prefix + suffix
        PrettyPrint.print(.info, prefix: false, string: string, carriageReturn: true, newLine: false)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)

        do {
            try FileManager.default.move(location, to: destination)
        } catch {
            PrettyPrint.print(.error, string: error.localizedDescription)
            exit(1)
        }
    }
}
