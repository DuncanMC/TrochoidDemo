//
//  TrochoidView.swift
//  TrochoidDemo
//
//  Created by Duncan Champney on 1/17/17.
//  Copyright © 2017 Duncan Champney. All rights reserved.
//

import UIKit

class TrochoidView: UIView {
  
  @IBInspectable public var fillColor: UIColor?
  
  var drawAxis: Bool = true  {
    didSet {
      forceUpdate()
    }
  }

  public var rotation: CGFloat = 0 {
    didSet {
      forceUpdate()
    }
  }
  
  @IBInspectable public var radius: CGFloat = 30 {
    didSet {
      if radius != oldValue {
        forceUpdate()
      }
    }
  }
  @IBInspectable public var lambda: CGFloat = 0.8 {
    didSet {
      if lambda != oldValue {
        forceUpdate()
      }
    }
  }
  
  public var smooth: Bool = true {
    didSet {
      forceUpdate()
    }
  }
 
  private var lineLength: CGFloat = 0
  
  private var  maxTheta:CGFloat = 0
  
  private var _trochoidCurve: UIBezierPath!
  
  private var trochoidCurve: UIBezierPath {
    lineLength = radius * lambda
    if  _trochoidCurve == nil {
      var points: [CGPoint] = []
      let width = self.bounds.size.width
      let   waveCount =   width / (radius * 4)
      maxTheta = CGFloat.pi * 2 * waveCount
      
      _trochoidCurve = UIBezierPath()
      var steps: Int = 0
      
      let baseY = self.bounds.size.height / 2
      //let pointsPer2Pi = width / (CGFloat.pi * 2)
      for theta in stride(from: 0,
                          to: maxTheta,
                          by: maxTheta / (width/4) ) {
                            steps += 1
                            let xOut = radius * (theta) + lineLength * cos(theta + rotation) - lineLength
                            let y = lineLength * sin(theta + rotation)
                            //print("y = \(y)")
                            let yOut = baseY - y
                            let point = CGPoint(x: xOut, y: yOut)
                            points.append(point)
                            
      }
      
      var smoothedPoints: [CGPoint]
      if smooth {
        (smoothedPoints, _) = smoothPointsInArray(points, granularity: 6)
      }
      else {
        smoothedPoints = points
      }
      var firstPoint: Bool = false
      if fillColor == nil {
        firstPoint = true
      }
      else {
        _trochoidCurve.move(to: CGPoint(x: -1, y: bounds.height+1))
      }
      for aPoint in smoothedPoints {
        if firstPoint {
          _trochoidCurve.move(to: aPoint)
          firstPoint = false
        }
        else {
          _trochoidCurve.addLine(to: aPoint)
        }
      }
      if fillColor != nil {
        _trochoidCurve.addLine(to: CGPoint(x: bounds.width+1, y: bounds.height+1))
        _trochoidCurve.addLine(to: CGPoint(x: -1, y: bounds.height+1))
        _trochoidCurve.close()
      }

      
      //print("Loop in \(steps) steps")
    }
    return _trochoidCurve
  }
  
  public func forceUpdate()
  {
    _trochoidCurve = nil
    setNeedsDisplay()
  }
  
  override func draw(_ rect: CGRect) {
    let baseY = self.bounds.size.height / 2
    
    //--------------------------
    let context = UIGraphicsGetCurrentContext()
    if drawAxis && false{
      //Draw the origin line
      //context?.saveGState()
      UIColor.blue.set()
      let blue:[CGFloat] = [0, 0, 1, 1]
      context?.setStrokeColor(blue);
      context?.setLineWidth(1.0)
      context?.strokeLineSegments(between: [CGPoint(x:0, y: baseY), CGPoint(x:self.bounds.size.width, y: baseY)])
      //context?.restoreGState()
      
    }
    //--------------------------
    trochoidCurve.stroke()
    if let fillColor = fillColor {
      fillColor.set()
      trochoidCurve.fill()
    }
    if drawAxis {
      context?.setLineWidth(2.0)

      var center = CGPoint(x: 0, y: baseY)
      var rect = CGRect(origin: center, size: CGSize(width: 0, height: 0))
      rect = rect.insetBy(dx: -lineLength, dy: -lineLength)
      let orange:[CGFloat] = [1, 0.5, 0, 1]
      context?.setStrokeColor(orange);
      context?.strokeEllipse(in: rect)
      center.x += cos(CGFloat.pi * 2 - rotation - CGFloat.pi / 3.06*lambda) * lineLength
      center.y += sin(CGFloat.pi * 2 - rotation - CGFloat.pi / 3.06*lambda) * lineLength
      rect = CGRect(origin: center, size: CGSize(width: 0, height: 0))
      rect = rect.insetBy(dx: -3, dy: -3)
      let darkBlue:[CGFloat] = [53/255.0, 87/255.0, 147/255.0, 1]
      context?.setFillColor(darkBlue);
      context?.fillEllipse(in: rect)

      
    }
  }
}
