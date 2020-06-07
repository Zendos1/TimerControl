//
//  TimerControlTests.swift
//  TimerControlTests
//
//  Created by mark jones on 15/05/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import XCTest
@testable import TimerControl

class TimerControlTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let mockViewController = MockViewController()
        _ = Bundle(for: TimerControlTests.self).loadNibNamed("MockViewController",
                                                             owner: mockViewController,
                                                             options: nil)

        XCTAssertTrue(mockViewController.mockTimerControlView.setupApplicationStateObserversCalled)
        XCTAssertEqual(mockViewController.mockTimerControlView.setupCounterLabelCalledWithTextColor, .white)
    }
}
