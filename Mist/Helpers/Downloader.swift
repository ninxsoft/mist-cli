//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Downloader {

    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    func download(_ product: Product, settings: Settings) throws {

        let temporaryURL: URL = URL(fileURLWithPath: "\(settings.temporaryDirectory)/\(product.identifier)")
        let urls: [String] = [product.distribution] + product.packages.map { $0.url }.sorted { $0 < $1 }

        try FileManager.default.remove(temporaryURL, description: "old temporary directory")
        try FileManager.default.create(temporaryURL, description: "new temporary directory")

        for (index, url) in urls.enumerated() {
            guard let source: URL = URL(string: url) else {
                throw MistError.invalidURL(url: url)
            }

            let indexString: String = "\(index < 10 && urls.count >= 10 ? "0" : "")\(index + 1)"
            let string: String = "[\(indexString) / \(product.totalFiles)] Downloading \(source.lastPathComponent)..."
            PrettyPrint.print(.info, string: string)

            let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: source) { url, response, error in

                if let error: Error = error {
                    PrettyPrint.print(.error, string: error.localizedDescription)
                    exit(1)
                }

                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    PrettyPrint.print(.error, string: "There was an error retrieving \(source.lastPathComponent)")
                    exit(1)
                }

                guard response.statusCode == 200 else {
                    PrettyPrint.print(.error, string: "Invalid HTTP status code: \(response.statusCode)")
                    exit(1)
                }

                guard let location: URL = url else {
                    PrettyPrint.print(.error, string: "Invalid temporary URL")
                    exit(1)
                }

                let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)

                do {
                    try FileManager.default.move(location, to: destination)
                    semaphore.signal()
                } catch {
                    PrettyPrint.print(.error, string: error.localizedDescription)
                    exit(1)
                }
            }

            task.resume()
            semaphore.wait()
        }
    }
}
