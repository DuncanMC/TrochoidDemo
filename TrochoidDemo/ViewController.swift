//
//  ViewController.swift
//  TrochoidDemo
//
//  Created by Duncan Champney on 1/17/17.
//  Copyright © 2017 Duncan Champney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  
  //MARK: - IBOutlets
  
  @IBOutlet var knobTapper: UITapGestureRecognizer!
  @IBOutlet weak var animateSwitch: UISwitch!
  @IBOutlet weak var rotationKnobView: UIImageView!
  @IBOutlet var rotationGestureRecognizer: OneFingerGestureRecognizer!
  @IBOutlet var doubleTapper: UITapGestureRecognizer!
  @IBOutlet var tripleTapper: UITapGestureRecognizer!
  @IBOutlet weak var controlsView: UIView!
  @IBOutlet weak var controlsViewConstraint: NSLayoutConstraint!
  @IBOutlet weak var radiusSlider: UISlider!
  @IBOutlet weak var radiusField: UITextField!
  
  @IBOutlet weak var lambdaSlider: UISlider!
  @IBOutlet weak var lambdaField: UITextField!
  
  @IBOutlet weak var speedSlider: UISlider!
  
  @IBOutlet weak var theTrochoidView: TrochoidView!
  
  
  //MARK: - Instance vars

  var rotationSpeed: Float = 0.5 {
    didSet {
      speedSlider.value = rotationSpeed
    }
  }
  var showKeyboardHandler: Any?
  var hideKeyboardHandler: Any?
  
  var keyboardHeight: CGFloat = 0
  var animationDuration: TimeInterval = 0
  
  var radiusValue: CGFloat = 0 {
    didSet {
      radiusSlider.value = Float(radiusValue)
      radiusField.text = String(format: "%.3f", radiusValue)
      theTrochoidView.radius = radiusValue
    }
  }
  
  var lambdaValue: CGFloat = 0
    {
    didSet {
      lambdaSlider.value = Float(lambdaValue)
      lambdaField.text = String(format: "%.3f", lambdaValue)
      theTrochoidView.lambda = lambdaValue
    }
  }
  private var timerInterval: TimeInterval = 0
  private var rotation: CGFloat = 0 {
    didSet {
      theTrochoidView.rotation = rotation
      rotationGestureRecognizer.rotation = rotation
      rotationKnobView.transform = CGAffineTransform(rotationAngle:0-rotation)
    }
  }

  private var timer: Timer?

  //MARK: - custom instance methods
  
  func startRotationTimer(_ start: Bool) {
    animateSwitch.setOn(start, animated: true)
    if !start {
      timer?.invalidate()
      //theTrochoidView.rotation = 0
    }
    else {
      timerInterval = Date().timeIntervalSinceReferenceDate
      timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) {
        timer in
        let elapsed = Float(Date().timeIntervalSinceReferenceDate - self.timerInterval)
        self.rotation += CGFloat(Float.pi * 2.0 -
          fmodf(self.rotationSpeed * elapsed * Float.pi * 2, Float.pi * 2.0))
        self.timerInterval = Date().timeIntervalSinceReferenceDate
      }
    }
  }
  
  func setupKeyboardNoticeHandlers() {
    hideKeyboardHandler = NotificationCenter.default.addObserver(
      forName: NSNotification.Name.UIKeyboardWillHide,
      object: nil,
      queue: nil) {
        notification in
        UIView.animate(withDuration: self.animationDuration) {
          self.controlsViewConstraint.constant -= self.keyboardHeight
          self.view.layoutIfNeeded()
        }
    }
    
    showKeyboardHandler = NotificationCenter.default.addObserver(
      forName: NSNotification.Name.UIKeyboardWillShow,
      object: nil,
      queue: nil) {
        notification in
        // Get information about the animation.
        guard let userInfo = notification.userInfo else {
          return
        }
        
        self.animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardViewBeginFrame = self.view.convert(keyboardScreenBeginFrame, from: self.view.window)
        let keyboardViewEndFrame = self.view.convert(keyboardScreenEndFrame,
                                                     from: self.view.window)
        
        // Determine how far the keyboard has moved up or down.
        self.keyboardHeight = keyboardViewBeginFrame.origin.y - keyboardViewEndFrame.origin.y
        UIView.animate(withDuration: self.animationDuration) {
          self.controlsViewConstraint.constant += self.keyboardHeight
          self.view.layoutIfNeeded()
        }
    }
  }

  //MARK: - overridden UIViewController methods

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if view.bounds.height > 375 {
      radiusSlider.maximumValue = 100
    }
    else {
      radiusSlider.maximumValue = 50
      if radiusValue > CGFloat(radiusSlider.maximumValue) {
        radiusValue = CGFloat(radiusSlider.maximumValue)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    rotationSpeed = 0.5
    setupKeyboardNoticeHandlers()
    doubleTapper.require(toFail: tripleTapper)
//    rotationGestureRecognizer = OneFingerGestureRecognizer(target: self,
//                                                           action: #selector(ViewController.handleRotationGesture(_:)))
//    rotationKnobView.addGestureRecognizer(rotationGestureRecognizer)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    radiusValue = theTrochoidView.radius
    lambdaValue = theTrochoidView.lambda
    startRotationTimer(true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  //MARK: - IBActions
  
  @IBAction func handleKnobTap(_ sender: UITapGestureRecognizer) {
    startRotationTimer(false)
    rotation = 0
  }
  
  @IBAction func handleRotationGesture(_ sender: OneFingerGestureRecognizer) {
    startRotationTimer(false)
    rotation = sender.rotation
  }
  @IBAction func handleAnimateSwitch(_ sender: UISwitch) {
    startRotationTimer(sender.isOn)
  }
  @IBAction func handleDrawDotsSwitch(_ sender: UISwitch) {
    theTrochoidView.drawDots = sender.isOn
  }

  @IBAction func handleRadiusSlider(_ sender: UISlider) {
    radiusValue = CGFloat(radiusSlider.value)
  }
  
  @IBAction func handleLambdaSlider(_ sender: UISlider) {
    lambdaValue = CGFloat(lambdaSlider.value)
  }

  @IBAction func handleSpeedSlider(_ sender: UISlider) {
    rotationSpeed = speedSlider.value
  }
  
  @IBAction func handleLambdaDoubleTap(_ sender: UITapGestureRecognizer) {
    lambdaValue = 1.0
  }
  
  @IBAction func handleLambdaTripleTap(_ sender: UITapGestureRecognizer) {
    lambdaValue = 0.5
  }
  
  override func viewWillTransition(to size: CGSize,
                                with: UIViewControllerTransitionCoordinator) {
    theTrochoidView.forceUpdate()
  }
}

//MARK: - ViewController UITextFieldDelegate extension

extension ViewController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    DispatchQueue.main.async {
      let allText = textField.textRange(
        from: textField.beginningOfDocument,
        to: textField.endOfDocument)
      
      textField.selectedTextRange = allText
    }
    return true
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    switch textField {
    case radiusField:
      if let string = radiusField.text,
        let value = Float(string),
        value >= radiusSlider.minimumValue && value <= radiusSlider.maximumValue {
        radiusValue = CGFloat(value)
      }
      else {
        radiusField.text = String(format: "%.3f", radiusValue)
      }
    case lambdaField:
      if let string = lambdaField.text,
        let value = Float(string),
        value >= lambdaSlider.minimumValue && value <= lambdaSlider.maximumValue {
        lambdaValue = CGFloat(value)
      }
      else {
        lambdaField.text = String(format: "%.3f", lambdaValue)
      }
    default:
      break
    }
    return true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }

}

//extension ViewController: UIGestureRecognizerDelegate {
//  
//  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//    return true
//  }
//}

