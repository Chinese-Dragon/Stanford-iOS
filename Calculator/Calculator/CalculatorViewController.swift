//
//  ViewController.swift
//  Calculator
//
//  Created by Mark on 6/1/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController,UISplitViewControllerDelegate {

    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet weak var displayDescription: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping = false
    
    var savedProgram: CalculatorBrain.propertyList?
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping || digit == "." {
            let textCurrenllyInDisplay = display.text!
            display.text = textCurrenllyInDisplay + digit
        } else {
            display.text = digit
            
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction func saveProgram(_ sender: UIButton) {
        savedProgram = brain.program
    }
    @IBAction func loadProgram(_ sender: UIButton) {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result as AnyObject
        }
    }
    //computed property (eg.variable)
    fileprivate var displayValue: AnyObject {
        get{
            if let digit = Double(display.text!){
                return digit as AnyObject
            } else {
                return display.text! as AnyObject
            }
        }
        set {
            display.text = String(describing: newValue)
        }
    }
    
    
    fileprivate var descriptionValue: String {
        get {
            return displayDescription.text!
        }
        set {
            displayDescription.text = String(newValue)
        }
    
    }

    // Mark -- Model
    fileprivate var brain = CalculatorBrain()
   
    @IBAction func assignVariableValue(_ sender: UIButton) {
        savedProgram = brain.program
        if let newVariableValue = displayValue as? Double {
            brain.newVariableValue = newVariableValue
        }
        brain.program = savedProgram!
        displayValue = brain.result as AnyObject
        //reset
        savedProgram = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            splitViewController?.delegate = self
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
   
    //buttons to performOperation
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        //validate optional check if the associated value is null nor String
        //optional means that the assocaited value can be null (e.g not set)
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result as AnyObject
        
        if brain.isPartialResult {
            descriptionValue = brain.openDescription+"..."
            
        } else if sender.currentTitle != "C" {
            descriptionValue = brain.openDescription+"="
            
        } else {
            descriptionValue = " "
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "graph":
                    if let destinationVc = segue.destination as? UINavigationController,
                        let graphVc = destinationVc.visibleViewController as? GraphViewController{
                        graphVc.graphProramData = brain.program as! [AnyObject]
                }
                default:
                    break
            }
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
            case "graph": if brain.isPartialResult { return false }
            default: break
        }
        return true
    }
}

