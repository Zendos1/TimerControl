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

    // MARK: - Instance Properties:

    var notificationCentre: NotificationCenter = .default
    var userDefaults: UserDefaults = .standard
    var innerColor = UIColor.gray
    var outerColor = UIColor.blue
    var arcWidth: Int = 1 {
        didSet {
            if self.arcWidth < 1 { self.arcWidth = 1 }
            if self.arcWidth > 10 { self.arcWidth = 10 }
        }
    }
    var arcDashPattern: TimerControlDashPattern = .none
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

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = .clear
        setupApplicationStateObservers()
        setupCounterLabel(textColor: .white)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupApplicationStateObservers()
        setupCounterLabel(textColor: .white)
    }

    // MARK: Public API

    /// configuration options for TimerControl UI
    /// - Parameters:
    ///     - innerColor: UIColor describing the innerOval color
    ///     - outerColor: UIColor describing the outer arc color
    ///     - counterTextColor: UIColor describing the counter text color
    ///     - arcWidth: a value between 1 and 10 describing the arc width as a proportion of the view size
    ///     - arcDashPattern: TimerControlDashPattern enum with 4 preset patterns
    public func configureTimerControl(innerColor: UIColor = .gray,
                                      outerColor: UIColor = .blue,
                                      counterTextColor: UIColor = .white,
                                      arcWidth: Int = 1,
                                      arcDashPattern: TimerControlDashPattern = .none) {
        self.innerColor = innerColor
        self.outerColor = outerColor
        self.counterLabel.textColor = counterTextColor
        self.arcWidth = arcWidth
        self.arcDashPattern = arcDashPattern
    }

    /// start the timer
    /// - Parameters:
    ///     - duration: Int value representing the duration of the timer in seconds
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

    /// stop the timer
    public func stopTimer() {
        timer.invalidate()
        guard sleepDuration > 0 else { return }
        stopTimerAnimation()
    }

    // MARK: Notification Observers

    func setupApplicationStateObservers() {
        notificationCentre.addObserver(self,
                                       selector: #selector(handleApplicationWillForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
        notificationCentre.addObserver(self,
                                       selector: #selector(handleApplicationBackGrounding),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }

    @objc func handleApplicationBackGrounding() {
        cacheTimerStateToUserDefaults()
        prepareArclayerForRedraw()
    }

    @objc func handleApplicationWillForeground() {
        retrieveTimerStateFromUserDefaults()
    }

    func cacheTimerStateToUserDefaults() {
        userDefaults.set(NSDate(), forKey: TimerControlConstants.cacheTime)
        userDefaults.set(sleepDuration, forKey: TimerControlConstants.sleepDuration)
        userDefaults.set(sleepCounter, forKey: TimerControlConstants.sleepCounter)
        userDefaults.synchronize()
    }

    func retrieveTimerStateFromUserDefaults() {
        guard let cacheTime = userDefaults.value(forKey: TimerControlConstants.cacheTime) as? Date,
            let cachedDuration = userDefaults.value(forKey: TimerControlConstants.sleepDuration) as? Double,
            let cachedCounter = userDefaults.value(forKey: TimerControlConstants.sleepCounter) as? Double else {
                return
        }
        let backgroundedTime = NSDate().timeIntervalSince(cacheTime)
        if (cachedCounter - backgroundedTime < 0) {
            resetTimerState()
        } else {
            sleepCounter = Int(cachedCounter - backgroundedTime)
            sleepDuration = Int(cachedDuration)
        }
    }

    // MARK: View

    func setupCounterLabel(textColor: UIColor) {
        counterLabel = UILabel(frame: CGRect.zero)
        counterLabel.textAlignment = .center
        counterLabel.textColor = textColor
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
        guard rect.width == rect.height else {
            fatalError("TimerControl should maintain a 1:1 aspect ratio")
        }
        drawInnerOval(rect)
        drawOuterArc(rect)
        if(sleepDuration > 0) {
            animateArcWithDuration(duration: sleepCounter)
        }
    }

    func drawInnerOval(_ rect: CGRect) {
        let innerOvalRect = CGRect(x: arcWidth(rect) + TimerControlConstants.arcSpacer,
                                   y: arcWidth(rect) + TimerControlConstants.arcSpacer,
                                   width: bounds.width - (2 * (arcWidth(rect) + TimerControlConstants.arcSpacer)) ,
                                   height: bounds.height - (2 * (arcWidth(rect) + TimerControlConstants.arcSpacer)))
        let innerOvalPath = UIBezierPath(ovalIn: innerOvalRect)
        innerColor.setFill()
        innerOvalPath.fill()
    }

    func drawOuterArc(_ rect: CGRect) {
        guard let arclayer = arcLayer() else {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = arcPath(rect).cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = outerColor.cgColor
            shapeLayer.lineWidth = arcWidth(rect)
            shapeLayer.lineDashPattern = configureDashPattern(arcDashPattern)
            shapeLayer.name = TimerControlConstants.arcLayerID
            layer.addSublayer(shapeLayer)
            return
        }
        arclayer.path = arcPath(rect).cgPath
    }

    func configureDashPattern(_ pattern: TimerControlDashPattern) -> [NSNumber] {
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

    func stopTimerAnimation() {
        drawOuterArc(bounds)
        animateArcWithDuration(duration: 1)
        resetTimerState()
    }

    func prepareArclayerForRedraw() {
        arcLayer()?.removeAnimation(forKey: TimerControlConstants.arcLayerAnimationID)
        arcLayer()?.path = nil
    }

    func displaySecondsCount(seconds: Int) -> String {
        return String(format: "%01i:%02i", (seconds / 60), (seconds % 60))
    }

    @objc func updateCounter() {
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

    // MARK: Helper

    func arcEndAngle() -> CGFloat {
        return TimerControlConstants.arcStartAngle - TimerControlConstants.startEndDifferential -
            (completedTimerPercentage() * TimerControlConstants.fullCircleRadians)
    }

    func arcLayer() -> CAShapeLayer? {
        return layer.sublayers?.compactMap({ sublayer in
            sublayer.name == TimerControlConstants.arcLayerID ? sublayer as? CAShapeLayer : nil
        }).first
    }

    func arcWidth(_ rect: CGRect) -> CGFloat {
        return rect.width * TimerControlConstants.arcWidthIncrement * CGFloat(self.arcWidth)
    }

    func animateArcWithDuration(duration: Int) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = CFTimeInterval(duration)
        arcLayer()?.add(animation, forKey: TimerControlConstants.arcLayerAnimationID)
    }

    func arcPath(_ rect: CGRect) -> UIBezierPath {
        let centre = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius = min(bounds.width/2 - arcWidth(rect)/2, bounds.height/2 - arcWidth(rect)/2)
        let arcPath = UIBezierPath(arcCenter: centre,
                                   radius: radius,
                                   startAngle: TimerControlConstants.arcStartAngle,
                                   endAngle: arcEndAngle(),
                                   clockwise:true)
        return arcPath;
    }

    func completedTimerPercentage() -> CGFloat {
        guard sleepDuration > 0 else { return 0.0 }
        return (CGFloat(sleepDuration - sleepCounter)) / CGFloat(sleepDuration)
    }

    func resetTimerState() {
        sleepDuration = 0
        sleepCounter = 0
    }
}

extension TimerControlView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag == true else { return }
        resetTimerState()
        drawOuterArc(bounds)
    }
}
