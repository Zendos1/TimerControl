//
//  MockColor.swift
//  TimerControlTests
//
//  Created by mark jones on 12/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import UIKit

class MockColor: UIColor {
    var colorSetFillCalled = false
    var mockColorValue: UIColor = .cyan

    override func setFill() {
        colorSetFillCalled = true
    }
}
