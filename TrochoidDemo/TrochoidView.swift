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
  
  @IBInspectable var drawDots: Bool = true  {
    didSet {
      forceUpdate()
    }
  }

  public var rotation: CGFloat = 0 {
    didSet {
      forceUpdate()
    }
  }
  
  @IBInspectable public var radius: CGFloat = 40 {
    didSet {
      if radius != oldValue {
        forceUpdate()
      }
    }
  }
  @IBInspectable public var lambda: CGFloat = 0.5 {
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
 
  private var baseY: CGFloat = 0
  
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
    lineLength = radius * lambda

    let maxCircle = max(radius, lineLength)
    baseY = bounds.height / 4
    
    if maxCircle * 8 > bounds.height {
      baseY = maxCircle * 1.5
      
    }
    
    //--------------------------
    let context = UIGraphicsGetCurrentContext()

    func scaleForYDistance(_ yDistance: CGFloat, radius: CGFloat) -> CGFloat {
      var scale =  -2.25*yDistance/(radius*CGFloat.pi*2) + 1.0
      if scale < 0 {
        scale = 0
      }
      return scale
    }

    func drawDotWithCenter(_ circleCenter: CGPoint,
                           radiusScale: CGFloat = 1.0,
                           specialDot: Bool) {
      
      var dotCenter = circleCenter
      var angle_offset: CGFloat
      angle_offset = CGFloat(fmodf(Float(Float(circleCenter.x/radius)), Float.pi * 2))

      dotCenter.x += cos(CGFloat.pi * 2 - rotation - angle_offset - CGFloat.pi / 3.06*lambda) * lineLength * radiusScale
      dotCenter.y += sin(CGFloat.pi * 2 - rotation - angle_offset - CGFloat.pi / 3.06*lambda) * lineLength * radiusScale
      var rect = CGRect(origin: dotCenter, size: CGSize(width: 0, height: 0))
      let darkBlue:[CGFloat] = [53/255.0, 87/255.0, 147/255.0, 1]
      if specialDot {
        rect = rect.insetBy(dx: -3, dy: -3)

        let yellow:[CGFloat] = [1, 1, 0, 1]
        context?.setFillColor(yellow);
        context?.setStrokeColor(darkBlue);

        context?.setLineWidth(1.0)

        context?.fillEllipse(in: rect)
        context?.strokeEllipse(in: rect)
        
      }
      else {
        rect = rect.insetBy(dx: -3, dy: -3)

        let darkBlue:[CGFloat] = [53/255.0, 87/255.0, 147/255.0, 1]
        context?.setFillColor(darkBlue);
        context?.fillEllipse(in: rect)
      }

    }
    if drawDots && false{
      //Draw the origin line
      UIColor.blue.set()
      let blue:[CGFloat] = [0, 0, 1, 1]
      context?.setStrokeColor(blue);
      context?.setLineWidth(1.0)
      context?.strokeLineSegments(between: [CGPoint(x:0, y: baseY), CGPoint(x:self.bounds.size.width, y: baseY)])
      
    }
    //--------------------------
    trochoidCurve.stroke()
    if let fillColor = fillColor {
      fillColor.set()
      trochoidCurve.fill()
    }
    if drawDots {

      var circleCenter = CGPoint(x: bounds.width / 2, y: baseY)
      
      
      let strideValue:CGFloat = 20
      let steps = bounds.width/strideValue

      circleCenter.x = strideValue * round(steps / 2)
      
      let centerX = circleCenter.x
      var magicCenters:[CGPoint] = [circleCenter]
      
      for (index,y) in stride(from: baseY, to: bounds.height, by: strideValue).enumerated() {
        circleCenter.y = y
        var radiusScale:CGFloat = 1
        
        //Reduce the radius by 1/2 at 1/9 the wavelength, and reduce the radius to 0 by 2/9
        radiusScale = scaleForYDistance(y-baseY, radius: radius)
        if radiusScale < 0 {
          radiusScale = 0
        } 
        for x in stride(from: -strideValue, to: bounds.width+strideValue, by: strideValue) {
          circleCenter.x = x
          if circleCenter.x == centerX && index == 3 {
            magicCenters.append(circleCenter)
          } else  {
            drawDotWithCenter(circleCenter,
                              radiusScale: radiusScale,
                              specialDot: false)
          }
        }
      }
      for aPoint in magicCenters {
        //Draw the orange circle.
        context?.setLineWidth(2.0)
        var rect = CGRect(origin: aPoint, size: CGSize(width: 0, height: 0))
        let radiusScale = scaleForYDistance(aPoint.y-baseY, radius: radius)

        rect = rect.insetBy(dx: -lineLength*radiusScale, dy: -lineLength*radiusScale)
        let orange:[CGFloat] = [1, 0.5, 0, 1.0]
        context?.setStrokeColor(orange)
        context?.strokeEllipse(in: rect)
        drawDotWithCenter(aPoint,
                          radiusScale: radiusScale,
                          specialDot: true)

      }
    }
  }
}
