//
//  ViewController.swift
//  TrochoidDemo
//
//  Created by Duncan Champney on 1/17/17.
//  Copyright © 2017 Duncan Champney. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var radiusSlider: UISlider!
  @IBOutlet weak var radiusField: UITextField!
  
  @IBOutlet weak var lambdaSlider: UISlider!
  @IBOutlet weak var lambdaField: UITextField!
  
  @IBOutlet weak var theTrochoidView: TrochoidView!
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewWillAppear(_ animated: Bool) {
    radiusValue = theTrochoidView.radius
    lambdaValue = theTrochoidView.lambda
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func handleRadiusSlider(_ sender: UISlider) {
    radiusValue = CGFloat(radiusSlider.value)
  }
  
  @IBAction func handleLambdaSlider(_ sender: UISlider) {
    lambdaValue = CGFloat(lambdaSlider.value)
  }

}

extension ViewController {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    switch textField {
    case radiusField:
      if let string = radiusField.text,
        let value = Float(string) {
        if value >= radiusSlider.minimumValue && value <= radiusSlider.maximumValue {
          radiusValue = CGFloat(value)
        }
      }
      else {
        radiusField.text = String(format: "%.3f", radiusValue)
      }
    case lambdaField:
      if let string = lambdaField.text,
        let value = Float(string) {
        if value >= lambdaSlider.minimumValue && value <= lambdaSlider.maximumValue {
          lambdaValue = CGFloat(value)
        }
      }
      else {
        lambdaField.text = String(format: "%.3f", lambdaValue)
      }
    default:
      break
    }
    return true
  }

}

