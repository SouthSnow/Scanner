//
//  SWAVSessionManager.m
//  SWallet
//
//  Created by swifter on 2018/8/18.
//  Copyright © 2018年 SwiftPass. All rights reserved.
//

#import "SWAVSessionManager.h"
@import UIKit.UIImagePickerController;
#import "SWSystemConst.h"
#import "SWDispatchTool.h"

@implementation SWAVSessionManager

+ (instancetype)shareAVSession {
    static dispatch_once_t onceToken;
    static SWAVSessionManager *shareSession = nil;
    dispatch_once(&onceToken, ^{
        shareSession = [SWAVSessionManager new];
    });
    return shareSession;
}

- (AVCaptureSession *)captureSession {
    if (_captureSession == nil) {
        [self createAVSession];
    }
    return _captureSession;
}

- (AVCaptureDevice *)captureDevice {
    if (_captureDevice == nil) {
        [self createAVSession];
    }
    return _captureDevice;
}

- (AVCaptureMetadataOutput *)codeDataOutput {
    if (_codeDataOutput == nil) {
        [self createAVSession];
    }
    return _codeDataOutput;
}

- (AVCaptureVideoDataOutput *)lightDataOutput {
    if (_lightDataOutput == nil) {
        [self createAVSession];
    }
    return _lightDataOutput;
}

- (AVCaptureDeviceInput *)deviceInput {
    if (_deviceInput == nil) {
        [self createAVSession];
    }
    return _deviceInput;
}


#pragma mark 创建AVSession
- (void)createAVSession {
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    
    if (_captureSession) {
        return;
    }
    
    // 1.获取硬件设备
    NSArray <AVCaptureDevice*> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device ;
    for (AVCaptureDevice *device_ in devices) {
        if (device_.position == AVCaptureDevicePositionBack) {
            device = device_;
            break;
        }
    }
    if (!device) {return;}

    // AVCaptureSession属性
    self.captureSession  = [[AVCaptureSession alloc]init];
    
    [self.captureSession beginConfiguration];
    
    // 3.创建设备输出流
    self.lightDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    self.codeDataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    self.captureDevice = device;
    
    NSError *error = nil;
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if (!error) {
        if ([self.captureDevice lockForConfiguration:nil]) {
            //自动对焦
            if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [self.captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [self.captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            if ([self.captureDevice isSmoothAutoFocusSupported]) {
                [self.captureDevice setSmoothAutoFocusEnabled:YES];
            }
            
            // 设置为高质量采集率
            [self.captureSession setSessionPreset:iOS_VERSION <= 9 ?AVCaptureSessionPreset640x480:AVCaptureSessionPresetHigh];
            
            if (iPhoneX || iPhone6P) {
                // 4k
                /* if ([self.session canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
                 [self.session setSessionPreset:AVCaptureSessionPreset3840x2160];
                 }
                 // 1080p
                 else */if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
                     [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
                 }
            }
            
            [self.captureDevice unlockForConfiguration];
        }
        
        // 添加会话输入和输出
        if ([self.captureSession canAddInput:self.deviceInput]) {
            [self.captureSession addInput:self.deviceInput];
        }
        if ([self.captureSession canAddOutput:_lightDataOutput]) {
            [self.captureSession addOutput:_lightDataOutput];
        }
        if ([self.captureSession canAddOutput:_codeDataOutput]) {
            [self.captureSession addOutput:_codeDataOutput];
        }
        
        NSMutableArray *metaDataTypes = @[].mutableCopy;
        if ([[_codeDataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
            [metaDataTypes addObject:AVMetadataObjectTypeQRCode];
        }
        
        if ([[_codeDataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeCode128Code]) {
            [metaDataTypes addObject:AVMetadataObjectTypeCode128Code];
        }
        [_codeDataOutput setMetadataObjectTypes:metaDataTypes.copy];
        
        [self.captureSession commitConfiguration];
        
        [self.captureSession startRunning];
        SWDispatchAfterDoSomething(0., ^{
            [self.captureSession stopRunning];
        });
    }
    else {
        NSLog(@"createInputDeviceError: %@",error.localizedDescription);
    }
}

#pragma mark 销毁session
- (void)destroyAVSession {
    self.captureSession = nil;
    self.deviceInput = nil;
    self.captureDevice = nil;
    self.codeDataOutput = nil;
    self.lightDataOutput = nil;
}

- (void)startRunning {
    SWCreateVideoSerialQueueDo(^{
        if (!self.captureSession.isRunning) {
            [self.captureSession startRunning];
        }
    });
}

- (void)stopRunning {
    SWCreateVideoSerialQueueDo(^{
        if (_captureSession && _captureSession.isRunning) {
            [self.captureSession stopRunning];
        }
    });
}




@end
