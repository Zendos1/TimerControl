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
    let sutFrameValue = 10
    var mockFrame: CGRect!
    var mockNotificationCentre: MockNotificationCentre!
    var sut: MockSut!

    override func setUp() {
        super.setUp()
        mockFrame = CGRect(x: sutFrameValue, y: sutFrameValue, width: sutFrameValue, height: sutFrameValue)
        mockNotificationCentre = MockNotificationCentre()
        sut = MockSut(frame: mockFrame, notificationCentre: mockNotificationCentre)
    }

    override func tearDown() {
        sut = nil
        mockNotificationCentre = nil
        super.tearDown()
    }

    func testInitWithCoder() {
        let mockViewController = MockViewController()
        _ = Bundle(for: TimerControlTests.self).loadNibNamed("MockViewController",
                                                             owner: mockViewController,
                                                             options: nil)

        XCTAssertTrue(mockViewController.mockTimerControlView.setupApplicationStateObserversCalled)
        XCTAssertEqual(mockViewController.mockTimerControlView.setupCounterLabelCalledWithTextColor, .white)
    }

    func testInitWithFrame() {
        XCTAssertEqual(sut.frame, mockFrame)
        XCTAssertTrue(sut.setupApplicationStateObserversCalled)
        XCTAssertEqual(sut.setupCounterLabelCalledWithTextColor, .white)
    }

    func testConfigureTimerControlDefaultValues() {
        XCTAssertEqual(sut.innerColor, .gray)
        XCTAssertEqual(sut.outerColor, .blue)
        XCTAssertEqual(sut.setupCounterLabelCalledWithTextColor, .white)
        XCTAssertEqual(sut.arcWidth, 1)
        XCTAssertEqual(sut.arcDashPattern, .none)
    }

    func testConfigureTimerControlWithValues() {
        sut.configureTimerControl(innerColor: .green,
                                  outerColor: .red,
                                  counterTextColor: .yellow,
                                  arcWidth: 10,
                                  arcDashPattern: .wide)

        XCTAssertEqual(sut.innerColor, .green)
        XCTAssertEqual(sut.outerColor, .red)
        XCTAssertEqual(sut.counterLabel.textColor, .yellow)
        XCTAssertEqual(sut.arcWidth, 10)
        XCTAssertEqual(sut.arcDashPattern, .wide)
    }

    func testStartTimer() {
        let sutDuration = 15
        sut.startTimer(duration: sutDuration)

        XCTAssertEqual(sut.sleepDuration, sutDuration)
        XCTAssertEqual(sut.sleepCounter, sutDuration)
        XCTAssertTrue(sut.timer.isValid)
        XCTAssertEqual(sut.timer.timeInterval, 1)
        XCTAssertEqual(sut.animateArcCalledWithDuration, sutDuration)
    }

    func testStopTimer_stopTimerAnimationIsNotCalled() {
        sut.stopTimer()

        XCTAssertFalse(sut.timer.isValid)
        XCTAssertFalse(sut.stopTimerAnimationCalled)
    }

    func testStopTimer_stopTimerAnimationIsCalled() {
        sut.sleepDuration = 10
        sut.stopTimer()

        XCTAssertFalse(sut.timer.isValid)
        XCTAssertTrue(sut.stopTimerAnimationCalled)
    }

    func testSetupApplicationStateObservers() {
        sut.allowSuper = true
        sut.setupApplicationStateObservers()
        let mockObservers = mockNotificationCentre.Observers

        XCTAssertEqual(mockNotificationCentre.Observers.count, 2)
        XCTAssertEqual(mockObservers.first?.observer as? MockSut, sut)
        XCTAssertEqual(mockObservers.first?.selector, #selector(TimerControlView.handleApplicationWillForeground))
        XCTAssertEqual(mockObservers.first?.name, UIApplication.willEnterForegroundNotification)
        XCTAssertNil(mockObservers.first?.object)
        XCTAssertEqual(mockObservers.last?.observer as? MockSut, sut)
        XCTAssertEqual(mockObservers.last?.selector, #selector(TimerControlView.handleApplicationBackGrounding))
        XCTAssertEqual(mockObservers.last?.name, UIApplication.didEnterBackgroundNotification)
        XCTAssertNil(mockObservers.last?.object)
    }
}
