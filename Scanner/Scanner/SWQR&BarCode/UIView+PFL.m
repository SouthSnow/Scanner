//
//  UIView+PFL.m
//  PuhuiLife
//
//  Created by pfl on 15/11/23.
//  Copyright © 2015年 QianHai Electronic Pay. All rights reserved.
//

#import "UIView+PFL.h"

@implementation UIView (PFL)


- (void)setX_:(CGFloat)x {
    self.frame = CGRectMake(x, self.y_, self.width, self.height);
}

- (void)setY_:(CGFloat)y {
    self.frame = CGRectMake(self.x_, y, self.width, self.height);
}


- (CGFloat)x_ {
    return self.frame.origin.x;
}

- (CGFloat)y_ {
    return self.frame.origin.y;
}

- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.x_, self.y_, self.width, height);
}

- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.x_, self.y_, width,self.height);
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}


- (void)setLeft:(CGFloat)left {
    self.frame = CGRectMake(left, self.y_, self.width, self.height);
}
- (CGFloat)left {
    return self.x_;
}

- (void)setRight:(CGFloat)right {
    self.frame = CGRectMake(right - self.width, self.y_, self.width, self.height);
}
- (CGFloat)right {
    return self.x_ + self.width;
}

- (void)setBottom:(CGFloat)bottom {
    self.frame = CGRectMake(self.x_, bottom - self.height, self.width, self.height);
}

- (CGFloat)bottom {
    return self.y_ + self.height;
}

- (void)setTop:(CGFloat)top {
    [self setY_:top];
}
- (CGFloat)top {
    return self.y_;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.centerY);
}

- (CGFloat)centerX {
    return self.x_ + self.width/2;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.centerX, centerY);
}

- (CGFloat)centerY {
    return self.y_ + self.height/2;
}

- (void)setCenter_:(CGPoint)center_ {
    self.center = center_;
}

- (CGPoint)center_ {
    return self.center;
}

- (void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.width, self.height);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setSize:(CGSize)size {
    self.frame = CGRectMake(self.x_, self.y_, size.width, size.height);
}

- (CGSize)size {
    return self.frame.size;
}






@end





