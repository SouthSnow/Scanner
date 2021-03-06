//
//  SWScanView.m
//  SWallet
//
//  Created by swifter on 2018/8/15.
//  Copyright © 2018年 SwiftPass. All rights reserved.
//

#import "SWScanView.h"
#import "UIView+PFL.h"
@import AVFoundation.AVCaptureDevice;

@interface SWScanView ()
/** scanView */
@property (nonatomic, strong) UIControl *scanView;
/** 扫描框 */
@property (nonatomic, strong) UIImageView *scanImageView;
/** 扫描线 */
@property (nonatomic, strong) UIControl *scanLine;

/** 手电 */
@property (nonatomic, strong) UIButton *torchBtn;

/** 手电视图 */
@property (nonatomic, strong) UIControl *torchView;

/** 手电label */
@property (nonatomic, strong) UILabel *torchTipLabel;

/** 提示视图 */
@property (nonatomic, strong) UIControl *tipView;

/** 提示label */
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation SWScanView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self setupSubviews];
        [self layoutIfNeeded];
        [self setNeedsLayout];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTorchAction) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
}

#pragma mark 配置子视图
- (void)setupSubviews {
    [self addSubview:self.scanView];
    [self addSubview:self.tipView];

    [self.scanView addSubview:self.scanImageView];
    [self.scanView addSubview:self.scanLine];
    [self.torchView addSubview:self.torchBtn];
    [self.torchView addSubview:self.torchTipLabel];
    [self.tipView addSubview:self.tipLabel];
    [self addSubview:self.torchView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectEqualToRect(CGRectZero, self.previewRectOfInterest)) {
        self.scanView.top = 80;
    }
    self.torchView.centerY = self.scanView.centerY+20;
    self.tipView.top = self.torchView.bottom + 100;
    
    self.scanView.size = self.scanImageView.size;
    self.scanView.centerX = self.width/2;
    self.scanLine.centerX = self.scanView.width/2;
    self.scanLine.top = 3;
    
    self.tipView.size = self.tipLabel.size;
    self.tipView.centerX = self.scanView.centerX;
    
    self.torchView.centerX = self.scanView.centerX;
    self.torchView.height = self.torchTipLabel.bottom - self.torchBtn.top;
    self.torchView.width = self.torchTipLabel.width;;
    self.torchTipLabel.centerX = self.torchView.width/2;
    self.torchBtn.centerX = self.torchTipLabel.centerX;
}

#pragma mark getter setter

- (void)setPreviewRectOfInterest:(CGRect)previewRectOfInterest {
    _previewRectOfInterest = previewRectOfInterest;
    self.scanImageView.frame = (CGRect){CGPointZero, previewRectOfInterest.size};
    self.scanView.frame = previewRectOfInterest;
    [self stopAnimation];
    [self.scanLine removeFromSuperview];
    self.scanLine = nil;
    [self.scanView addSubview:self.scanLine];
}

- (UIControl *)scanView {
    if (_scanView == nil) {
        _scanView = [UIControl new];
        _scanView.backgroundColor = UIColor.clearColor;
    }
    return _scanView;
}

- (UIImageView *)scanImageView {
    if (!_scanImageView) {
        _scanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tab_home_scanarea"]];
        [_scanImageView sizeToFit];
        CGFloat size = MAX(MAX(_scanImageView.width,_scanImageView.height),217);
        size = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds)-140, size);
        _scanImageView.size = CGSizeMake(size, size);
        if (!CGRectEqualToRect(CGRectZero, self.previewRectOfInterest)) {
            _scanImageView.frame = self.previewRectOfInterest;
        }
        _scanImageView.backgroundColor = UIColor.clearColor;
    }
    return _scanImageView;
}

- (UIControl *)scanLine {
    if (_scanLine == nil) {
        _scanLine = [UIControl new];
        _scanLine.backgroundColor = UIColor.whiteColor;
        _scanLine.height = 2;
        _scanLine.width = self.scanImageView.width-20;
        _scanLine.hidden = YES;
    }
    return _scanLine;
}

- (UIControl *)torchView {
    if (!_torchView) {
        _torchView = [UIControl new];
        [_torchView sizeToFit];
//        _torchView.size = CGSizeMake(44, 44);
        [_torchView addTarget:self action:@selector(changeTorchStatusAction:) forControlEvents:UIControlEventTouchUpInside];
        _torchView.hidden = YES;
        _torchView.backgroundColor = UIColor.clearColor;

    }
    return _torchView;
}

- (UIButton *)torchBtn {
    if (_torchBtn == nil) {
        _torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_torchBtn setImage:[UIImage imageNamed: @"icon_button_light_off"] forState:UIControlStateNormal];
        [_torchBtn setImage:[UIImage imageNamed: @"icon_button_light_on"] forState:UIControlStateSelected];
        [_torchBtn sizeToFit];
        _torchBtn.tag = 3;
        [_torchBtn addTarget:self action:@selector(changeTorchStatusAction:) forControlEvents:UIControlEventTouchUpInside];
        _torchBtn.userInteractionEnabled = YES;
    }
    return _torchBtn;
}

- (UILabel *)torchTipLabel {
    if (!_torchTipLabel) {
        _torchTipLabel = [UILabel new];
        _torchTipLabel.textAlignment = NSTextAlignmentCenter;
        _torchTipLabel.font = [UIFont systemFontOfSize:15];
        _torchTipLabel.textColor = UIColor.clearColor;
        _torchTipLabel.top = self.torchBtn.bottom+14;
        _torchTipLabel.text = @" 00000  ";
        [_torchTipLabel sizeToFit];
    }
    return _torchTipLabel;
}

- (UIControl *)tipView {
    if (!_tipView) {
        _tipView = [UIControl new];
        _tipView.backgroundColor = UIColor.clearColor;

    }
    return _tipView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15];
        _tipLabel.textColor = UIColor.whiteColor;
//        _tipLabel.text = @"SW30007";
        [_tipLabel sizeToFit];
    }
    return _tipLabel;
}

#pragma mark event

- (void)changeTorchStatusAction:(id)sender {
    !self.torchPressedAction?:self.torchPressedAction(self.torchBtn);
    [self torchPressed];
}

- (void)torchPressed {
    self.torchBtn.selected = !self.torchBtn.selected;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (self.torchBtn.selected) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];//开
        [device unlockForConfiguration];
        self.torchTipLabel.text = @"SW30013";
    }
    else {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];//关
        [device unlockForConfiguration];
        self.torchView.hidden = YES;
        self.torchTipLabel.text = @"SW30012";
    }
}

- (void)stratAnimation {
    self.scanLine.hidden = NO;
    [self.scanLine.layer addAnimation:[self moveAnimation] forKey:@"move"];
}

- (void)stopAnimation {
    self.scanLine.hidden = YES;
    [self.scanLine.layer removeAllAnimations];
}

#pragma mark closeTorchAction
- (void)closeTorchAction {
    self.torchBtn.selected = NO;
    self.torchView.hidden = YES;
}

-(CABasicAnimation*)moveAnimation {
    CGPoint starPoint = CGPointMake(_scanLine .center.x  , _scanLine.center.y);
    CGPoint endPoint = CGPointMake(_scanLine.center.x, _scanImageView.bounds.size.height-5);
    CABasicAnimation*translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translation.fromValue = [NSValue valueWithCGPoint:starPoint];
    translation.toValue = [NSValue valueWithCGPoint:endPoint];
    translation.duration = 1.5;
    translation.repeatCount = CGFLOAT_MAX;
    translation.autoreverses = NO;
    translation.timeOffset = 0;
    return translation;
}



@end
