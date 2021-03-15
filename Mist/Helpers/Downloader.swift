//
//  Downloader.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

struct Downloader {

    static func download(_ product: Product) throws {

        let temporaryURL: URL = URL(fileURLWithPath: "\(String.baseTemporaryDirectory)/\(product.identifier)")
        let urls: [String] = [product.distribution] + product.packages.map { $0.url }.sorted { $0 < $1 }

        try FileManager.default.remove(temporaryURL, description: "old temporary directory")
        try FileManager.default.create(temporaryURL, description: "new temporary directory")

        for (index, url) in urls.enumerated() {
            guard let source: URL = URL(string: url) else {
                throw MistError.invalidURL(string: url)
            }

            let string: String = String(format: "[%02d / %02d] Downloading %@...", index + 1, product.totalFiles, source.lastPathComponent)
            PrettyPrint.print(.info, string: string)

            let task: (url: URL?, response: URLResponse?, error: Error?) = URLSession.shared.synchronousDownloadTask(with: source)

            if let error: Error = task.error {
                PrettyPrint.print(.error, string: error.localizedDescription)
                throw error
            }

            guard let response: URLResponse = task.response,
                let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                throw MistError.invalidURLResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw MistError.invalidHTTPStatusCode(code: httpResponse.statusCode)
            }

            guard let url: URL = task.url else {
                throw MistError.invalidURL(string: source.path)
            }

            let destination: URL = temporaryURL.appendingPathComponent(source.lastPathComponent)
            try FileManager.default.move(url, to: destination)
        }
    }
}
