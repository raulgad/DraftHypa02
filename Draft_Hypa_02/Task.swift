//
//  Task.swift
//  Draft_Hypa_02
//
//  Created by mac on 20.10.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation

struct Task {
    static let plusMinusOperations: [(Int,Int)->Int] = [(+),(-)]
    static var stepsToNextComplexity: Int = 5
    static var minValueForRandom: Int = 1
    static var maxValueForRandom: Int = 10
    //FIXME: Try to use 'let' instead 'var' in 'question', 'answerOne', 'answerTwo'
    var question: String = "No question"
    var answerOne: String = "No first answer"
    var answerTwo: String = "No second answer"
    
    private var correctAnswer: Int = 0
    
    init(score: Int) {
        if score > Task.stepsToNextComplexity {
            //Increase level of complexity
            Task.stepsToNextComplexity = Task.stepsToNextComplexity + (Task.stepsToNextComplexity + 2)
            Task.minValueForRandom = Task.maxValueForRandom
            Task.maxValueForRandom *= 10
        } else {
            //Set variables to default values
            Task.stepsToNextComplexity = 5
            Task.minValueForRandom = 1
            Task.maxValueForRandom = 10
        }
//        print("\(Task.stepsToNextComplexity) : Task.stepsToNextComplexity")
        print("\(score) : score in Task.init()")
//        print("\(Task.minValueForRandom) : Task.minValueForRandom")
//        print("\(Task.maxValueForRandom) : Task.maxValueForRandom")
        switch CardsViewController.taskOperation {
        case .Plus:
            plus()
        case .Minus:
            minus()
        case .Multiply:
            multiply()
        case .Divide:
            divide()
        }
    }
    
    private func getWrongResult(summand1: Int, summand2: Int, result: Int) -> Int {
        //wrongResult == result + or - (random number between one and minValue)
        let randomNumberBetweenOneAndMinValue = Int(arc4random_uniform(UInt32(Task.minValueForRandom))) + 1
        
//        print("\(Task.minValueForRandom) : Task.minValueForRandom")
//        print("\(randomNumberBetweenOneAndMinValue) : randomNumberBetweenOneAndMinValue")
//        
        let wrongResult = abs(Task.plusMinusOperations.randomElement(result,randomNumberBetweenOneAndMinValue))
        return wrongResult
    }
    
    mutating private func setValuesToProperties(result: Int, wrongResult: Int) {
        //Randomly set result and wrongResult to answers
        let randomIndex = [0,1].randomElement
        answerOne = String([result, wrongResult][randomIndex])
        answerTwo = String([result, wrongResult][abs(randomIndex-1)])
        //Set values to 'correctAnswer' and 'question'
        correctAnswer = result
    }
    
    //Why we use 'mutating' if we already set 'mutating' in the setValuesToProperties()?
    mutating func plus() {
        //Plus operation
        let summand1 = Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
        let summand2 = Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
        let result = summand1 + summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) + \(summand2)"
        
//        print("\(answerOne) : answerOne")
//        print("\(answerTwo) : answerTwo")
//        print("\(wrongResult) : wrongResult")
//        print("\(result) : result")
//        print("\(summand1) : summand1")
//        print("\(summand2) : summand2")
//        print("\(summand1 + summand2) : summand1 + summand2")
    }
    
    mutating func minus() {
        //Minus operation
        let summand1 = Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
        let summand2 = Int(arc4random_uniform(UInt32((summand1 - Task.minValueForRandom)))) + Task.minValueForRandom
        let result = summand1 - summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) - \(summand2)"

//        print("\(answerOne) : answerOne")
//        print("\(answerTwo) : answerTwo")
//        print("\(wrongResult) : wrongResult")
//        print("\(result) : result")
//        print("\(summand1) : summand1")
//        print("\(summand2) : summand2")
//        print("\(summand1 - summand2) : summand1 - summand2")
    }
    
    mutating func multiply() {
        //Multiply operation
        let summand1 = Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
        let summand2 = Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
        let result = summand1 * summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) x \(summand2)"
        
//        print("\(answerOne) : answerOne")
//        print("\(answerTwo) : answerTwo")
//        print("\(wrongResult) : wrongResult")
//        print("\(result) : result")
//        print("\(summand1) : summand1")
//        print("\(summand2) : summand2")
//        print("\(summand1 * summand2) : summand1 * summand2")
    }
    
    mutating func divide() {
        //Divide operation. Set summands so that the result always be an integral
        let result = Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
        let summand2 = Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
        let summand1 = result * summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) ÷ \(summand2)"
        
//        print("\(answerOne) : answerOne")
//        print("\(answerTwo) : answerTwo")
//        print("\(wrongResult) : wrongResult")
//        print("\(result) : result")
//        print("\(summand1) : summand1")
//        print("\(summand2) : summand2")
//        print("\(summand1 / summand2) : summand1 / summand2")
    }
    
    
    func getLabel(to card: Card) -> String {
        switch card.item {
        case .Question:
            return question
        case .AnswerOne:
            return answerOne
        case .AnswerTwo:
            return answerTwo
        default:
            return "\(card.item) : 'card.item' property has incorrect value"
        }
    }
}

//FIXME: What you will do if number of answers will be changed dynamically? And is it enum is necessary?
enum Item {
    case Question, AnswerOne, AnswerTwo, Unknown
}

extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}
