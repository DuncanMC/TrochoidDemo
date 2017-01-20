//
//  OneFingerGestureRecognizer.swift
//  TrochoidDemo
//
//  Created by Duncan Champney on 1/20/17.
//  Copyright © 2017 Duncan Champney. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

 open class OneFingerGestureRecognizer: UIGestureRecognizer {
  
  @IBInspectable public var rotation: CGFloat = 0
  
  override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
  }

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
    
    guard let touch = touches.first,
     view != nil else {
      return
    }
    let center = CGPoint(x: view!.bounds.midX, y: view!.bounds.midY)
    let currentTouchPoint = touch.location(in:  view)
    let previousTouchPoint = touch.previousLocation(in:  view)
    rotation -= CGFloat(
      atan2f(Float(currentTouchPoint.y - center.y),
             Float(currentTouchPoint.x - center.x)) -
        atan2f(Float(previousTouchPoint.y - center.y),
               Float(previousTouchPoint.x - center.x))
    )
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
