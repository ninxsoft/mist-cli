//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Downloader {

    static func download(_ product: Product, settings: Settings) throws {

        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let temporaryURL: URL = URL(fileURLWithPath: settings.temporaryDirectory(for: product))
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
                    PrettyPrint.print(prefix: "└─", error.localizedDescription)
                    exit(1)
                }

                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    PrettyPrint.print(prefix: "└─", "There was an error retrieving \(source.lastPathComponent)")
                    exit(1)
                }

                guard response.statusCode == 200 else {
                    PrettyPrint.print(prefix: "└─", "Invalid HTTP status code: \(response.statusCode)")
                    exit(1)
                }

                guard let location: URL = url else {
                    PrettyPrint.print(prefix: "└─", "Invalid temporary URL")
                    exit(1)
                }

                let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)

                do {
                    try FileManager.default.moveItem(at: location, to: destination)
                    semaphore.signal()
                } catch {
                    PrettyPrint.print(prefix: "└─", error.localizedDescription)
                    exit(1)
                }
            }

            task.resume()
            semaphore.wait()
        }
    }
}
