//
//  XCTestCase+FatalError.swift
//  TimerControlTests
//
//  Created by mark jones on 11/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import XCTest
@testable import TimerControl

extension XCTestCase {
    func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while (true)
    }

    func expectFatalError(expectedMessage: String, _ testcase: @escaping () -> Void) {
        let expectation = self.expectation(description: "expectingFatalError")
        FatalErrorUtil.replaceFatalError { message, _, _ in
            XCTAssertEqual(message, expectedMessage)
            expectation.fulfill()
            self.unreachable()
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)
        waitForExpectations(timeout: 0.1) { _ in
            FatalErrorUtil.restoreFatalError()
        }
    }
}
