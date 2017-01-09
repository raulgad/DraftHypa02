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
    private(set) static var complexity: Int = 0
    private static var numberOfStepsToChangeComplexity: Int = 5
    private static var minForRandom: Int = 1
    private static var maxForRandom: Int = 10
    //FIXME: Not sure if it good idea store task's operation by not private class variable
    static var taskOperation: Operation = .Addition
    var question = "No question"
    var answerOne = "No first answer"
    var answerTwo = "No second answer"
    private var summand1: Int!
    private var summand2: Int!
    private var correctAnswer = Card.Item.Unknown
    
    init() {
        if Task.complexity > Task.numberOfStepsToChangeComplexity {
            //Increase level of complexity
            Task.numberOfStepsToChangeComplexity += 5
            Task.minForRandom = Task.maxForRandom
            Task.maxForRandom *= 2
        //Reset to default range of random values
        } else if Task.complexity < 2 {
            Task.numberOfStepsToChangeComplexity = 5
            Task.minForRandom = 1
            Task.maxForRandom = 10
        }
        
        summand1 = getRandomFromMinToMax()
        summand2 = getRandomFromMinToMax()
        
        switch Task.taskOperation {
        case .Addition:
            add()
        case .Subtraction:
            subtract()
        case .Multiplication:
            multiply()
        case .Division:
            divide()
        }
        
        Task.complexity += 1
    }
    
    //FIXME: Bad idea to give global access for reset complexity.
    static func resetComplexity() {
        Task.complexity = 0
    }
    //FIXME: Bad idea to give global access for reset complexity.
    static func holdComplexity() {
        Task.complexity -= 1
    }
    
    private func getWrongResult(summand1: Int, summand2: Int, result: Int) -> Int {
        let randomFromOneToHalfResult = Int(arc4random_uniform(UInt32(result / 2))) + 1
        let wrongResult = Task.plusMinusOperations.randomElement(result,randomFromOneToHalfResult)
        return wrongResult
    }
    
    mutating private func setToProperties(result: Int, wrongResult: Int) {
        //Randomly set result and wrongResult to answers
        answerOne = String([result, wrongResult].randomElement)
        answerTwo = answerOne == String(result) ? String(wrongResult) : String(result)
        
        //Set values to 'correctAnswer'
        correctAnswer = (answerOne == String(result)) ? Card.Item.AnswerOne : Card.Item.AnswerTwo
    }
    
    func getRandomFromMinToMax() -> Int {
        return Int(arc4random_uniform(UInt32((Task.maxForRandom - Task.minForRandom)))) + Task.minForRandom
    }
    
    //Why we use 'mutating' if we already set 'mutating' in the setValuesToProperties()?
    private mutating func add() {
        //Plus operation
        let result = summand1 + summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1!) + \(summand2!)"
    }
    
    private mutating func subtract() {
        //Minus operation
        //Set 'summand2' a random from minValueForRandom to 'summand1'
        summand2 = Int(arc4random_uniform(UInt32((summand1 - Task.minForRandom)))) + Task.minForRandom
        
        let result = summand1 - summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1!) - \(summand2!)"
    }
    
    private mutating func multiply() {
        //Multiply operation
        let result = summand1 * summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1!) x \(summand2!)"
    }
    
    private mutating func divide() {
        //Divide operation
        //Set 'summand2' a random from 1 to 'summand1' for the first 5 questions and random from 1 to minValueForRandom for follow-up questions
        summand2 = Int(arc4random_uniform(UInt32((Task.minForRandom == 1 ? summand1 : Task.minForRandom)))) + 1
        
        //Remove modulo from first summand
        if (summand1 % summand2) != 0 {summand1! -= (summand1 % summand2)}

        let result = summand1 / summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1!) ÷ \(summand2!)"
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
    
    func checkAnswer(touchedCard: Card.Item) -> Bool {
        return touchedCard == correctAnswer
    }
}

enum Operation {
    case Addition, Subtraction, Multiplication, Division
}

extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}
