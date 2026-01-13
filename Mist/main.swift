//
//  main.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation

#if os(Linux)
/// A shim for Linux that runs the given block of code.
///
/// The existence of this shim allows you the use of auto-release pools to optimize memory footprint on Darwin platforms while maintaining
/// compatibility with Linux where this API is not implemented.
@discardableResult
public func autoreleasepool<Result>(_ block: () throws -> Result) rethrows -> Result {
    return try block()
}

public func autoreleasepool<E, Result>(invoking body: () throws(E) -> Result) throws(E) -> Result where E: Error, Result : ~Copyable {
    return try body()
}
#else
// Disable stdout stream buffering for more immediate output.
setbuf(__stdoutp, nil)
#endif

Mist.main()
exit(0)
