//
//  MockSut.swift
//  TimerControlTests
//
//  Created by mark jones on 05/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

@testable import TimerControl

class MockSut: TimerControlView {
    var setupApplicationStateObserversCalled = false
    var stopTimerAnimationCalled = false
    var cacheTimerStateToUserDefaultsCalled = false
    var prepareArclayerForRedrawCalled = false
    var retrieveTimerStateFromUserDefaultsCalled = false
    var resetTimerStateCalled = false
    var setupCounterLabelCalledWithTextColor: UIColor?
    var animateArcCalledWithDuration: Int?
    var drawInnerOvalCalled = false
    var outerArcRect: CGRect?
    var pathForInnerOvalCalledWithRect: CGRect?
    var arcWidthCalledForRect: CGRect?
    var configureDashPatternCalled = false
    var mockLayer: CAShapeLayer?
    var mockPath: UIBezierPath?
    var timerCompletedCalled = false
    var timerTickedCalled = false
    var displaySecondsCountCalled = false
    var mockSecondsCountDisplay: String?
    var mockCompletedValue: CGFloat?
    var mockArcWidth: CGFloat?

    convenience init(frame: CGRect,
                     notificationCentre: NotificationCenter,
                     userDefaults: UserDefaults) {
        self.init(frame: frame)
        self.notificationCentre = notificationCentre
        self.userDefaults = userDefaults
    }

    override func setupApplicationStateObservers() {
        setupApplicationStateObserversCalled = true
        super.setupApplicationStateObservers()
    }

    override func setupCounterLabel(textColor: UIColor) {
        setupCounterLabelCalledWithTextColor = textColor
        super.setupCounterLabel(textColor: textColor)
    }

    override func animateArcWithDuration(duration: Int) {
        animateArcCalledWithDuration = duration
        super.animateArcWithDuration(duration: duration)
    }

    override func stopTimerAnimation() {
        stopTimerAnimationCalled = true
        super.stopTimerAnimation()
    }

    override func cacheTimerStateToUserDefaults() {
        cacheTimerStateToUserDefaultsCalled = true
        super.cacheTimerStateToUserDefaults()
    }

    override func prepareArclayerForRedraw() {
        prepareArclayerForRedrawCalled = true
        super.prepareArclayerForRedraw()
    }

    override func retrieveTimerStateFromUserDefaults() {
        retrieveTimerStateFromUserDefaultsCalled = true
        super.retrieveTimerStateFromUserDefaults()
    }

    override func resetTimerState() {
        resetTimerStateCalled = true
        super.resetTimerState()
    }

    override func drawInnerOval(_ bezierPath: UIBezierPath) {
        drawInnerOvalCalled = true
        super.drawInnerOval(bezierPath)
    }

    override func drawOuterArc(_ rect: CGRect) {
        outerArcRect = rect
        super.drawOuterArc(rect)
    }

    override func pathForInnerOval(_ rect: CGRect) -> UIBezierPath {
        pathForInnerOvalCalledWithRect = rect
        return super.pathForInnerOval(rect)
    }

    override func arcWidth(_ rect: CGRect) -> CGFloat {
        arcWidthCalledForRect = rect
        guard let mockArcWidth = mockArcWidth else {
            return super.arcWidth(rect)
        }
        return mockArcWidth
    }

    override func configureDashPattern(_ pattern: TimerControlDashPattern) -> [NSNumber] {
        configureDashPatternCalled = true
        return super.configureDashPattern(pattern)
    }

    override func arcLayer() -> CAShapeLayer? {
        return mockLayer ?? super.arcLayer()
    }

    override func arcPath(_ rect: CGRect) -> UIBezierPath {
        guard let mockPath = mockPath else {
            return super.arcPath(rect)
        }
        return mockPath
    }

    override func displaySecondsCount(seconds: Int) -> String {
        displaySecondsCountCalled = true
        guard let secondsDisplay = mockSecondsCountDisplay else {
            return super.displaySecondsCount(seconds: seconds)
        }
        return secondsDisplay
    }

    override func completedTimerPercentage() -> CGFloat {
        return mockCompletedValue ?? super.completedTimerPercentage()
    }
}

extension MockSut: TimerControlDelegate {
    func timerCompleted() {
        timerCompletedCalled = true
    }

    func timerTicked() {
        timerTickedCalled = true
    }
}
