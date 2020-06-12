//
//  MockTimer.swift
//  TimerControlTests
//
//  Created by mark jones on 12/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import Foundation

class MockTimer: Timer {
    var invalidateCalled = false

    override func invalidate() {
        invalidateCalled = true
    }
}
