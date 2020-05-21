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
    public weak var delegate: TimerControlDelegate?
    var pathLayer = CAShapeLayer()
    let arcStartAngle = -CGFloat.pi / 2
    let startEndDifferential: CGFloat = 0.0000001
    let fullCircleRadians = 2 * CGFloat.pi
    public var completionFactor: CGFloat = 0.0
    var fillColor: UIColor = UIColor.gray
    var arcColor: UIColor = UIColor.blue
    var arcPercentageWidth: CGFloat = 0.04
    var arcWidth: CGFloat = 0
    let arcSpacer: CGFloat = 1.0
    var counterLabelTextColor: UIColor = UIColor.white
    var counterLabel = UILabel()
    public var remaingTime: Int = 0
    public var animateRemainingArc: Bool = false
    var timer = Timer()
    var counter: Int = 0
    var sleepTime: Int = 10 {
        didSet {
            if (sleepTime >= 3600) {
                sleepTime = 3599
            }
            counterLabel.text = displaySecondsCount(seconds: sleepTime)
            counter = sleepTime
        }
    }

    // MARK: TODO
    // possibly remove the CAShapelayer from the view on applicationEnterBackGround then redraw effect on forgrounding
    // create protocol and postNotifications to protocol methods for timerEnd & timer Start
    // Width constraints are explicit on graphView UIView - need these to adjust to the parent view.
    // Build to a cocoapod for inclusion to radio app
    // Extract values to a constants file
    // Guarantee 1:1 UIView setup

    // MARK: Init


    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupApplicationStateObservers()
        setupCounterLabel()
    }

    private func setupApplicationStateObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDueToApplicationReturn),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveStateForApplicationBackGrounding),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    private func setupCounterLabel() {
        counterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        counterLabel.textAlignment = NSTextAlignment.center
        counterLabel.textColor = counterLabelTextColor
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(counterLabel)
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
        addConstraints([centreX, centreY])
        counterLabel.text = displaySecondsCount(seconds: 0)
    }

    // MARK: Draw

    override public func draw(_ rect: CGRect) {
        drawInnerOval(rect)
        drawOuterArc(endAngle: arcStartAngle - startEndDifferential - (completionFactor * fullCircleRadians))
        if(animateRemainingArc == true) {
            startAnimationWithDuration(duration: remaingTime)
        }
    }

    private func drawInnerOval(_ rect: CGRect) {
        arcWidth = rect.width * arcPercentageWidth
        let innerOvalRect = CGRect(x: arcWidth + arcSpacer,
                                   y: arcWidth + arcSpacer,
                                   width: bounds.width - (2 * (arcWidth + arcSpacer)) ,
                                   height: bounds.height - (2 * (arcWidth + arcSpacer)))
        let innerOvalPath = UIBezierPath(ovalIn: innerOvalRect)
        fillColor.setFill()
        innerOvalPath.fill()
    }

    private func drawOuterArc(endAngle: CGFloat) {
        if (outerArcNotDrawn()) {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = arcPath(endAngle: endAngle).cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = arcColor.cgColor
            shapeLayer.lineWidth = arcWidth
            pathLayer = shapeLayer;
            layer.addSublayer(pathLayer)
        } else {
            pathLayer.path = arcPath(endAngle: endAngle).cgPath
        }
    }

    private func outerArcNotDrawn() -> Bool {
        layer.sublayers?.count == 1
    }

    func startAnimationWithDuration(duration: Int) {
        animationCompleted = false
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = CFTimeInterval(duration)
        animation.fillMode = CAMediaTimingFillMode.both
        pathLayer.add(animation, forKey: animation.keyPath)
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
        startAnimationWithDuration(duration: sleepTime)
    }


    public func stopTimer() {
        self.timer.invalidate()
    }





    // MARK: Private Methods

    private func resetOuterArc() {
        self.stopTimer()
        self.animationCompleted = true
        self.completionFactor = 0.0
        self.layer.sublayers?.last?.removeFromSuperlayer()
        self.setNeedsDisplay()
    }

    @objc func updateCounter() {
        if (counter == 0) {
            delegate?.timerCompleted()
            timer.invalidate()
            self.resetOuterArc()
            return
        }
        counter -= 1
        delegate?.timerTicked()
        counterLabel.text = displaySecondsCount(seconds: counter)
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
            completionFactor = CGFloat(completion)
            remaingTime = counter
            animateRemainingArc = true
            setNeedsDisplay()
        }
    }

    func displaySecondsCount(seconds: Int) -> String {
        return String(format: "%01i:%02i", (seconds / 60), (seconds % 60))
    }
}

extension TimerControlView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        layer.sublayers?.last?.removeFromSuperlayer()
        let endAngle = arcStartAngle - startEndDifferential
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = arcPath(endAngle: endAngle).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = arcColor.cgColor
        shapeLayer.lineWidth = arcWidth
        pathLayer = shapeLayer;
        layer.addSublayer(pathLayer)
    }
}

public protocol TimerControlDelegate: class {
    func timerCompleted()
    func timerTicked()
}
