//
//  TimerControlView.swift
//  TimerControl
//
//  Created by mark jones on 15/05/2020.
//  Copyright © 2020 mark jones. All rights reserved.
//

import UIKit

public class TimerControlView: UIView {
    public weak var delegate: TimerControlDelegate?
    var pathLayer = CAShapeLayer()
    let arcStartAngle = -CGFloat.pi / 2
    let startEndDifferential: CGFloat = 0.0000001
    let fullCircleRadians = 2 * CGFloat.pi
    var fillColor: UIColor = UIColor.gray
    var arcColor: UIColor = UIColor.blue
    var arcPercentageWidth: CGFloat = 0.04
    var arcWidth: CGFloat = 0
    let arcSpacer: CGFloat = 1.0
    var counterLabelTextColor: UIColor = UIColor.white
    var counterLabel = UILabel()
    public var animateRemainingArc: Bool = false
    var timer = Timer()
    var sleepCounter: Int = 0
    var sleepDuration: Int = 10 {
        didSet {
            if (sleepDuration >= 3600) {
                sleepDuration = 3599
            }
            counterLabel.text = displaySecondsCount(seconds: sleepDuration)
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
                                               selector: #selector(updateForApplicationWillForeground),
                                               name: UIApplication.willEnterForegroundNotification,
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
        drawOuterArc(endAngle: arcStartAngle - startEndDifferential - (completedTimerPercentage() * fullCircleRadians))
        if(animateRemainingArc == true) {
            startAnimationWithDuration(duration: sleepCounter, delegate: self)
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

    private func startAnimationWithDuration(duration: Int, delegate: CAAnimationDelegate? = nil) {
        animateRemainingArc = true
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = delegate
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = CFTimeInterval(duration)
        animation.fillMode = CAMediaTimingFillMode.both
        pathLayer.add(animation, forKey: animation.keyPath)
    }

    private func arcPath(endAngle: CGFloat) -> UIBezierPath {
        let centre = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius = min(bounds.width/2 - arcWidth/2, bounds.height/2 - arcWidth/2)
        let arcPath = UIBezierPath(arcCenter: centre, radius: radius, startAngle: arcStartAngle, endAngle: endAngle, clockwise:true)
        return arcPath;
    }

    // MARK: Public API

    public func startTimer(duration: Int) {
        sleepDuration = duration
        sleepCounter = sleepDuration
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        startAnimationWithDuration(duration: sleepDuration)
    }

    public func stopTimer() {
        timer.invalidate()
        startAnimationForRemainingArc()
    }

    private func startAnimationForRemainingArc() {
        let completedAngle = completedTimerPercentage() * fullCircleRadians
        drawOuterArc(endAngle: arcStartAngle - startEndDifferential - completedAngle)
        startAnimationWithDuration(duration: 1, delegate: self)
    }

    @objc private func updateCounter() {
        if (sleepCounter == 0) {
            delegate?.timerCompleted()
            timer.invalidate()
            return
        }
        sleepCounter -= 1
        delegate?.timerTicked()
        counterLabel.text = displaySecondsCount(seconds: sleepCounter)
    }

    @objc private func saveStateForApplicationBackGrounding() {
        cacheTimerStateToUserDefaults()
        layer.sublayers?.last?.removeFromSuperlayer()
    }

    @objc private func updateForApplicationWillForeground() {
        guard let cacheTime = UserDefaults.standard.value(forKey: "CacheTime") as? Date,
            let cachedSleepDuration = UserDefaults.standard.value(forKey: "SleepDuration") as? Double,
            let cachedSleepCounter = UserDefaults.standard.value(forKey: "SleepCounter") as? Double else {
                return
        }
        let intervalTime = NSDate().timeIntervalSince(cacheTime)
        sleepCounter = cachedSleepCounter - intervalTime < 0 ? 0 : Int(cachedSleepCounter - intervalTime)
        sleepDuration = Int(cachedSleepDuration)
        animateRemainingArc = true
    }

    private func cacheTimerStateToUserDefaults() {
        UserDefaults.standard.set(NSDate(), forKey: "CacheTime")
        UserDefaults.standard.set(sleepDuration, forKey: "SleepDuration")
        UserDefaults.standard.set(sleepCounter, forKey: "SleepCounter")
        UserDefaults.standard.synchronize()
    }

    private func retrieveTimerStateFromUserDefaults() {
        guard let cacheTime = UserDefaults.standard.value(forKey: "CacheTime") as? Date,
            let cachedSleepDuration = UserDefaults.standard.value(forKey: "SleepDuration") as? Double,
            let cachedSleepCounter = UserDefaults.standard.value(forKey: "SleepCounter") as? Double else {
                return
        }
        let intervalTime = NSDate().timeIntervalSince(cacheTime)
        sleepCounter = cachedSleepCounter - intervalTime < 0 ? 0 : Int(cachedSleepCounter - intervalTime)
        sleepDuration = Int(cachedSleepDuration)
        animateRemainingArc = true
    }

    func completedTimerPercentage() -> CGFloat {
        return (CGFloat(sleepDuration - sleepCounter)) / CGFloat(sleepDuration)
    }

    func displaySecondsCount(seconds: Int) -> String {
        return String(format: "%01i:%02i", (seconds / 60), (seconds % 60))
    }
}

extension TimerControlView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        resetOuterArc()
        sleepDuration = 0
    }

    private func resetOuterArc() {
        let endAngle = arcStartAngle - startEndDifferential
        pathLayer.path = arcPath(endAngle: endAngle).cgPath
    }
}
