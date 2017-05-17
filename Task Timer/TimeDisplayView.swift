//
//  TimeDisplayView.swift
//  Task Timer
//
//  Created by Joseph Chan on 5/4/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import UIKit

let π = CGFloat(Double.pi)

@IBDesignable
class TimeDisplayView: UIView {
    @IBInspectable var circleForeground: UIColor = .lightGray
    @IBInspectable var circleBackground: UIColor = .darkGray
    @IBInspectable var circleStrokeWidth: CGFloat = 10.0
    
    private var shapeLayer = CAShapeLayer()
    
    // This initializer in needed so that the view can be programmatically
    // created correctly, with the CAShapeLayer. It is needed so that the
    // preview in IB works.
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShapeLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Don't call addShapeLayer here because none of the custom properties
        // are initialized here yet. Instead, call it from awakeFromNib().
    }
    
    func addShapeLayer() {
        let size = min(bounds.width, bounds.height)
        shapeLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        shapeLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        self.layer.addSublayer(shapeLayer)
        
        shapeLayer.path = createCirclePath().cgPath
        shapeLayer.strokeColor = circleForeground.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = circleStrokeWidth
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
    }

    func setupAnimation(duration: TimeInterval, from start: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        // The animation starts at the start time, which is a fraction of the
        // total duration.
        animation.fromValue = Float(start / duration)
        animation.toValue = 1.0
        // We still want the animation to finish at the designated time, so we
        // have to subtract the start time from the total duration.
        animation.duration = duration - start
        
        shapeLayer.add(animation, forKey: animation.keyPath)
    }
    
    func start(duration: TimeInterval, from start: TimeInterval) {
        // First set the final values of the model properties.
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 1.0
        setupAnimation(duration: duration, from: start)
        
        // We could have reset speed, timeOffset, and beginTime of the layer
        // here instead of in reset(). The reason we don't is because this
        // method is also used to reinstate animation after the app switch
        // from background mode. If the animation was paused when the app was
        // switched into background, speed would have been set to 0.0, and when
        // we reinstate the animation, it'll still be paused. Resume at that
        // point will work correctly. Had we reset the layer speed here, paused
        // while switching back from background would not have worked.
    }
    
    func reset() {
        // Kill the animation so it doesn't animate the strokeEnd going back.
        shapeLayer.removeAllAnimations()
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
        
        // Reset animation params that might have changed because reset is
        // called while the animation is paused.
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
    }
    
    // Both pause & resume code came out of Core Animation Programming Guide.
    // Detail explanation: http://coveller.com/2016/05/core_animation_timing/
    func pause() {
        // Grab the current local time, before we pause
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        // Set the layer speed to 0.0 to pause the animation
        shapeLayer.speed = 0.0
        // Move the timeOffset to paused time to freeze the animation. Otherwise
        // it will snap back to the model value.
        shapeLayer.timeOffset = pausedTime
    }
    
    func resume() {
        // Get the local time when it was paused from timeOffset
        let pausedTime = shapeLayer.timeOffset
        // Set the layer speed back to 1.0 to resume the animation
        shapeLayer.speed = 1.0
        // Change the timeOffset and beginTime back to 0.0 to clear the offset
        // between shapeLayer and parent layer
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        // Now resume from timeSincePause
        shapeLayer.beginTime = timeSincePause
    }
    
    override func awakeFromNib() {
        // Do the rest of the initialization here to make sure that all the
        // custom properties from the NIB are initialized (not true for
        // init?(coder:)).
        addShapeLayer()
    }
    
    override func draw(_ rect: CGRect) {
        // Draw the background circle.
        let circle = createCirclePath()
        circleBackground.setStroke()
        circle.lineWidth = circleStrokeWidth
        circle.stroke()
    }

    private func createCirclePath() -> UIBezierPath {
        let size = min(bounds.width, bounds.height)
        // The order of the startAngle & endAngle need to match clockwise, or
        // else the animation won't work correctly.
        return UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
                            radius: (size - circleStrokeWidth) / 2,
                            startAngle: 3 * π / 2,
                            endAngle: -π / 2,
                            clockwise: false)
    }
    
}
