//
//  MockSut.swift
//  TimerControlTests
//
//  Created by mark jones on 05/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

@testable import TimerControl

class MockSut: TimerControlView {
    var allowSuper = false
    var setupApplicationStateObserversCalled = false
    var stopTimerAnimationCalled = false
    var setupCounterLabelCalledWithTextColor: UIColor?
    var animateArcCalledWithDuration: Int = 0

    convenience init(frame: CGRect, notificationCentre: NotificationCenter) {
        self.init(frame: frame)
        self.notificationCentre = notificationCentre
    }

    override func setupApplicationStateObservers() {
        setupApplicationStateObserversCalled = true
        guard (allowSuper == true) else { return }
        super.setupApplicationStateObservers()
    }

    override func setupCounterLabel(textColor: UIColor) {
        setupCounterLabelCalledWithTextColor = textColor
    }

    override func animateArcWithDuration(duration: Int) {
        animateArcCalledWithDuration = duration
    }

    override func stopTimerAnimation() {
        stopTimerAnimationCalled = true
    }
}
