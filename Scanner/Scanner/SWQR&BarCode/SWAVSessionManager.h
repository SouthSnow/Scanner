//
//  SWAVSessionManager.h
//  SWallet
//
//  Created by swifter on 2018/8/18.
//  Copyright © 2018年 SwiftPass. All rights reserved.
//

#import <Foundation/Foundation.h>
//@import AVFoundation;
#import <AVFoundation/AVFoundation.h>

@interface SWAVSessionManager : NSObject

+ (instancetype)shareAVSession;

@property (nonatomic, strong) AVCaptureVideoDataOutput *lightDataOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *codeDataOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;

- (void)createAVSession;
- (void)destroyAVSession;
- (void)startRunning;
- (void)stopRunning;

@end
