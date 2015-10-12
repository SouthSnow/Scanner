//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

func addOptional(OptionalX: Int?, OptionalY: Int?)->Int?
{
    
    if let x = OptionalX
    {
        if let y = OptionalY
        {
            return x + y
        }
    }
    
    return nil
}


func addOptional2(OptionalX: Int?, OptionalY: Int?)->Int?
{
    if let x = OptionalX, y = OptionalY
    {
        return x + y
    }
    
    return nil
    
}

addOptional(3, OptionalY: 8)
addOptional2(2, OptionalY: 0)


func incrementOptional(x: Int?) -> Int?
{
    return x.map{x in x + x}
}


incrementOptional(3)


func combinationFucntion(x: Int?,f:(Int?, Int?)->Int?)->Int?
{
    if let x1 = x, f1 = f(x,x)
    {
        return x1 + f1
        
    }
    return nil
    
}


combinationFucntion(3, f: addOptional2)


let aString: String = "helloSwift"
let end = aString.endIndex
let start = aString.startIndex
let successor = start.successor()
let predecessor = successor.predecessor()
let next = successor.successor()
let subString = aString.substringToIndex(start.advancedBy(6))
let subString2 = aString.substringFromIndex(start.advancedBy(7))
let sunString3 = aString.substringWithRange(Range(start: start.advancedBy(2