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
    var innerOvalRect: CGRect?
    var outerArcRect: CGRect?

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
    }

    override func stopTimerAnimation() {
        stopTimerAnimationCalled = true
    }

    override func cacheTimerStateToUserDefaults() {
        cacheTimerStateToUserDefaultsCalled = true
        super.cacheTimerStateToUserDefaults()
    }

    override func prepareArclayerForRedraw() {
        prepareArclayerForRedrawCalled = true
    }

    override func retrieveTimerStateFromUserDefaults() {
        retrieveTimerStateFromUserDefaultsCalled = true
        super.retrieveTimerStateFromUserDefaults()
    }

    override func resetTimerState() {
        resetTimerStateCalled = true
    }

    override func drawInnerOval(_ rect: CGRect) {
        innerOvalRect = rect
    }

    override func drawOuterArc(_ rect: CGRect) {
        outerArcRect = rect
    }
}
