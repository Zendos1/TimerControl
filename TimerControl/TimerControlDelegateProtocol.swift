//
//  TimerControlDelegateProtocol.swift
//  TimerControl
//
//  Created by mark jones on 21/05/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

public protocol TimerControlDelegate: class {
    func timerCompleted()
    func timerTicked()
}
