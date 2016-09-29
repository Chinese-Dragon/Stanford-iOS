//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Mark on 6/2/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation //core service layer which has nothing to do with UI

//DS of enum,IT IS A ENUM with associated value of any given type(can even be an function)
//type of functions is just like (Double) -> Double, which means that A fuction that takes a double
//and return a double, and function can be stored in to local variable that has a function type
//enum Optional<T> {
//    case None
//    case Some(T)
//}

//Building API
class CalculatorBrain {
    
    fileprivate var accumulator = 0.0
    fileprivate var description = ""
    fileprivate var withUniary = false
    fileprivate var withConstant = false
    fileprivate var withVariable = false
    fileprivate var equalBefore = false
    fileprivate var lastResult = 0.0
    fileprivate var internalProgram = [AnyObject]()
    fileprivate var currentVariableValue = 0.0 //default value

    
    var newVariableValue: Double = 0.0 {
        willSet {
            operations["M"] = Operation.variable(newValue)
        }
    }
    
    var openDescription:String {
        get{
            return description
        }
    }
    var isPartialResult = false
    
    func setOperand(_ operand: AnyObject) {
        if let operand = operand as? Double {
            accumulator = operand
            internalProgram.append(operand as AnyObject)
        } else if let variable = operand as? String, let _ = operations[variable]{
            performOperation(variable)
    
        }
    }
    

    
    //store value is enume that can have an associated value of any type
    fileprivate var operations: Dictionary<String,Operation> = [
        "π": Operation.constant(M_PI), //M_PI
        "e": Operation.constant(M_E), //M_E
        "M": Operation.variable(0.0),
        "√": Operation.unaryOperation(sqrt), //sqrt
        "cos": Operation.unaryOperation(cos), //cos
        "sin": Operation.unaryOperation(sin),
        "+/−": Operation.unaryOperation(){-$0},
        "%": Operation.unaryOperation(){$0 / 100},
        "×": Operation.binaryOperation(){$0 * $1},
        "÷": Operation.binaryOperation(){$0 / $1},
        "+": Operation.binaryOperation(){$0 + $1},
        "−": Operation.binaryOperation(){$0 - $1},
        "=": Operation.equals,
        "C": Operation.cleans
    ]
    
    //why we use enum is because we cannot use function in operations but constant
    //pass by value data structure
    //** All type should capatalized, eg. class, protocal, struct, enum
    fileprivate enum Operation {
        case constant(Double)
        case variable(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case cleans
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        //the dictionary may not have the key
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                if equalBefore {
                    cleanDescription()
                    description.append(symbol)
                    equalBefore = false
                } else {
                    description.append(symbol)
                }
                accumulator = value
                withConstant = true
                
            case .variable(let variableValue):
                if equalBefore {
                    cleanDescription()
                    description.append(symbol)
                    equalBefore = false
                } else {
                    description.append(symbol)
                }
                accumulator = variableValue
                withVariable = true
        
                
            case .unaryOperation(let function):
                
                if !isPartialResult{
                    if description == " "{
                        description = symbol + String(accumulator)
                    }else {
                        description = symbol + description
                    }
                } else {
                    
                    withUniary = true
                    description = description+symbol+String(accumulator)
                    
                }
                
                accumulator = function(accumulator)
                
            case .binaryOperation(let function):
                
                if pending != nil {
                    if withUniary{
                        description.append(symbol)
                        withUniary = false
                    } else if withConstant{
                        description.append(symbol)
                        withConstant = false
                    } else if withVariable {
                        description.append(symbol)
                        withVariable = false
                    } else {
                        description.append(String(accumulator)+symbol)
                    }
                    accumulator = pending!.binaryFunction(pending!.firstOperand,accumulator)
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                    
                } else {
                    if checkEqualOfLastResultAndCurrentDisplay(lastResult, currentDisplay: accumulator){
                        if equalBefore{
                            description.append(symbol)
                            equalBefore = false
                        } else {
                            description.append(String(accumulator)+symbol)
                        }
                    } else{
                        resetEverythingAboutDescription()
                        description.append(String(accumulator)+symbol)
                    }
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                }
                isPartialResult = true
                
            case .equals:
                
                equalBefore = true
                if pending != nil {
                    if !withUniary && !withConstant && !withVariable{
                        description.append(String(accumulator))
                    } else{
                        withConstant = false
                        withUniary = false
                        withVariable = false
                    }
                    accumulator = pending!.binaryFunction(pending!.firstOperand,accumulator)
                    pending = nil
                    isPartialResult = false
                }
            case .cleans:
                cleanAll()
                newVariableValue = 0.0
            }
        }
        
    }
    
    // it is optional because it is initilized when there is a Pending Operation
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double //type of local variable is a function
        var firstOperand: Double
    }
    
    typealias propertyList = AnyObject
    var program: propertyList {
        get {
            return internalProgram as CalculatorBrain.propertyList
        }
        set {
            cleanAll()
            if let arrayOfOp = newValue as? [AnyObject] {
                print(arrayOfOp.count)
                for op in arrayOfOp {
                    print(op)
                    if let operand = op as? Double {
                        setOperand(operand as AnyObject)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
        
    }
    
    var result: Double {
        //read only property
        get {
            lastResult = accumulator
            return accumulator
        }
    }
    
    fileprivate func cleanDescription(){
        description = " "
    }
    
    fileprivate func checkEqualOfLastResultAndCurrentDisplay(_ lastResult: Double, currentDisplay: Double) -> Bool{
        var check = false
        if lastResult == currentDisplay {
            check = true
        }
        return check
    }
    
    fileprivate func resetEverythingAboutDescription(){
        description = " "
        withUniary = false
        withConstant = false
        withVariable = false
        equalBefore = false
    }
    
    fileprivate func cleanAll(){
        isPartialResult = false
        pending = nil
        accumulator = 0.0
        internalProgram.removeAll()
        resetEverythingAboutDescription()
    }
}
