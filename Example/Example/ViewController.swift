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

    override func viewDidLoad() {
        super.viewDidLoad()
        timerControl.delegate = self
        timerControl.configureTimerControl(innerColor: .blue,
                                           outerColor: .black,
                                           counterTextColor: .white,
                                           arcWidth: 3,
                                           arcDashPattern: .narrow)
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
