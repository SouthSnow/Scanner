//
//  PFL.swift
//  YiDongFu
//
//  Created by dongbailan on 16/4/11.
//  Copyright © 2016年 pfl. All rights reserved.
//

import UIKit

protocol ViewFrameable {
     var x: CGFloat {set get}
     var y: CGFloat  {set get}
     var left: CGFloat  {set get}
     var right: CGFloat  {set get}
     var top: CGFloat  {set get}
     var bottom: CGFloat  {set get}
     var width: CGFloat {set get}
     var height: CGFloat {set get}
     var centerX: CGFloat {set get}
     var centerY: CGFloat {set get}
     var center_: CGPoint {set get}
     var origin: CGPoint {set get}
     var size: CGSize {set get}
}

extension ViewFrameable where Self: UIView {
    
     var x: CGFloat {
        set {
            self.frame = CGRect(x: newValue, y: self.y, width: self.width, height: self.height)
        }
        get {
            return self.frame.origin.x
        }
    }
    
     var y: CGFloat {
        set {
            self.frame = CGRect(x: self.x, y: newValue, width: self.width, height: self.height)
        }
        get {
            return self.frame.origin.y
        }
    }
    
     var top: CGFloat {
        set {
            self.y = newValue
        }
        get {
            return self.frame.origin.y
        }
    }
    
     var bottom: CGFloat {
        set {
            self.frame = CGRect(x: self.x, y: newValue - self.height, width: self.width, height: self.height)
        }
        get {
            return self.y + self.height
        }
    }
    
     var left: CGFloat {
        set {
            self.x = newValue
        }
        get {
            return self.x
        }
    }
    
     var right: CGFloat {
        set {
            self.frame = CGRect(x: newValue - self.width, y: self.y, width: self.width, height: self.height)
        }
        get {
            return self.x + self.width
        }
    }
    
     var centerX: CGFloat {
        set {
            self.center = CGPoint(x: newValue, y: centerY);
        }
        get {
            return self.x + self.width/2
        }
    }
    
     var centerY: CGFloat {
        set {
            self.center = CGPoint(x: centerX, y: newValue);
        }
        get {
            return self.y + self.height/2
        }
    }
    
     var center_: CGPoint {
        set {
            self.center = newValue
        }
        get {
            return self.center
        }
    }
    
     var origin: CGPoint {
        set {
            self.frame.origin = origin
        }
        get {
            return self.frame.origin
        }
    }
    
     var size: CGSize {
        set {
            self.frame.size = newValue
        }
        get {
            return self.frame.size
        }
    }

     var width: CGFloat {
        set {
            self.frame = CGRect(x: self.x, y: self.y, width: newValue, height: self.height)
        }
        get {
            return self.frame.size.width
        }
    }
    
     var height: CGFloat {
        set {
            self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: newValue)
        }
        get {
            return self.frame.size.height
        }
    }
    
}

extension UIView: ViewFrameable {}








