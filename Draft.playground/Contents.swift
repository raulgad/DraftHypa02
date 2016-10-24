//: Playground - noun: a place where people can play

import UIKit

struct Test {
    var str: String!

    init () {
        return
    }

    mutating func setString(newString: String!) {
        self.str = newString
    }
}

Test.str

//var cards = [Test]()
//
//for _ in 0...2 {
//    cards.append(Test())
//}
//
////for card in cards {
////    card.setString(newString: "working")
////}
//for index in 0..<cards.count {
//    cards[index].setString(newString: "working")
//}
//
//cards[0].str
