//
//  MockNotificationCentre.swift
//  TimerControlTests
//
//  Created by mark jones on 08/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import Foundation

class MockNotificationCentre: NotificationCenter {
    struct MockObserver {
        var observer: Any
        var selector: Selector
        var name: NSNotification.Name?
        var object: Any?
    }

    var Observers: [MockObserver] = []

    override func addObserver(_ observer: Any,
                              selector aSelector: Selector,
                              name aName: NSNotification.Name?,
                              object anObject: Any?) {
        Observers.append(MockObserver(observer: observer,
                                      selector: aSelector,
                                      name: aName,
                                      object: anObject))
    }
}
