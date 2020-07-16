//
//  ViewController.swift
//  Example
//
//  Created by mark jones on 07/06/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import UIKit
import TimerControl

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var secondsBox: UITextField!
    @IBOutlet var timerControl: TimerControlView!
    var VCCounter: Int = 0
    var randomiser = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        timerControl.delegate = self
        self.secondsBox.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @IBAction func startSleep() {
        VCCounter = 0
        let text = secondsBox.text!
        if let num = Double(text) {
            timerControl.startTimer(duration: Int(num))
        } else {
            timerControl.startTimer(duration: Int(10.0))
        }
    }

    @IBAction func configure() {
        let innerColor: [UIColor] = [.blue, .systemGray3, .systemGray5, .green]
        let outerColor: [UIColor] = [ .black, .red, .orange, .magenta]
        let textColor: [UIColor] = [.white, .magenta, .systemBlue, .black]
        let hide: [Bool] = [false, false, false, true]
        let arcWidths: [Int] = [3, 4, 5, 6]
        let dashPatterns: [TimerControlDashPattern] = [.narrow, .medium, .wide, .none]

        timerControl.configureTimerControl(innerColor: innerColor[randomiser%4],
                                           outerColor: outerColor[randomiser%4],
                                           counterTextColor: textColor[randomiser%4],
                                           hideInactiveCounter: hide[randomiser%4],
                                           arcWidth: arcWidths[randomiser%4],
                                           arcDashPattern: dashPatterns[randomiser%4])
        randomiser += 1
    }

    @IBAction func resetSleep() {
        VCCounter = 0
        timerControl.stopTimer()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ViewController: TimerControlDelegate {

    func timerCompleted() {
        print("TIMER STOPPED DELEGATE CALL RECEIVED")
    }

    func timerTicked() {
        print("TIMER TICKED")
    }
}
