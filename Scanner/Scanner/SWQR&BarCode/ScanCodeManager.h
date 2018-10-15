//
//  ScanCodeManager.h
//  InputViewPasswordViewDemo
//
//  Created by swifter on 2017/12/21.
//  Copyright © 2017年 pang. All rights reserved.
//



#import <Foundation/Foundation.h>
@import UIKit;
@import AVFoundation;


/**
 扫码回调

 @param scanResult 扫码结果
 @param isOpenTorch 是否开启手电
 @return 是否点击了手电
 */
typedef  void (^ScanHandler) (id _Nullable scanResult);
typedef BOOL (^TorchHandler) (BOOL isOpenTorch);

@interface ScanCodeManager : NSObject

/**
 扫码handler

 @param presentedViewController 用于交互控制器
 @param handler 扫码回调
 @return  扫码handler
 */
- (instancetype)initWithPresentedViewController:(UIViewController* _Nonnull)presentedViewController previewLayerView:(UIView*_Nonnull)previewLayerView rectOfInterest:(CGRect)rectOfInterest handler:(ScanHandler _Nullable )handler torchHandler:(TorchHandler _Nullable )torchHandler;


@property (nonatomic, strong, readonly) AVCaptureSession * _Nonnull session;

/** chooseFromAlbumHandler */
@property (nonatomic, copy) void(^chooseFromAblumCompletionHandler)(UIImage *image);


/**
 从相册获取二维码
 */
- (void)chooseQRCodeFromAlbum;
- (void)chooseQRCodeFromAlbum:(void(^)(UIImage *image))completionHandler;

- (void)startRun;
- (void)stopRun;

- (void)setupDelegate;

/**
 授权
 */
- (void)checkAVAuthorizationStatus;

- (void)addInterestWithScanView:(UIView*)scanview;


@end










