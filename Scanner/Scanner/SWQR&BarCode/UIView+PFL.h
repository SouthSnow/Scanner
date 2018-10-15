//
//  UIView+PFL.h
//  PuhuiLife
//
//  Created by pfl on 15/11/23.
//  Copyright © 2015年 QianHai Electronic Pay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PFL)
/**
 *  原点x
 */
@property (nonatomic, readwrite, assign) CGFloat x_;
/**
 *  原点y
 */
@property (nonatomic, readwrite, assign) CGFloat y_;
/**
 *  最大左边
 */

@property (nonatomic, readwrite, assign) CGFloat left;
/**
 *  最大右边
 */
@property (nonatomic, readwrite, assign) CGFloat right;
/**
 *  控件宽
 */
@property (nonatomic, readwrite, assign) CGFloat width;
/**
 *  控件高
 */
@property (nonatomic, readwrite, assign) CGFloat height;
/**
 *  中点x
 */
@property (nonatomic, readwrite, assign) CGFloat centerX;
/**
 *  中点Y
 */
@property (nonatomic, readwrite, assign) CGFloat centerY;
/**
 *  中点
 */
@property (nonatomic, readwrite, assign) CGPoint center_;

/**
 *  顶部
 */
@property (nonatomic, readwrite, assign) CGFloat top;

/**
 *  底部
 */
@property (nonatomic, readwrite, assign) CGFloat bottom;

/**
 *  size
 */
@property (nonatomic, readwrite, assign) CGSize size;
/**
 *  原点
 */
@property (nonatomic, readwrite, assign) CGPoint origin;


@end














