//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Downloader {

    static func download(_ firmware: Firmware, options: DownloadOptions) throws {

        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let temporaryURL: URL = URL(fileURLWithPath: options.temporaryDirectory(for: firmware))

        PrettyPrint.printHeader("DOWNLOAD")

        guard let source: URL = URL(string: firmware.url) else {
            throw MistError.invalidURL(url: firmware.url)
        }

        PrettyPrint.print("Downloading file - \(source.lastPathComponent)...")

        let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: source) { url, response, error in

            if let error: Error = error {
                PrettyPrint.print(error.localizedDescription, prefix: "  └─")
                exit(1)
            }

            guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                PrettyPrint.print("There was an error retrieving \(source.lastPathComponent)", prefix: "  └─")
                exit(1)
            }

            guard response.statusCode == 200 else {
                PrettyPrint.print("Invalid HTTP status code: \(response.statusCode)", prefix: "  └─")
                exit(1)
            }

            guard let location: URL = url else {
                PrettyPrint.print("Invalid temporary URL", prefix: "  └─")
                exit(1)
            }

            let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)

            do {
                try FileManager.default.moveItem(at: location, to: destination)
                semaphore.signal()
            } catch {
                PrettyPrint.print(error.localizedDescription, prefix: "  └─")
                exit(1)
            }
        }

        task.resume()
        semaphore.wait()
    }

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

            let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: source) { url, response, error in

                if let error: Error = error {
                    PrettyPrint.print(error.localizedDescription, prefix: "  └─")
                    exit(1)
                }

                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    PrettyPrint.print("There was an error retrieving \(source.lastPathComponent)", prefix: "  └─")
                    exit(1)
                }

                guard response.statusCode == 200 else {
                    PrettyPrint.print("Invalid HTTP status code: \(response.statusCode)", prefix: "  └─")
                    exit(1)
                }

                guard let location: URL = url else {
                    PrettyPrint.print("Invalid temporary URL", prefix: "  └─")
                    exit(1)
                }

                let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)

                do {
                    try FileManager.default.moveItem(at: location, to: destination)
                    semaphore.signal()
                } catch {
                    PrettyPrint.print(error.localizedDescription, prefix: "  └─")
                    exit(1)
                }
            }

            task.resume()
            semaphore.wait()
        }
    }
}
