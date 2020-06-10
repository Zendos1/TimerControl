//
//  MockUserDefaults.swift
//  TimerControlTests
//
//  Created by mark jones on 09/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import Foundation

class MockUserDefaults: UserDefaults {
    var mockUserDefaultDictionary: [String: Any?] = [:]
    var synchronizeCalled = false

    override func set(_ value: Any?, forKey defaultName: String) {
        mockUserDefaultDictionary[defaultName] = value
    }

    override func set(_ value: Int, forKey defaultName: String) {
        mockUserDefaultDictionary[defaultName] = value
    }

    override func value(forKey key: String) -> Any? {
        return mockUserDefaultDictionary[key] ?? nil
    }

    override func synchronize() -> Bool {
        synchronizeCalled = true
        return true
    }
}
