//
//  MockBezierPath.swift
//  TimerControlTests
//
//  Created by mark jones on 12/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import UIKit

class MockUIBezierPath: UIBezierPath {
    var bezierPathFillCalled = false

    override func fill() {
        bezierPathFillCalled = true
    }
}
