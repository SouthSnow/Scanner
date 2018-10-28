//
//  SWBaseButton.m
//  Wallet
//
//  Created by swifter on 2017/12/29.
//  Copyright © 2017年 SwiftPass. All rights reserved.
//

#import "SWBaseButton.h"

@implementation NSString (ImageConvert)

- (UIImage *)convertToImgae {
    if ([self isKindOfClass:[NSString class]] && self.length > 0) {
        return [UIImage imageNamed:self];
    }
    return [UIImage new];
}

- (UIImage*)image {
    return [self convertToImgae];
}

@end


@interface SWBaseButton ()
//@property (nonatomic, copy) ButtonEventCallBack eventCallback;
@end

@implementation SWBaseButton

static NSMutableDictionary *_cbDic_;
static ButtonEventCallBack _eventCallback_;

- (void)dealloc {
    _eventCallback_ = nil;
}

#pragma mark init

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame eventCallback:(ButtonEventCallBack)callback  {
    self = [super initWithFrame:frame];
    if (self) {
        _eventCallback = callback;
        if (!_cbDic_) {
            _cbDic_ =  @{}.mutableCopy;
        }
        [_cbDic_ setValue:callback forKey:[self identityKey]];
    }
    return self;
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType eventCallback:(ButtonEventCallBack)callback {
    SWBaseButton *btn = [SWBaseButton buttonWithType:buttonType];
    if (self) {
        _eventCallback_ = callback;
        if (!_cbDic_) {
            _cbDic_ =  @{}.mutableCopy;
        }
        [_cbDic_ setValue:callback forKey:[btn identityKey]];
    }
    return btn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(btnPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return self;
}

#pragma mark override

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
//    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [super sendAction:action to:target forEvent:event];
}


- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupStyle];
}

/// 只对xib有效
//- (CGSize)intrinsicContentSize {
//    return (CGSize){304.0, 44};
//}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    if (!userInteractionEnabled) {
        [self setBackgroundImage:[self backgroundImageForState:(UIControlStateDisabled)]?:@"buttom_next_unavailable".image forState:(UIControlStateDisabled)];
        self.alpha = 0.5;
    }
    else {
        [self setBackgroundImage: [self backgroundImageForState:(UIControlStateNormal)] ?:@"buttom_next_default".image forState:(UIControlStateNormal)];
        self.alpha = 1;
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled) {
        [self setBackgroundImage:[self backgroundImageForState:(UIControlStateDisabled)]?:@"buttom_next_unavailable".image forState:(UIControlStateDisabled)];
        self.alpha = 0.5;
    }
    else {
        [self setBackgroundImage: [self backgroundImageForState:(UIControlStateNormal)] ?:@"buttom_next_default".image forState:(UIControlStateNormal)];
        self.alpha = 1;
    }
}

#pragma mark setter

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    [self setBackgroundColor:normalColor];
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    [self setBackgroundColor:bgColor];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
}

- (void)setHighlightColr:(UIColor *)highlightColr {
    _highlightColr = highlightColr;
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    _normalTitleColor = normalTitleColor;
    [self setTitleColor:normalTitleColor forState:UIControlStateNormal];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    [self setTitleColor:selectedTitleColor forState:UIControlStateSelected];
}

- (void)setHighlightTitleColr:(UIColor *)highlightTitleColr {
    _highlightTitleColr = highlightTitleColr;
    [self setTitleColor:highlightTitleColr forState:UIControlStateHighlighted];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setNormalTitle:title];
}

- (void)setNormalTitle:(NSString *)normalTitle {
    _normalTitle = normalTitle;
    [self setTitle:normalTitle forState:(UIControlStateNormal)];
}

- (void)setSelectedTitle:(NSString *)selectedTitle {
    _selectedTitle = selectedTitle;
    [self setTitle:selectedTitle forState:UIControlStateSelected];
}

- (void)setHighlightTitle:(NSString *)highlightTitle {
    _highlightTitle = highlightTitle;
    [self setTitle:highlightTitle forState:UIControlStateHighlighted];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self.titleLabel setFont:font];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    [self setFont:[UIFont systemFontOfSize:fontSize]];
}


+ (void)setEventCallback_:(ButtonEventCallBack)eventCallback_ {
    _eventCallback_ = eventCallback_;
}

+ (ButtonEventCallBack)eventCallback_ {
    if (!_eventCallback_) {
        _eventCallback_ = ^{};
    }
    return _eventCallback_;
}


#pragma mark public method

- (void)setFont:(UIFont *)font title:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)state {
    self.font = font;
    color = color ?: [UIColor whiteColor];
    font = font ?: [UIFont systemFontOfSize:[UIFont systemFontSize]];
    [self setTitleColor:color forState:state];
    [self setTitle:title forState:state];
}

- (void)setFontSize:(CGFloat)fontSize title:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)state {
    fontSize = fontSize ?: [UIFont systemFontSize];
    self.fontSize = fontSize;
    [self setFont:[UIFont systemFontOfSize:fontSize] title:title titleColor:color forState:state];
}

- (void)setFont:(UIFont *)font title:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)state backgroundColor:(UIColor *)bgColor {
    bgColor = bgColor ?: [UIColor clearColor];
    switch (state) {
        case UIControlStateNormal:
            [self setBgColor:bgColor];
            break;
        case UIControlStateSelected:
            [self setBgColor:bgColor];
            break;
        case UIControlStateHighlighted:
            [self setBgColor:bgColor];
            break;
        case UIControlStateDisabled:
            [self setBgColor:bgColor];
            break;
        default:
            [self setBgColor:bgColor];
            break;
    }
    [self setFont:font title:title titleColor:color forState:state];
}

- (void)setFontSize:(CGFloat)fontSize title:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)state backgroundColor:(UIColor *)bgColor {
    fontSize = fontSize ?: [UIFont systemFontSize];
    self.fontSize = fontSize;
    [self setFont:[UIFont systemFontOfSize:fontSize] title:title titleColor:color forState:state backgroundColor:bgColor];
}


#pragma mark private method

#pragma mark 将指针作为唯一标识符
- (NSString*)identityKey {
    NSString *key = [NSString stringWithFormat:@"%p",self];
    NSLog(@"identityKey:%@",key);
    return key;
}

- (void)setupStyle {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = MIN(self.bounds.size.height, self.bounds.size.width)/2;
}

- (void)btnPressed:(UIButton*)btn {
    ButtonEventCallBack cb = [_cbDic_ valueForKey:[self identityKey]];
    if (cb)cb();
}

#pragma mark override

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGPointEqualToPoint(CGPointZero, self.enlargeOffset)) {
        return [super pointInside:point withEvent:event];
    }
    CGRect rect = CGRectInset(self.bounds, -self.enlargeOffset.x, -self.enlargeOffset.y);
    return CGRectContainsPoint(rect, point);
}


@end














