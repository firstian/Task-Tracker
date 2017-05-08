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
    @IBInspectable var circleForeground: UIColor = .darkGray
    @IBInspectable var circleBackground: UIColor = .lightGray
    @IBInspectable var circleStrokeWidth: CGFloat = 10.0
    
    private var shapeLayer = CAShapeLayer()
    
    func addShapeLayer() {
        let size = min(bounds.width, bounds.height)
        shapeLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        shapeLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        self.layer.addSublayer(shapeLayer)
        
        shapeLayer.path = createCirclePath(startAngle: -π / 2, endAngle: 3 * π / 2).cgPath
        shapeLayer.strokeColor = circleForeground.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = circleStrokeWidth
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
    }
    
    func start(duration: TimeInterval) {
        // First set the final values of the model properties.
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 1.0
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = duration
        
        shapeLayer.add(animation, forKey: animation.keyPath)
    }
    
    func reset() {
        // Kill the animation so it doesn't animate the strokeEnd going back.
        shapeLayer.removeAllAnimations()
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
    }
    
    // Both pause & resume code came out of Core Animation Programming Guide.
    // Detail explanation: http://coveller.com/2016/05/core_animation_timing/
    func pause() {
        // Grab the current local time, before we pause
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        // Set the layer speed to 0.0 to pause the animation
        layer.speed = 0.0
        // Move the timeOffset to paused time to freeze the animation. Otherwise
        // it will snap back to the model value.
        layer.timeOffset = pausedTime
    }
    
    func resume() {
        // Get the local time when it was paused from timeOffset
        let pausedTime = layer.timeOffset
        // Set the layer speed back to 1.0 to resume the animation
        layer.speed = 1.0
        // Change the timeOffset and beginTime back to 0.0, but resume
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    override func awakeFromNib() {
        // Do the rest of the initialization here to make sure that all the
        // custom properties from the NIB are initialized (not true for
        // init?(coder:)).
        addShapeLayer()
    }
    
    override func draw(_ rect: CGRect) {
        // Draw the background circle.
        let circle = createCirclePath(startAngle: 0, endAngle: 2 * π)
        circleBackground.setStroke()
        circle.lineWidth = circleStrokeWidth
        circle.stroke()
    }

    private func createCirclePath(startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: shapeLayer.position,
                            radius: (shapeLayer.bounds.width - circleStrokeWidth) / 2,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true)
    }
    
}
