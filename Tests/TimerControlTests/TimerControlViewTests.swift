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
    var mockColor: MockColor!
    var mockBezierPath: MockUIBezierPath!
    var mockNotificationCentre: MockNotificationCentre!
    var mockUserDefaults: MockUserDefaults!
    var sut: MockSut!

    override func setUp() {
        super.setUp()
        mockFrame = CGRect(x: sutFrameValue, y: sutFrameValue, width: sutFrameValue, height: sutFrameValue)
        mockUserDefaults = MockUserDefaults()
        mockNotificationCentre = MockNotificationCentre()
        mockColor = MockColor()
        mockBezierPath = MockUIBezierPath()
        sut = MockSut(frame: mockFrame,
                      notificationCentre: mockNotificationCentre,
                      userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        sut = nil
        mockNotificationCentre = nil
        mockUserDefaults = nil
        mockColor = nil
        mockBezierPath = nil
        super.tearDown()
    }

    // MARK: Custom setters & Initilisers

    func testArcWidthSetter_lowerBound() {
        sut.arcWidth = 0

        XCTAssertEqual(sut.arcWidth, 1)
    }

    func testArcWidthSetter_upperBound() {
        sut.arcWidth = 11

        XCTAssertEqual(sut.arcWidth, 10)
    }

    func testsleepDurationSetter() {
        sut.sleepDuration = 100

        XCTAssertEqual(sut.sleepDuration, 100)
        XCTAssertTrue(sut.displaySecondsCountCalled)
    }


    func testsleepDurationSetter_upperBound() {
        sut.sleepDuration = 4000

        XCTAssertEqual(sut.sleepDuration, 3599)
        XCTAssertTrue(sut.displaySecondsCountCalled)
    }

    func testInitWithFrame() {
        XCTAssertEqual(sut.frame, mockFrame)
        XCTAssertTrue(sut.setupApplicationStateObserversCalled)
        XCTAssertEqual(sut.setupCounterLabelCalledWithTextColor, .white)
    }

    // MARK: Public API

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

    // MARK: View

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

        XCTAssertEqual(sut.pathForInnerOvalCalledWithRect, mockFrame)
        XCTAssertTrue(sut.drawInnerOvalCalled)
        XCTAssertEqual(sut.outerArcRect, mockFrame)
        XCTAssertEqual(sut.animateArcCalledWithDuration, sutCounter)
    }

    func testDraw_validCGRect_zeroDuration() {
        sut.draw(mockFrame)

        XCTAssertEqual(sut.pathForInnerOvalCalledWithRect, mockFrame)
        XCTAssertTrue(sut.drawInnerOvalCalled)
        XCTAssertEqual(sut.outerArcRect, mockFrame)
        XCTAssertNil(sut.animateArcCalledWithDuration)
    }

    func testDraw_invalidCGRect() {
        let invalidRect = CGRect(x: 0, y: 0, width: 10, height: 11)
        let expectedErrorMessage = "TimerControl should maintain a 1:1 aspect ratio"

        expectFatalError(expectedMessage: expectedErrorMessage) {
            self.sut.draw(invalidRect)
        }
    }

    func testDrawInnerOval() {
        sut.innerColor = mockColor
        sut.drawInnerOval(mockBezierPath)

        XCTAssertTrue(mockColor.colorSetFillCalled)
        XCTAssertTrue(mockBezierPath.bezierPathFillCalled)
    }

    func testDrawOuterArc_noExistingArc() throws {
        sut.layer.sublayers = []
        sut.outerColor = mockColor.mockColorValue
        sut.drawOuterArc(mockFrame)

        let arclayer = try? XCTUnwrap(sut.layer.sublayers?.first as? CAShapeLayer)
        XCTAssertNotNil(arclayer?.path)
        XCTAssertEqual(arclayer?.fillColor, UIColor.clear.cgColor)
        XCTAssertEqual(arclayer?.strokeColor, mockColor.mockColorValue.cgColor)
        XCTAssertEqual(sut.arcWidthCalledForRect, mockFrame)
        XCTAssertTrue(sut.configureDashPatternCalled)
        XCTAssertEqual(arclayer?.name, TimerControlConstants.arcLayerID)
    }

    func testDrawOuterArc_existingArc() throws {
        let mockLayer = CAShapeLayer()
        sut.mockLayer = mockLayer
        sut.mockPath = mockBezierPath
        sut.drawOuterArc(mockFrame)

        XCTAssertEqual(mockLayer.path, mockBezierPath.cgPath)
    }

    func testConfigureDashPattern() {
        XCTAssertEqual(sut.configureDashPattern(.none), [])
        XCTAssertEqual(sut.configureDashPattern(.narrow), [2, 1])
        XCTAssertEqual(sut.configureDashPattern(.medium), [4, 1])
        XCTAssertEqual(sut.configureDashPattern(.wide), [6, 1])
    }

    func testStopTimerAnimation() {
        sut.stopTimerAnimation()

        XCTAssertEqual(sut.outerArcRect, CGRect(x: 0, y: 0, width: mockFrame.width, height: mockFrame.height))
        XCTAssertEqual(sut.animateArcCalledWithDuration, 1)
        XCTAssertTrue(sut.resetTimerStateCalled)
    }

    func testPrepareArcLayerForRedraw() {
        let mockLayer = MockCAShapeLayer()
        mockLayer.path = mockBezierPath.cgPath
        sut.mockLayer = mockLayer
        sut.prepareArclayerForRedraw()

        XCTAssertEqual(mockLayer.animationRemovedForKey, TimerControlConstants.arcLayerAnimationID)
        XCTAssertNil(mockLayer.path)
    }

    func testDisplaySecondsCount_variousOutputs() {
        XCTAssertEqual(sut.displaySecondsCount(seconds: 1), "0:01")
        XCTAssertEqual(sut.displaySecondsCount(seconds: 30), "0:30")
        XCTAssertEqual(sut.displaySecondsCount(seconds: 90), "1:30")
        XCTAssertEqual(sut.displaySecondsCount(seconds: 630), "10:30")
    }

    func testUpdateCounter_timerCompleted() {
        sut.sleepCounter = 0
        sut.delegate = sut
        let mockTimer = MockTimer()
        sut.timer = mockTimer
        sut.updateCounter()

        XCTAssertTrue(sut.timerCompletedCalled)
        XCTAssertTrue(mockTimer.invalidateCalled)
        XCTAssertTrue(sut.resetTimerStateCalled)
    }

    func testUpdateCounter_timerNotCompleted() {
        sut.sleepCounter = 1
        sut.delegate = sut
        sut.mockSecondsCountDisplay = "0:01"
        sut.updateCounter()

        XCTAssertTrue(sut.timerTickedCalled)
        XCTAssertEqual(sut.sleepCounter, 0)
        XCTAssertEqual(sut.counterLabel.text, "0:01")
    }

    func testAnimateArcWithDuration() throws {
        sut.drawOuterArc(mockFrame)
        sut.animateArcWithDuration(duration: 10)
        let arclayer = sut.layer.sublayers?.last as? CAShapeLayer
        let animation = arclayer?.animation(forKey: TimerControlConstants.arcLayerAnimationID) as? CABasicAnimation

        XCTAssertNotNil(animation?.delegate)
        XCTAssertEqual(animation?.keyPath, "strokeEnd")
        XCTAssertEqual(animation?.fromValue as? CGFloat, 1.0)
        XCTAssertEqual(animation?.toValue as? CGFloat, 0.0)
        XCTAssertEqual(animation?.duration, CFTimeInterval(10.0))
    }

    // MARK: Helper

    func testArcEndAngle() {
        sut.mockCompletedValue = 1.5
        let expectedValue = TimerControlConstants.arcStartAngle - TimerControlConstants.startEndDifferential -
            (1.5 * TimerControlConstants.fullCircleRadians)
        XCTAssertEqual(sut.arcEndAngle(), expectedValue)
    }

    func testArcLayer() {
        let mockLayer = MockCAShapeLayer()
        mockLayer.name = TimerControlConstants.arcLayerID
        sut.layer.addSublayer(mockLayer)

        XCTAssertEqual(sut.arcLayer(), mockLayer)
    }

    func testArcWidth() {
        sut.arcWidth = 5
        let expectedWidth = mockFrame.width * TimerControlConstants.arcWidthIncrement * 5.0
        XCTAssertEqual(sut.arcWidth(mockFrame), expectedWidth)
    }

    func testPathForInnerOval() {
        let mockArcWidth: CGFloat = 5.0
        sut.mockArcWidth = mockArcWidth
        let innerRect = CGRect(x: mockArcWidth + TimerControlConstants.arcSpacer,
                               y: mockArcWidth + TimerControlConstants.arcSpacer,
                               width: mockFrame.width - (2 * (mockArcWidth + TimerControlConstants.arcSpacer)) ,
                               height: mockFrame.height - (2 * (mockArcWidth + TimerControlConstants.arcSpacer)))
        let expectedPath = UIBezierPath(ovalIn: innerRect)

        XCTAssertEqual(sut.pathForInnerOval(mockFrame), expectedPath)
    }

    func testArcPath() {
        let mockArcWidth: CGFloat = 5.0
        let mockCompletedValue: CGFloat = 1.5
        sut.mockArcWidth = mockArcWidth
        sut.mockCompletedValue = mockCompletedValue
        let centre = CGPoint(x: mockFrame.width/2, y: mockFrame.height/2)
        let radius = mockFrame.width/2 - mockArcWidth/2
        let arcEndAngel = TimerControlConstants.arcStartAngle - TimerControlConstants.startEndDifferential -
            (mockCompletedValue * TimerControlConstants.fullCircleRadians)
        let expectedArcPath = UIBezierPath(arcCenter: centre,
                                           radius: radius,
                                           startAngle: TimerControlConstants.arcStartAngle,
                                           endAngle: arcEndAngel,
                                           clockwise:true)

        XCTAssertEqual(sut.arcPath(mockFrame), expectedArcPath)
    }

    func testCompletedTimerPercentage_sleepDurationExpired() {
        sut.sleepDuration = 0

        XCTAssertEqual(sut.completedTimerPercentage(), 0.0)
    }

    func testCompletedTimerPercentage_sleepDurationActive() {
        sut.sleepDuration = 2
        sut.sleepCounter = 1
        let expectedCompletedPercentage = CGFloat((2.0 - 1.0) / 2.0)

        XCTAssertEqual(sut.completedTimerPercentage(), expectedCompletedPercentage)
    }

    func testResetTimerState() {
        sut.sleepDuration = 2
        sut.sleepCounter = 1
        sut.resetTimerState()

        XCTAssertEqual(sut.sleepDuration, 0)
        XCTAssertEqual(sut.sleepCounter, 0)
    }


    // MARK: CAAnimationDelegate

    func testAnimationDidStop_isFinished() {
        sut.animationDidStop(CAAnimation(), finished: true)

        XCTAssertTrue(sut.resetTimerStateCalled)
        XCTAssertEqual(sut.outerArcRect, CGRect(x: 0, y: 0, width: mockFrame.width, height: mockFrame.height))
    }

    func testAnimationDidStop_isNotFinished() {
        sut.animationDidStop(CAAnimation(), finished: false)

        XCTAssertFalse(sut.resetTimerStateCalled)
        XCTAssertNil(sut.outerArcRect)
    }
}
