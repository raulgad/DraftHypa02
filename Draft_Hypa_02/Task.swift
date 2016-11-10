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
    var question = "No question"
    var answerOne = "No first answer"
    var answerTwo = "No second answer"
    
    private var correctAnswer = Card.Item.Unknown
    
    init(complexity: Int) {
        if complexity > Task.stepsToNextComplexity {
            //Increase level of complexity
            Task.stepsToNextComplexity += 5
            Task.minValueForRandom = Task.maxValueForRandom
            Task.maxValueForRandom *= 2
        }
        
        switch CardsViewController.taskOperation {
        case .Addition:
            add()
        case .Subtraction:
            subtract()
        case .Multiplication:
            multiply()
        case .Division:
            divide()
        }
    }
    
    private func getWrongResult(summand1: Int, summand2: Int, result: Int) -> Int {
        let randomFromOneToHalfResult = Int(arc4random_uniform(UInt32(result / 2))) + 1
        let wrongResult = Task.plusMinusOperations.randomElement(result,randomFromOneToHalfResult)
        return wrongResult
    }
    
    mutating private func setValuesToProperties(result: Int, wrongResult: Int) {
        //FIXME: Ugly implementation
        //Randomly set result and wrongResult to answers
        let randomIndex = [0,1].randomElement
        answerOne = String([result, wrongResult][randomIndex])
        answerTwo = String([result, wrongResult][abs(randomIndex-1)])
        
        //Set values to 'correctAnswer'
        correctAnswer = (answerOne == String(result)) ? Card.Item.AnswerOne : Card.Item.AnswerTwo
    }
    
    func getRandomFromMinToMaxValues() -> Int {
        return Int(arc4random_uniform(UInt32((Task.maxValueForRandom - Task.minValueForRandom)))) + Task.minValueForRandom
    }
    
    //Why we use 'mutating' if we already set 'mutating' in the setValuesToProperties()?
    private mutating func add() {
        //Plus operation
        let summand1 = getRandomFromMinToMaxValues()
        let summand2 = getRandomFromMinToMaxValues()
        let result = summand1 + summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) + \(summand2)"
    }
    
    private mutating func subtract() {
        //Minus operation
        let summand1 = getRandomFromMinToMaxValues()
        
        //Set 'summand2' a random from minValueForRandom to 'summand1'
        let summand2 = Int(arc4random_uniform(UInt32((summand1 - Task.minValueForRandom)))) + Task.minValueForRandom
        
        let result = summand1 - summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) - \(summand2)"
    }
    
    private mutating func multiply() {
        //Multiply operation
        let summand1 = getRandomFromMinToMaxValues()
        let summand2 = getRandomFromMinToMaxValues()
        let result = summand1 * summand2
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) x \(summand2)"
    }
    
    private mutating func divide() {
        //Divide operation
        var summand1 = getRandomFromMinToMaxValues()

        //Set 'summand2' a random from 1 to 'summand1' for the first 5 questions and random from 1 to minValueForRandom for follow-up questions
        let summand2 = Int(arc4random_uniform(UInt32((Task.minValueForRandom == 1 ? summand1 : Task.minValueForRandom)))) + 1
        
        //Remove modulo from first summand
        if (summand1 % summand2) != 0 {summand1 -= (summand1 % summand2)}
        let result = summand1 / summand2
        
        let wrongResult = getWrongResult(summand1: summand1, summand2: summand2, result: result)
        setValuesToProperties(result: result, wrongResult: wrongResult)
        question = "\(summand1) ÷ \(summand2)"
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

extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}
