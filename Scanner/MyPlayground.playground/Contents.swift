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

addOptional(3, 8)
addOptional2(2, 0)


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


combinationFucntion(3, addOptional2)






