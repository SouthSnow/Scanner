//
//  PreviewView.h
//  InputViewPasswordViewDemo
//
//  Created by swifter on 2017/12/20.
//  Copyright © 2017年 pang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewView : UIView
@property (nonatomic, assign) CGRect previewRectOfInterest;
- (instancetype)initWithRectOfInterest:(CGRect)frame;
@property (nonatomic, readonly) UIButton *torchBtn;
@end
