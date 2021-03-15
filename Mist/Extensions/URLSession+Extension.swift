//
//  URLSession+Extension.swift
//  Mist
//
//  Created by Nindi Gill on 11/3/21.
//

import Foundation

extension URLSession {

    // swiftlint:disable:next large_tuple
    func synchronousDownloadTask(with downloadURL: URL) -> (url: URL?, response: URLResponse?, error: Error?) {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

        var url: URL?
        var response: URLResponse?
        var error: Error?

        let task: URLSessionDownloadTask = self.downloadTask(with: downloadURL) {
            url = $0
            response = $1
            error = $2
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        return (url, response, error)
    }
}
