//
//  ViewController.swift
//  Calculator
//
//  Created by Mark on 6/1/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController,UISplitViewControllerDelegate {

    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var displayDescription: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    var savedProgram: CalculatorBrain.propertyList?
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping || digit == "." {
            let textCurrenllyInDisplay = display.text!
            display.text = textCurrenllyInDisplay + digit
        } else {
            display.text = digit
            
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction func saveProgram(sender: UIButton) {
        savedProgram = brain.program
    }
    @IBAction func loadProgram(sender: UIButton) {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    //computed property (eg.variable)
    private var displayValue: AnyObject {
        get{
            if let digit = Double(display.text!){
                return digit
            } else {
                return display.text!
            }
        }
        set {
            display.text = String(newValue)
        }
    }
    
    
    private var descriptionValue: String {
        get {
            return displayDescription.text!
        }
        set {
            displayDescription.text = String(newValue)
        }
    
    }

    // Mark -- Model
    private var brain = CalculatorBrain()
   
    @IBAction func assignVariableValue(sender: UIButton) {
        savedProgram = brain.program
        if let newVariableValue = displayValue as? Double {
            brain.newVariableValue = newVariableValue
        }
        brain.program = savedProgram!
        displayValue = brain.result
        //reset
        savedProgram = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone) {
            splitViewController?.delegate = self
        }
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
   
    //buttons to performOperation
    @IBAction private func performOperation(sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        //validate optional check if the associated value is null nor String
        //optional means that the assocaited value can be null (e.g not set)
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        
        if brain.isPartialResult {
            descriptionValue = brain.openDescription+"..."
            
        } else if sender.currentTitle != "C" {
            descriptionValue = brain.openDescription+"="
            
        } else {
            descriptionValue = " "
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "graph":
                    if let destinationVc = segue.destinationViewController as? UINavigationController,
                        let graphVc = destinationVc.visibleViewController as? GraphViewController{
                        graphVc.graphProramData = brain.program as! [AnyObject]
                }
                default:
                    break
            }
        }
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
            case "graph": if brain.isPartialResult { return false }
            default: break
        }
        return true
    }
}

