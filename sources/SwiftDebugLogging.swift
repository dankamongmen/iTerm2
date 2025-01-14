//
//  SwiftDebugLogging.swift
//  iTerm2SharedARC
//
//  Created by George Nachman on 8/5/21.
//

import Foundation

func DLog(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
    guard gDebugLogging.boolValue else {
        return
    }
    // print("\(file):\(line) \(function): \(message)")

    DebugLogImpl(file.cString(using: .utf8), Int32(line), function.cString(using: .utf8), message)
}

