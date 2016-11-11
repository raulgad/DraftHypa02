//: Playground - noun: a place where people can play

import UIKit


class Test {
    var score: Int = 0
    var taskComplexity: Int = 0
 
    func change1() {
        score += 1
        taskComplexity += 1
    }
    
    func reset() {
        score = 0
        taskComplexity = 0
    }
 
}

var cl = Test()
cl.change1()
cl.change1()
cl.score
cl.reset()
cl.score
cl.change1()
cl.score