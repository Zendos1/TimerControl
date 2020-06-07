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
    var setupCounterLabelCalledWithTextColor: UIColor?

    override func setupApplicationStateObservers() {
        setupApplicationStateObserversCalled = true
    }

    override func setupCounterLabel(textColor: UIColor) {
        setupCounterLabelCalledWithTextColor = textColor
    }
}
