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
    let sutDuration: Int = 15
    let sutCounter = 10
    var mockFrame: CGRect!
    var mockNotificationCentre: MockNotificationCentre!
    var mockUserDefaults: MockUserDefaults!
    var sut: MockSut!

    override func setUp() {
        super.setUp()
        mockFrame = CGRect(x: sutFrameValue, y: sutFrameValue, width: sutFrameValue, height: sutFrameValue)
        mockUserDefaults = MockUserDefaults()
        mockNotificationCentre = MockNotificationCentre()
        sut = MockSut(frame: mockFrame,
                      notificationCentre: mockNotificationCentre,
                      userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        sut = nil
        mockNotificationCentre = nil
        mockUserDefaults = nil
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
        sut.sleepDuration = sutDuration
        sut.stopTimer()

        XCTAssertFalse(sut.timer.isValid)
        XCTAssertTrue(sut.stopTimerAnimationCalled)
    }

    func testSetupApplicationStateObservers() {
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

    func testHandleApplicationBackGrounding() {
        sut.handleApplicationBackGrounding()

        XCTAssertTrue(sut.cacheTimerStateToUserDefaultsCalled)
        XCTAssertTrue(sut.prepareArclayerForRedrawCalled)
    }

    func testHandleApplicationWillForeground() {
        sut.handleApplicationWillForeground()

        XCTAssertTrue(sut.retrieveTimerStateFromUserDefaultsCalled)
    }

    func testCacheTimerStateToUserDefaults() throws {
        sut.sleepDuration = sutDuration
        sut.sleepCounter = sutCounter
        sut.cacheTimerStateToUserDefaults()

        let mockDefaults = try XCTUnwrap(sut.userDefaults as? MockUserDefaults)
        XCTAssertNotNil(mockDefaults.mockUserDefaultDictionary.keys.contains(TimerControlConstants.cacheTime))
        XCTAssertEqual(mockDefaults.mockUserDefaultDictionary[TimerControlConstants.sleepDuration] as? Int, sutDuration)
        XCTAssertEqual(mockDefaults.mockUserDefaultDictionary[TimerControlConstants.sleepCounter] as? Int, sutCounter)
        XCTAssertTrue(mockDefaults.synchronizeCalled)
    }

    func testRetrieveTimerStateFromUserDefaults_timerHasExpired() {
        let sutDate = NSDate(timeIntervalSinceNow: -Double(sutCounter))
        sut.userDefaults.set(sutDate, forKey: TimerControlConstants.cacheTime)
        sut.userDefaults.set(sutDuration, forKey: TimerControlConstants.sleepDuration)
        sut.userDefaults.set(sutCounter, forKey: TimerControlConstants.sleepCounter)
        sut.retrieveTimerStateFromUserDefaults()

        XCTAssertTrue(sut.resetTimerStateCalled)
    }

    func testRetrieveTimerStateFromUserDefaults_timerIsValid() {
        let sutDate = NSDate(timeIntervalSinceNow: 0)
        sut.userDefaults.set(sutDate, forKey: TimerControlConstants.cacheTime)
        sut.userDefaults.set(sutDuration, forKey: TimerControlConstants.sleepDuration)
        sut.userDefaults.set(sutCounter, forKey: TimerControlConstants.sleepCounter)
        sut.retrieveTimerStateFromUserDefaults()

        XCTAssertFalse(sut.resetTimerStateCalled)
        XCTAssertTrue(sut.sleepCounter < sutCounter)
        XCTAssertEqual(sut.sleepDuration, sutDuration)
    }

    func testSetupCounterLabel() {
        XCTAssertEqual(sut.counterLabel.frame, CGRect.zero)
        XCTAssertEqual(sut.counterLabel.textAlignment, .center)
        XCTAssertEqual(sut.counterLabel.textColor, .white)
        XCTAssertFalse(sut.counterLabel.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.subviews.count, 1)
        XCTAssertEqual(sut.subviews.first, sut.counterLabel)
        XCTAssertEqual(sut.constraints.count, 2)
        XCTAssertEqual(sut.constraints.first?.firstAttribute, .centerX)
        XCTAssertEqual(sut.constraints.first?.multiplier, 1)
        XCTAssertEqual(sut.constraints.last?.firstAttribute, .centerY)
        XCTAssertEqual(sut.constraints.last?.multiplier, 1.5)
        XCTAssertEqual(sut.counterLabel.text, sut.displaySecondsCount(seconds: 0))
    }

    func testDraw_validCGRect_validDuration() {
        sut.sleepDuration = sutDuration
        sut.sleepCounter = sutCounter
        sut.draw(mockFrame)

        XCTAssertEqual(sut.innerOvalRect, mockFrame)
        XCTAssertEqual(sut.outerArcRect, mockFrame)
        XCTAssertEqual(sut.animateArcCalledWithDuration, sutCounter)
    }

    func testDraw_validCGRect_zeroDuration() {
        sut.draw(mockFrame)

        XCTAssertEqual(sut.innerOvalRect, mockFrame)
        XCTAssertEqual(sut.outerArcRect, mockFrame)
        XCTAssertNil(sut.animateArcCalledWithDuration)
    }

    func testDraw_invalidCGRect() {
        let invalidRect = CGRect(x: 0, y: 0, width: 10, height: 11)
        sut.draw(invalidRect)

    }
}
