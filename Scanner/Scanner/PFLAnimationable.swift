//
//  PFLAnimationable.swift
//  JiuDingPay
//
//  Created by dongbailan on 16/3/29.
//  Copyright © 2016年 JIUDING Electronic Pay. All rights reserved.
//

import UIKit
import Foundation

protocol Animationable {
     func performAnimation()
     func performRotationAnimation()
     func dismissAnimation()
     func addBehavior() -> UIGravityBehavior
     func addDropBehavior() -> UIGravityBehavior
}

extension Animationable where Self: UIView {
    
    func performRotationAnimation() {
        let baseAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        baseAnimation.fromValue = NSNumber(value: 0 as Double)
        baseAnimation.fromValue = NSNumber(value: M_PI * 2 as Double)
        baseAnimation.duration = 0.03
        baseAnimation.repeatCount = 10
        self.layer.add(baseAnimation, forKey: nil)
    }
    
    func dismissAnimation() {
        let dismissAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        dismissAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0))
        dismissAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(0.0, 0.0, 1.0))
        dismissAnimation.isRemovedOnCompletion = false
        
        let opacityAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = NSNumber(value: 1.0 as Float)
        opacityAnimation.toValue = NSNumber(value: 0 as Float)
        opacityAnimation.isRemovedOnCompletion = false
        
        let groupAnimation: CAAnimationGroup = CAAnimationGroup()
        groupAnimation.duration = 0.3
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.animations = [dismissAnimation, opacityAnimation]
        groupAnimation.fillMode = kCAFillModeForwards
        self.layer.add(groupAnimation, forKey: nil)
        
    }
    
    func performAnimation() {
        let baseAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        baseAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0.3, 0.3, 1.0))
        baseAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0))
        baseAnimation.duration = 0.3
        self.layer.add(baseAnimation, forKey: nil)
    }
    
    func addBehavior() -> UIGravityBehavior {
        let behavior: UIGravityBehavior = UIGravityBehavior()
        behavior.angle = CGFloat(M_PI_2)
        behavior.magnitude = 10
        behavior.addItem(self)
        return behavior
    }
    
    func addDropBehavior() -> UIGravityBehavior {
        let behavior: UIGravityBehavior = UIGravityBehavior()
        behavior.magnitude = 10
        behavior.addItem(self)
        return behavior
    }
    

}


protocol OptionalType {
    associatedtype T
    var asOptional: T? {get}
}
extension Optional: OptionalType {
    var asOptional: Wrapped? {return self}
}
extension Sequence where Iterator.Element: OptionalType {
    var flatMapped: [Iterator.Element.T] {
        return self.flatMap {$0.asOptional}
    }
}










