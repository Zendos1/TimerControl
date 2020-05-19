//
//  TimerControlView.swift
//  TimerControl
//
//  Created by mark jones on 15/05/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import UIKit

public class TimerControlView: UIView {

    // MARK: Properties
    public weak var delegate: TimerControlDelegate?  //MJDelegate

    var pathLayer = CAShapeLayer()
    let π: CGFloat = CGFloat(M_PI)
    let startEndDifferential: CGFloat = 0.0000001
    public var completionFactor: CGFloat = 0.0
    var fillColor: UIColor = UIColor.gray
    var arcColor: UIColor = UIColor.blue
    var counterLabelTextColor: UIColor = UIColor.white
    var arcWidth: CGFloat = 10.0
    var counterLabel = UILabel()
    public var remaingTime: Int = 0
    public var animateRemaining: Bool = false
    var timer = Timer()
    var counter: Int = 0
    var sleepTime: Int = 10 {
        didSet {
            if (sleepTime >= 3600) {
                sleepTime = 3599
            }
            self.counterLabel.text = self.displaySecondsCount(seconds: sleepTime)
            self.counter = sleepTime
        }
    }

    // MARK: TODO
    // possibly remove the CAShapelayer from the view on applicationEnterBackGround then redraw effect on forgrounding
    // create protocol and postNotifications to protocol methods for timerEnd & timer Start
    // Width constraints are explicit on graphView UIView - need these to adjust to the parent view.
    // Build to a cocoapod for inclusion to radio app
    // MARK: Init


    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        NotificationCenter.default.addObserver(self, selector: #selector(updateDueToApplicationReturn), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveStateForApplicationBackGrounding), name: UIApplication.didEnterBackgroundNotification, object: nil)

        counterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 14))
        counterLabel.textAlignment = NSTextAlignment.center
        counterLabel.textColor = counterLabelTextColor
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(counterLabel)
        let centreX = NSLayoutConstraint(item: counterLabel,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centreY = NSLayoutConstraint(item: counterLabel,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerY,
                                         multiplier: 1.5,
                                         constant: 0)
        self.addConstraints([centreX, centreY])

        self.counterLabel.text = self.displaySecondsCount(seconds: 0)
    }


    // MARK: Draw


    override public func draw(_ rect: CGRect) {

        //Inner Oval
        let arcSpacer: CGFloat = 5.0
        let innerRect = CGRect(x: arcWidth + arcSpacer, y: arcWidth + arcSpacer, width: self.bounds.width - 2 * (arcWidth + arcSpacer) , height: self.bounds.height - 2 * (arcWidth + arcSpacer))
        let ovalPath = UIBezierPath(ovalIn: innerRect )
        fillColor.setFill()
        ovalPath.fill()

        self.drawOuterArc()

        if(animateRemaining == true) {
            self.startAnimationWithDuration(duration: remaingTime)
        }
    }


    func drawOuterArc() {
        if (self.layer.sublayers?.count == 1) {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = self.arcPath().cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = self.arcColor.cgColor
            shapeLayer.lineWidth = arcWidth
            self.pathLayer = shapeLayer;
            self.layer.addSublayer(self.pathLayer)
        }
        else {
            self.pathLayer.path = self.arcPath().cgPath
        }
    }


    func startAnimationWithDuration(duration: Int) {
        animateRemaining = true
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = CFTimeInterval(duration)
        animation.fillMode = CAMediaTimingFillMode.both
        self.pathLayer.add(animation, forKey: animation.keyPath)
    }


    func arcPath() -> UIBezierPath {
        let centre = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        let radius = min(self.bounds.width/2 - arcWidth/2, self.bounds.height/2 - arcWidth/2)
        let startAngle = (3/2)*π
        let endAngle = (((3/2) - startEndDifferential)  * π) - (completionFactor * 2 * π)
        let arcPath = UIBezierPath(arcCenter: centre, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise:true)

        return arcPath;
    }


    // MARK: Public API


    public func startTimer(duration: Int) {
        sleepTime = duration
        counter = sleepTime
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        self.startAnimationWithDuration(duration: sleepTime)
    }


    public func stopTimer() {
        self.timer.invalidate()
    }


    public func resetOuterArc() {
        self.stopTimer()
        self.animateRemaining = false
        self.completionFactor = 0.0
        self.counterLabel.text = "0.0"
        self.layer.sublayers?.last?.removeFromSuperlayer()
        self.setNeedsDisplay()
    }


    // MARK: Private Methods


    @objc func updateCounter() {
        if (counter == 0) {
            self.delegate?.timerCompleted() //MJDelegate
            counter = sleepTime
            timer.invalidate()
            self.resetOuterArc()
            return
        }
        counter -= 1
        self.delegate?.timerTicked() //MJDelegate
        self.counterLabel.text = displaySecondsCount(seconds: counter)
    }


    @objc func saveStateForApplicationBackGrounding() {
        let remainingTime: Int = counter
        let nowTime = NSDate()
        let userDefaults = UserDefaults.standard
        userDefaults.set(remainingTime, forKey: "remainingTime")
        userDefaults.set(nowTime, forKey: "nowTime")
        userDefaults.synchronize()
    }


    @objc func updateDueToApplicationReturn() {
        //userDefaults
        let userDefaults = UserDefaults.standard
        let previousNowTime = userDefaults.value(forKey: "nowTime")
        if(previousNowTime != nil) {

            let intervalTime = NSDate().timeIntervalSince(previousNowTime as! Date)
            let remainingTime = userDefaults.value(forKey: "remainingTime") as! Double
            var updatedRemainingTime = remainingTime - Double(intervalTime)
            if (updatedRemainingTime < 0) {
                updatedRemainingTime = 0
            }
            counter = Int(updatedRemainingTime)

            let completion = (CGFloat(sleepTime - counter)) / CGFloat(sleepTime)
            self.completionFactor = CGFloat(completion)
            remaingTime = counter
            animateRemaining = true
            self.setNeedsDisplay()
        }
    }


    func displaySecondsCount(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes).\(remainingSeconds)"
    }

}



public protocol TimerControlDelegate: class {

    func timerCompleted()  //MJDelegate
    func timerTicked()
}
