//
//  OneFingerGestureRecognizer.swift
//  TrochoidDemo
//
//  Created by Duncan Champney on 1/20/17.
//  Copyright © 2017 Duncan Champney. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass


/**
 This class is a custom gesture recognizer that provides a one finger version of UIRotationGestureRecognizer.
 
 It's a continuous gesture recognizer that has a single property, rotation. It's intended to be attached to a UIImageView that has userInteractionsEnabled set to true.
 
 If the user presses on a view this gesture recognizer is attached to and rotates their finger around the center of the view, the gesture recognizer adjusts its rotation property based on the change in angle  of the user's "spin" gesture.
 */

 open class OneFingerGestureRecognizer: UIGestureRecognizer {
  
  @IBInspectable public var rotation: CGFloat = 0
  
  
  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    
    if event.touches(for: self)?.count ?? 0 > 1 {
      state = .failed
    }
  }
  
    
  override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    if state == .possible {
      state = .began
    }
    else {
      state = .changed
    }
    //If there are no touch events or we're not attached to a view then exit.
    guard let touch = touches.first,
     view != nil else {
      state = .failed
      return
    }
    

    let center = CGPoint(x: view!.bounds.midX, y: view!.bounds.midY)
    let currentTouchPoint = touch.location(in:  view)
    let previousTouchPoint = touch.previousLocation(in:  view)
    
    //Calculate the angle from the center of the view to the previous touch point.
    let previousAngle = atan2f(Float(previousTouchPoint.y - center.y),
                               Float(previousTouchPoint.x - center.x))
    //Calculate the angle from the center of the view to the current touch point.
    let currentAngle = atan2f(Float(currentTouchPoint.y - center.y),
                              Float(currentTouchPoint.x - center.x))
    
    //Adjust the rotation by the change in angle.
    rotation -= CGFloat(currentAngle - previousAngle)
  }
  
  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if state == .changed {
      state = .ended
    }
    else {
      state = .failed
    }
  }
  
  override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    state = .ended
  }
  
}
