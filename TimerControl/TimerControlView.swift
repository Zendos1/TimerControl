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


    let arcStartAngle = -CGFloat.pi / 2
    let startEndDifferential: CGFloat = 0.0000001
    let fullCircleRadians = 2 * CGFloat.pi

    var arcDashPattern: TimerDashPattern = .none
    var innerColor: UIColor = UIColor.gray
    var outerColor: UIColor = UIColor.blue
    var arcPercentageWidth: CGFloat = 0.04
    let arcSpacer: CGFloat = 1.0
    var counterLabelTextColor = UIColor.white
    var counterLabel = UILabel()
    var timer = Timer()
    var sleepCounter: Int = 0
    var sleepDuration: Int = 0 {
        didSet {
            if (sleepDuration >= 3600) {
                sleepDuration = 3599
            }
            counterLabel.text = displaySecondsCount(seconds: sleepDuration)
        }
    }

    // MARK: TODO
    // create protocol and postNotifications to protocol methods for timerEnd & timer Start
    // Width constraints are explicit on graphView UIView - need these to adjust to the parent view.
    // Extract values to a constants file
    // Guarantee 1:1 UIView setup



    // MARK: Init

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupApplicationStateObservers()
        setupCounterLabel()
    }

    // MARK: Public API

    public func configureTimerControl(innerColor: UIColor = .gray,
                                      outerColor: UIColor = .blue,
                                      counterTextColor: UIColor = .white,
                                      arcPercentageWidth: CGFloat = 0.04,
                                      arcDashPattern: TimerDashPattern = .none) {
        self.innerColor = innerColor
        self.outerColor = outerColor
        self.counterLabelTextColor = counterTextColor
        self.arcPercentageWidth = arcPercentageWidth
        self.arcDashPattern = arcDashPattern
    }

    public func startTimer(duration: Int) {
        sleepDuration = duration
        sleepCounter = sleepDuration
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(updateCounter),
                                     userInfo: nil,
                                     repeats: true)
        animateArcWithDuration(duration: sleepDuration)
    }

    public func stopTimer() {
        timer.invalidate()
        stopTimerAnimation()
    }

    // MARK: Notification Observers

    private func setupApplicationStateObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleApplicationWillForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleApplicationBackGrounding),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc private func handleApplicationBackGrounding() {
        cacheTimerStateToUserDefaults()
        removeArcLayer()
    }

    @objc private func handleApplicationWillForeground() {
        retrieveTimerStateFromUserDefaults()
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
        let backgroundedTime = NSDate().timeIntervalSince(cacheTime)
        if (cachedSleepCounter - backgroundedTime < 0) {
            resetTimerState()
        } else {
            sleepCounter = Int(cachedSleepCounter - backgroundedTime)
            sleepDuration = Int(cachedSleepDuration)
        }
    }

    // MARK: View

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

    override public func draw(_ rect: CGRect) {
        drawInnerOval(rect)
        drawOuterArc(rect)
        if(sleepDuration > 0) {
            animateArcWithDuration(duration: sleepCounter)
        }
    }

    private func drawInnerOval(_ rect: CGRect) {
        let innerOvalRect = CGRect(x: arcWidth(rect) + arcSpacer,
                                   y: arcWidth(rect) + arcSpacer,
                                   width: bounds.width - (2 * (arcWidth(rect) + arcSpacer)) ,
                                   height: bounds.height - (2 * (arcWidth(rect) + arcSpacer)))
        let innerOvalPath = UIBezierPath(ovalIn: innerOvalRect)
        innerColor.setFill()
        innerOvalPath.fill()
    }

    private func drawOuterArc(_ rect: CGRect) {
        if (isOuterArcDrawn()) {
            arcLayer()?.path = arcPath(rect).cgPath
        } else {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = arcPath(rect).cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = outerColor.cgColor
            shapeLayer.lineWidth = rect.width * arcPercentageWidth
            shapeLayer.lineDashPattern = configureDashPattern(arcDashPattern)
            layer.addSublayer(shapeLayer)
        }
    }

    private func configureDashPattern(_ pattern: TimerDashPattern) -> [NSNumber] {
        switch pattern {
        case .narrow:
            return [2, 1]
        case .medium:
            return [4, 1]
        case .wide:
            return [6, 1]
        default:
            return []
        }
    }

    private func arcEndAngle() -> CGFloat {
        return arcStartAngle - startEndDifferential - (completedTimerPercentage() * fullCircleRadians)
    }

    private func arcLayer() -> CAShapeLayer? {
        return layer.sublayers?[1] as? CAShapeLayer
    }

    private func isOuterArcDrawn() -> Bool {
        guard let subLayerCount = layer.sublayers?.count else { return false }
        return subLayerCount > [counterLabel.layer].count
    }

    private func arcWidth(_ rect: CGRect) -> CGFloat {
        return rect.width * arcPercentageWidth
    }

    private func animateArcWithDuration(duration: Int) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = CFTimeInterval(duration)
        arcLayer()?.add(animation, forKey: animation.keyPath)
    }

    private func arcPath(_ rect: CGRect) -> UIBezierPath {
        let centre = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius = min(bounds.width/2 - arcWidth(rect)/2, bounds.height/2 - arcWidth(rect)/2)
        let arcPath = UIBezierPath(arcCenter: centre, radius: radius, startAngle: arcStartAngle, endAngle: arcEndAngle(), clockwise:true)
        return arcPath;
    }

    private func stopTimerAnimation() {
        drawOuterArc(bounds)
        animateArcWithDuration(duration: 1)
        resetTimerState()
    }

    private func resetTimerState() {
        sleepDuration = 0
        sleepCounter = 0
    }

    private func removeArcLayer() {
        layer.sublayers?.last?.removeFromSuperlayer()
    }

    func displaySecondsCount(seconds: Int) -> String {
        return String(format: "%01i:%02i", (seconds / 60), (seconds % 60))
    }

    @objc private func updateCounter() {
        if (sleepCounter == 0) {
            delegate?.timerCompleted()
            timer.invalidate()
            resetTimerState()
            return
        }
        sleepCounter -= 1
        delegate?.timerTicked()
        counterLabel.text = displaySecondsCount(seconds: sleepCounter)
    }

    private func completedTimerPercentage() -> CGFloat {
        guard sleepDuration > 0 else { return 0.0 }
        return (CGFloat(sleepDuration - sleepCounter)) / CGFloat(sleepDuration)
    }
}

extension TimerControlView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag == true else { return }
        resetTimerState()
        drawOuterArc(bounds)
    }
}
