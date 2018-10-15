//
//  PreviewView.m
//  InputViewPasswordViewDemo
//
//  Created by swifter on 2017/12/20.
//  Copyright © 2017年 pang. All rights reserved.
//

#import "PreviewView.h"
#import "UIView+PFL.h"
@import AVFoundation.AVCaptureDevice;

@interface PreviewView()
@property (nonatomic, strong) UIButton *torchBtn;
@end

@implementation PreviewView

- (void)dealloc {
    NSLog(@"PreviewView_dealloc");
}

- (instancetype)initWithRectOfInterest:(CGRect)frame {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _previewRectOfInterest = frame;
        self.userInteractionEnabled = NO;
        [self layoutCoverViews];
    }
    return self;
}

- (UIButton *)torchBtn {
    return nil;
    if (_torchBtn) {
        return _torchBtn;
    }
    _torchBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _torchBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-100/2, [UIScreen mainScreen].bounds.size.height-100, 100, 44);
    [_torchBtn addTarget:self action:@selector(horchPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_torchBtn];
    [_torchBtn setTitle:@"轻点照亮" forState:(UIControlStateNormal)];
    [_torchBtn setTitle:@"轻点关闭" forState:(UIControlStateSelected)];
//    [_torchBtn setImage:[UIImage imageNamed:@"horch"] forState:(UIControlStateNormal)];
//    [_torchBtn setImage:[UIImage imageNamed:@"horch2"] forState:(UIControlStateSelected)];
    [_torchBtn setTitleEdgeInsets:(UIEdgeInsetsMake(39, 0, 0, 0))];
    [_torchBtn setImageEdgeInsets:(UIEdgeInsetsMake(0, 37, 0, 0))];
    [_torchBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    _torchBtn.hidden = YES;
    return _torchBtn;
}

- (void)horchPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (sender.selected) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];//开
        [device unlockForConfiguration];
    }
    else {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];//关
        [device unlockForConfiguration];
        sender.hidden = YES;
    }
}

- (void)layoutCoverViews {
    CGFloat screenWidth = CGRectGetWidth(self.bounds);
    CGFloat screenHeight = CGRectGetHeight(self.bounds);

    UIView *topView = [[UIView alloc] init];
    topView.height =  self.previewRectOfInterest.origin.y;
    topView.width = screenWidth;
    topView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.height = screenHeight - CGRectGetMaxY(self.previewRectOfInterest);
    bottomView.top = screenHeight - bottomView.height;

    bottomView.width = screenWidth;
    bottomView.backgroundColor = topView.backgroundColor;
    
    UIView *leftView = [[UIView alloc] init];
    leftView.top = topView.bottom;
    leftView.height = self.previewRectOfInterest.size.height;
    leftView.width = screenWidth/2 - self.previewRectOfInterest.size.width/2;
    leftView.backgroundColor = topView.backgroundColor;
    
    UIView *rightView = [[UIView alloc] init];
    rightView.top = topView.bottom;
    rightView.height = leftView.height;
    rightView.width = leftView.width;
    rightView.left = screenWidth - rightView.width;
    rightView.backgroundColor = topView.backgroundColor;
    
    [self addSubview:topView];
    [self addSubview:leftView];
    [self addSubview:bottomView];
    [self addSubview:rightView];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect2:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
    
    CGMutablePathRef screenPath = CGPathCreateMutable();
    CGPathAddRect(screenPath, NULL, self.bounds);
    
    CGMutablePathRef scanPath = CGPathCreateMutable();
//    CGRect rect2 = CGRectMake(self.bounds.size.width/2-120, self.bounds.size.height/2-120, 240, 240);
    CGPathAddRect(scanPath, NULL,_previewRectOfInterest);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, NULL, screenPath);
    CGPathAddPath(path, NULL, scanPath);
    
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathEOFill);
    
    CGPathRelease(screenPath);
    CGPathRelease(scanPath);
    CGPathRelease(path);
}


@end
