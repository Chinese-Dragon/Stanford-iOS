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
    
    private var accumulator = 0.0
    private var description = ""
    private var withUniary = false
    private var withConstant = false
    private var withVariable = false
    private var equalBefore = false
    private var lastResult = 0.0
    private var internalProgram = [AnyObject]()
    private var currentVariableValue = 0.0 //default value

    
    var newVariableValue: Double = 0.0 {
        willSet {
            operations["M"] = Operation.Variable(newValue)
        }
    }
    
    var openDescription:String {
        get{
            return description
        }
    }
    var isPartialResult = false
    
    func setOperand(operand: AnyObject) {
        if let operand = operand as? Double {
            accumulator = operand
            internalProgram.append(operand)
        } else if let variable = operand as? String, _ = operations[variable]{
            performOperation(variable)
    
        }
    }
    

    
    //store value is enume that can have an associated value of any type
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI), //M_PI
        "e": Operation.Constant(M_E), //M_E
        "M": Operation.Variable(0.0),
        "√": Operation.UnaryOperation(sqrt), //sqrt
        "cos": Operation.UnaryOperation(cos), //cos
        "sin": Operation.UnaryOperation(sin),
        "+/−": Operation.UnaryOperation(){-$0},
        "%": Operation.UnaryOperation(){$0 / 100},
        "×": Operation.BinaryOperation(){$0 * $1},
        "÷": Operation.BinaryOperation(){$0 / $1},
        "+": Operation.BinaryOperation(){$0 + $1},
        "−": Operation.BinaryOperation(){$0 - $1},
        "=": Operation.Equals,
        "C": Operation.Cleans
    ]
    
    //why we use enum is because we cannot use function in operations but constant
    //pass by value data structure
    //** All type should capatalized, eg. class, protocal, struct, enum
    private enum Operation {
        case Constant(Double)
        case Variable(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
        case Cleans
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        //the dictionary may not have the key
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                if equalBefore {
                    cleanDescription()
                    description.appendContentsOf(symbol)
                    equalBefore = false
                } else {
                    description.appendContentsOf(symbol)
                }
                accumulator = value
                withConstant = true
                
            case .Variable(let variableValue):
                if equalBefore {
                    cleanDescription()
                    description.appendContentsOf(symbol)
                    equalBefore = false
                } else {
                    description.appendContentsOf(symbol)
                }
                accumulator = variableValue
                withVariable = true
        
                
            case .UnaryOperation(let function):
                
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
                
            case .BinaryOperation(let function):
                
                if pending != nil {
                    if withUniary{
                        description.appendContentsOf(symbol)
                        withUniary = false
                    } else if withConstant{
                        description.appendContentsOf(symbol)
                        withConstant = false
                    } else if withVariable {
                        description.appendContentsOf(symbol)
                        withVariable = false
                    } else {
                        description.appendContentsOf(String(accumulator)+symbol)
                    }
                    accumulator = pending!.binaryFunction(pending!.firstOperand,accumulator)
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                    
                } else {
                    if checkEqualOfLastResultAndCurrentDisplay(lastResult, currentDisplay: accumulator){
                        if equalBefore{
                            description.appendContentsOf(symbol)
                            equalBefore = false
                        } else {
                            description.appendContentsOf(String(accumulator)+symbol)
                        }
                    } else{
                        resetEverythingAboutDescription()
                        description.appendContentsOf(String(accumulator)+symbol)
                    }
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                }
                isPartialResult = true
                
            case .Equals:
                
                equalBefore = true
                if pending != nil {
                    if !withUniary && !withConstant && !withVariable{
                        description.appendContentsOf(String(accumulator))
                    } else{
                        withConstant = false
                        withUniary = false
                        withVariable = false
                    }
                    accumulator = pending!.binaryFunction(pending!.firstOperand,accumulator)
                    pending = nil
                    isPartialResult = false
                }
            case .Cleans:
                cleanAll()
                newVariableValue = 0.0
            }
        }
        
    }
    
    // it is optional because it is initilized when there is a Pending Operation
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double //type of local variable is a function
        var firstOperand: Double
    }
    
    typealias propertyList = AnyObject
    var program: propertyList {
        get {
            return internalProgram
        }
        set {
            cleanAll()
            if let arrayOfOp = newValue as? [AnyObject] {
                print(arrayOfOp.count)
                for op in arrayOfOp {
                    print(op)
                    if let operand = op as? Double {
                        setOperand(operand)
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
    
    private func cleanDescription(){
        description = " "
    }
    
    private func checkEqualOfLastResultAndCurrentDisplay(lastResult: Double, currentDisplay: Double) -> Bool{
        var check = false
        if lastResult == currentDisplay {
            check = true
        }
        return check
    }
    
    private func resetEverythingAboutDescription(){
        description = " "
        withUniary = false
        withConstant = false
        withVariable = false
        equalBefore = false
    }
    
    private func cleanAll(){
        isPartialResult = false
        pending = nil
        accumulator = 0.0
        internalProgram.removeAll()
        resetEverythingAboutDescription()
    }
}