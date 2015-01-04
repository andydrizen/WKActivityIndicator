//
//  WatchKitActivityIndicator.swift
//  WatchKitActivityIndicator
//
//  Created by Andy Drizen on 03/01/2015.
//  Copyright (c) 2015 Andy Drizen. All rights reserved.
//

import UIKit

class WatchKitActivityIndicator: UIView {
    
    let numberOfBalls = 6
    
    var shouldStop = false
    var offset: CGFloat = 0
    var speed: CGFloat = 0

    var displayLink : CADisplayLink?
    
    var alphas : [CGFloat] = []
    var scales : [CGFloat] = []

    var stoppedCompletionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        resetProperties()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetProperties() {
        if (displayLink != nil) {
            displayLink!.invalidate()
        }
        
        speed = 3
        offset = 0
        
        alphas = []
        scales = []
        
        shouldStop = false
        
        for i in 0..<numberOfBalls {
            alphas.append(0.2 - CGFloat(numberOfBalls - i - 1) * 0.3)
            scales.append(0.2 - CGFloat(numberOfBalls - i - 1) * 0.3)
        }
    }
    
    func startAnimating() {
        resetProperties()
        displayLink = CADisplayLink(target: self, selector: "handleDisplayLink:")
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func stopAnimating(completion: () -> Void) {
        shouldStop = true
        stoppedCompletionHandler = completion
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        
        let center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        
        var referenceBallWidth = floor(CGRectGetWidth(rect) / (CGFloat(numberOfBalls)/2)) - 1
        
        let radius = Double(CGRectGetWidth(rect) - referenceBallWidth) / 2
        
        for i in 0..<numberOfBalls {
            
            let angle = -1 * M_PI/2 + M_PI/180 * (Double(CGFloat(i) * 360.0 / CGFloat(numberOfBalls)) + Double(offset))

            let x = center.x + CGFloat(sin(angle) * radius)
            let y = center.y + CGFloat(cos(angle) * radius)

            let ballWidth = referenceBallWidth * max(0, scales[i])
            UIColor(white: 1.0, alpha:max(0, min(alphas[i], 1))).set()
            CGContextAddEllipseInRect(context, CGRectMake(x - ballWidth/2, y - ballWidth/2, ballWidth, ballWidth))
            CGContextDrawPath(context, kCGPathFill)
        }
    }
    
    func handleDisplayLink(displayLink : CADisplayLink) {
        let growthRate = CGFloat(0.08)
        let maxSpeed : CGFloat = 5
        
        if (speed < maxSpeed) {
            speed = speed + 2 * growthRate
            let scale = speed/maxSpeed
            transform = CGAffineTransformMakeScale(scale, scale)
        }
        
        if (speed > maxSpeed) {
            speed = maxSpeed
            transform = CGAffineTransformIdentity
        }
        
        offset = offset - speed

        if (shouldStop) {
            for i in 0..<numberOfBalls {
                alphas[i] = max(0, alphas[i] - growthRate)
            }
            
            if (maxElement(alphas) <= 0) {
                if (stoppedCompletionHandler != nil) {
                    stoppedCompletionHandler!()
                }
                displayLink.invalidate()
            }
        }
        else{
            if (minElement(alphas) <= 1) {
                for i in 0..<numberOfBalls {
                    alphas[i] = min(1, alphas[i] + growthRate)
                }
            }
            
            if (minElement(scales) <= 1) {
                for i in 0..<numberOfBalls {
                    scales[i] = min(1, scales[i] + growthRate)
                }
            }
        }
        
        setNeedsDisplay()
    }
}
