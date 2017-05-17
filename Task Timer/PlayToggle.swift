//
//  PlayToggle.swift
//  Task Timer
//
//  Created by Joseph Chan on 5/14/17.
//  Copyright © 2017 Joseph Chan. All rights reserved.
//

import UIKit

@IBDesignable
class PlayToggle: UIButton {
    @IBInspectable var buttonColor: UIColor = UIColor.gray
    @IBInspectable var buttonPressedColor: UIColor = UIColor.darkGray

    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let pathFunc = isSelected ? pauseImagePath : playImagePath
        let path = pathFunc(bounds)
        if isHighlighted {
            buttonPressedColor.setFill()
        } else {
            buttonColor.setFill()
        }
        path.fill()
    }
    
    private func playImagePath(rect: CGRect) -> UIBezierPath {
        let shapeBounds = calculateShapeBounds(rect)
        let startPt = shapeBounds.origin
        let path = UIBezierPath()
        path.move(to: startPt)
        path.addLine(to: CGPoint(x: startPt.x, y: startPt.y + shapeBounds.height))
        path.addLine(to: CGPoint(x: startPt.x + shapeBounds.width,
                                 y: startPt.y + shapeBounds.height / 2))
        path.close()
        return path
    }
    
    private func pauseImagePath(rect: CGRect) -> UIBezierPath {
        let shapeBounds = calculateShapeBounds(rect)
        let gapWidth = 0.2 * shapeBounds.width
        let barSize = CGSize(width: (shapeBounds.width - gapWidth) / 2,
                             height: shapeBounds.height)

        let path = UIBezierPath(rect: CGRect(origin: shapeBounds.origin,
                                             size: barSize))
        let bar2 = path.copy() as! UIBezierPath
        bar2.apply(CGAffineTransform(translationX: barSize.width + gapWidth, y: 0.0))
        path.append(bar2)
        return path
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

        // Get sin(60) for equilateral triangle
        let arrowWidth = squareBound.height * sin(CGFloat(Double.pi / 3))
        // Return the tightest bound for the arrow.
        return squareBound.insetBy(dx: (squareBound.width - arrowWidth) / 2, dy: 0.0)
    }
}
