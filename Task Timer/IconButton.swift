//
//  IconButton.swift
//  Task Timer
//
//  Created by Joseph Chan on 5/18/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import UIKit

@IBDesignable
class IconButton: UIButton {
    @IBInspectable var buttonColor: UIColor = UIColor.gray
    @IBInspectable var buttonPressedColor: UIColor = UIColor.darkGray
    @IBInspectable var type: Int = -1

    // Because @IBInspectable doesn't support enum, we have to fake it.
    static let kCloseButton: Int = 0
    static let kSettingButton: Int = 1
    
    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if isHighlighted {
            buttonPressedColor.setStroke()
        } else {
            buttonColor.setStroke()
        }
        
        switch type {
        case IconButton.kCloseButton: drawCloseButton(rect)
        case IconButton.kSettingButton: drawSettingButton(rect)
        default:
            let framePath = UIBezierPath(roundedRect: rect.insetBy(dx: 1.0, dy: 1.0), cornerRadius: 4.0)
            framePath.lineWidth = 2.0
            framePath.stroke()
        }
    }
 
    private func drawCloseButton(_ rect: CGRect) {
        let lineWidth: CGFloat = 2.0
        let square = calculateShapeBounds(bounds)
        let radius = (square.size.width - lineWidth) / 2
        let crossWidth = radius - lineWidth * 2.5
        
        let path = UIBezierPath(arcCenter: bounds.origin, radius: radius, startAngle: 0, endAngle: 2 * CGFloat(Double.pi), clockwise: true)
        path.move(to: CGPoint(x: bounds.origin.x - crossWidth, y: bounds.origin.y))
        path.addLine(to: CGPoint(x: bounds.origin.x + crossWidth, y: bounds.origin.y))
        path.move(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y - crossWidth))
        path.addLine(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y + crossWidth))
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.translateBy(x: bounds.width / 2, y: bounds.height / 2)
        context.rotate(by: CGFloat(Double.pi / 4))
        
        path.lineCapStyle = .round
        path.lineWidth = lineWidth
        path.stroke()
        context.restoreGState()
    }
    
    private func drawSettingButton(_ rect: CGRect) {
        let lineWidth: CGFloat = 2.0
        let square = calculateShapeBounds(bounds)
        let insetSize = (square.width - 22.0) / 2 + lineWidth
        let outerBounds = square.insetBy(dx: insetSize, dy: insetSize)
        let innerBounds = outerBounds.insetBy(dx: lineWidth, dy: lineWidth)
        
        let innerPath = UIBezierPath(ovalIn: innerBounds)
        innerPath.lineWidth = lineWidth * 2
        innerPath.stroke()
        
        let count: Int = 8
        let dashLen = outerBounds.width * CGFloat(Double.pi) / CGFloat(count * 2)
        let outerPath = UIBezierPath(ovalIn: outerBounds)
        let pattern: [CGFloat] = [dashLen, dashLen]
        outerPath.setLineDash(pattern, count: pattern.count, phase: 2.0)
        outerPath.lineWidth = lineWidth * 2
        outerPath.stroke()
}
    
    private func calculateShapeBounds(_ rect: CGRect) -> CGRect {
        var squareBound = rect
        if rect.height > rect.width {
            squareBound.size.height = rect.width
            squareBound.origin.y += (rect.height - rect.width) / 2
        } else if rect.height < rect.width {
            squareBound.size.width = rect.height
            squareBound.origin.x += (rect.width - rect.height) / 2
        }  // Nothing to do if height == width
        return squareBound
    }
}
