//
//  SWBaseButton.h
//  Wallet
//
//  Created by swifter on 2017/12/29.
//  Copyright © 2017年 SwiftPass. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonEventCallBack)(void);

@interface SWBaseButton : UIButton

/**
 init方法

 @param frame 按钮frame
 @param callback 回调
 @return button
 */
- (instancetype)initWithFrame:(CGRect)frame eventCallback:(ButtonEventCallBack)callback;

/**
 工厂方法

 @param buttonType button样式
 @param callback 回调
 @return btn
 */
+ (instancetype)buttonWithType:(UIButtonType)buttonType eventCallback:(ButtonEventCallBack)callback;

/*背景颜色*/
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightColr;
@property (nonatomic, strong) UIColor *selectedColor;

/*标题颜色*/
@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *highlightTitleColr;
@property (nonatomic, strong) UIColor *selectedTitleColor;

/*标题*/
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *normalTitle;
@property (nonatomic, copy) NSString *selectedTitle;
@property (nonatomic, copy) NSString *highlightTitle;

/*字体*/
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIFont *font;

/*扩大点击范围*/
@property (nonatomic, assign) IBInspectable CGPoint enlargeOffset;

/**
 点击回调
 */
@property (nonatomic, copy) ButtonEventCallBack eventCallback;

@property (nonatomic, copy, class) ButtonEventCallBack eventCallback_;

/**
 设置字体,标题, 字体颜色,选择状态

 @param font 字体
 @param title 标题
 @param color 字体颜色
 @param state 选中状态
 */
- (void)setFont:(UIFont*)font title:(NSString*)title titleColor:(UIColor*)color forState:(UIControlState)state;

/**
 设置字体大小,标题, 字体颜色,选择状态
 
 @param fontSize 字体大小
 @param title 标题
 @param color 字体颜色
 @param state 选中状态
 */
- (void)setFontSize:(CGFloat)fontSize title:(NSString*)title titleColor:(UIColor*)color forState:(UIControlState)state;

/**
 设置字体,标题, 字体颜色,选择状态
 
 @param font 字体
 @param title 标题
 @param color 字体颜色
 @param state 选中状态
 @param bgColor 背景颜色
 */

- (void)setFont:(UIFont*)font title:(NSString*)title titleColor:(UIColor*)color forState:(UIControlState)state backgroundColor:(UIColor*)bgColor;

/**
 设置字体大小,标题, 字体颜色,选择状态
 
 @param fontSize 字体大小
 @param title 标题
 @param color 字体颜色
 @param state 选中状态
 @param bgColor 背景颜色
 */
- (void)setFontSize:(CGFloat)fontSize title:(NSString*)title titleColor:(UIColor*)color forState:(UIControlState)state backgroundColor:(UIColor*)bgColor;



@end




