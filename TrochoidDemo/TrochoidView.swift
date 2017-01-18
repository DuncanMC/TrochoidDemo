//
//  TrochoidView.swift
//  TrochoidDemo
//
//  Created by Duncan Champney on 1/17/17.
//  Copyright © 2017 Duncan Champney. All rights reserved.
//

import UIKit

class TrochoidView: UIView {
  
  var fillColor: UIColor?
  
  var drawAxis: Bool = false  {
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
      
      var firstPoint: Bool = true
      _trochoidCurve = UIBezierPath()
      var steps: Int = 0
      
      let baseY = self.bounds.size.height / 2
      //let pointsPer2Pi = width / (CGFloat.pi * 2)
      for theta in stride(from: 0,
                          to: maxTheta,
                          by: maxTheta / (width/4) ) {
                            steps += 1
                            //print("theta = \(theta)")
                            let xOut = radius * (theta) + lineLength * cos(theta + rotation) - lineLength
                            if firstPoint {
                              firstPoint = false
                            }
                            let y = radius * sin(theta + rotation)
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
      for (index, aPoint) in smoothedPoints.enumerated() {
        if index == 0 {
          _trochoidCurve.move(to: aPoint)
        }
        else {
          _trochoidCurve.addLine(to: aPoint)
        }
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
    if drawAxis {
      //Draw the origin line
      let context = UIGraphicsGetCurrentContext()
      context?.saveGState()
      UIColor.blue.set()
      let blue:[CGFloat] = [0, 0, 1, 1]
      context?.setStrokeColor(blue);
      context?.setLineWidth(1.0)
      context?.strokeLineSegments(between: [CGPoint(x:0, y: baseY), CGPoint(x:self.bounds.size.width, y: baseY)])
      context?.restoreGState()
    }
    //--------------------------
    trochoidCurve.stroke()
    if fillColor != nil {
      
    }
  }
}
