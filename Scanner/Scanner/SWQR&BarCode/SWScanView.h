//
//  SWScanView.h
//  SWallet
//
//  Created by swifter on 2018/8/15.
//  Copyright © 2018年 SwiftPass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWScanView : UIControl

@property (nonatomic, assign) CGRect previewRectOfInterest;
/** scanView */
@property (nonatomic, strong, readonly) UIControl *scanView;
/** 扫描框 */
@property (nonatomic, strong, readonly) UIImageView *scanImageView;
/** 扫描线 */
@property (nonatomic, strong, readonly) UIControl *scanLine;

/** 手电 */
@property (nonatomic, strong, readonly) UIButton *torchBtn;

/** 手电视图 */
@property (nonatomic, strong, readonly) UIControl *torchView;

/** 手电label */
@property (nonatomic, strong, readonly) UILabel *torchTipLabel;

/** 提示视图 */
@property (nonatomic, strong, readonly) UIControl *tipView;

/** 提示label */
@property (nonatomic, strong, readonly) UILabel *tipLabel;

@property (nonatomic, copy) void (^torchPressedAction)(UIButton*btn);

 #pragma mark start Animation
- (void)stratAnimation;
- (void)stopAnimation;
@end
