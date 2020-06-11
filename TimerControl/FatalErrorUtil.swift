//
//  FatalErrorUtil.swift
//  TimerControl
//
//  Created by mark jones on 10/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import Foundation

func fatalError(_ message: @autoclosure () -> String = "",
                file: StaticString = #file,
                line: UInt = #line) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

struct FatalErrorUtil {
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure

    private static let defaultFatalErrorClosure = {
        Swift.fatalError($0, file: $1, line: $2)
    }

    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }

    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}
