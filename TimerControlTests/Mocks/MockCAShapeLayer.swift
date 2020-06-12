//
//  MockCAShapeLayer.swift
//  TimerControlTests
//
//  Created by mark jones on 12/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import UIKit

class MockCAShapeLayer: CAShapeLayer {
    var animationRemovedForKey: String?

    override func removeAnimation(forKey key: String) {
        animationRemovedForKey = key
    }
}
