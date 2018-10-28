//
//  ScanCodeManager.m
//  InputViewPasswordViewDemo
//
//  Created by swifter on 2017/12/21.
//  Copyright © 2017年 pang. All rights reserved.
//

#import "ScanCodeManager.h"
//#import "SWAuthorizationTool.h"

#import "PreviewView.h"
//#import "QHWAlertView.h"

#import "SWAVSessionManager.h"
#import "SWSystemConst.h"
#import "UIView+PFL.h"
#import "SWDispatchTool.h"


static NSString * const kSoundKey = @"scancode.caf";

@interface ScanCodeManager() <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIViewController *presentedViewController;
@property (nonatomic, strong) UIButton *horchTap;
@property (nonatomic, copy) ScanHandler handler;
@property (nonatomic, copy) TorchHandler torchHandler;

@property (nonatomic, strong) PreviewView *preview;

@property (nonatomic, weak) UIView *previewLayerView;


@property (nonatomic, assign) CGSize layerSize;
/**
 是否打开手电
 */
@property (nonatomic, assign) BOOL isOpenTorch;
/**
 扫码结果
 */
@property (nonatomic, copy) id scanResult;

/**
 扫码框尺寸
 */
@property (nonatomic, assign) CGRect rectOfInterest;


@property (nonatomic, assign) BOOL isFinish;

@property (nonatomic, strong) dispatch_queue_t sampleBufferCallbackQueue;

@property (nonatomic, strong) AVCaptureVideoDataOutput *lightDataOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *codeDataOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;




@end

@implementation ScanCodeManager

- (void)dealloc {
    NSLog(@"%@_%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [_lightDataOutput setSampleBufferDelegate:nil queue:self.sampleBufferCallbackQueue];
    [_codeDataOutput setMetadataObjectsDelegate:nil queue:self.sampleBufferCallbackQueue];

}


- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController previewLayerView:(UIView*)previewLayerView rectOfInterest:(CGRect)rectOfInterest  handler:(ScanHandler)handler torchHandler:(TorchHandler)torchHandler {
    if ((self = [super init])) {
        self.presentedViewController = presentedViewController;
        self.handler = handler;
        self.rectOfInterest = rectOfInterest;
        self.previewLayerView = previewLayerView;
        self.torchHandler = torchHandler;
        [self createAVSession2];
    }
    return self;
}

#pragma mark setter

- (void)setRectOfInterest:(CGRect)rectOfInterest {
    _rectOfInterest = rectOfInterest;
}

#pragma mark getter

- (dispatch_queue_t)sampleBufferCallbackQueue {
    if (!_sampleBufferCallbackQueue) {
        _sampleBufferCallbackQueue = dispatch_queue_create("com.wallet.video.queue", NULL);
    }
    return _sampleBufferCallbackQueue;
}

- (AVCaptureSession *)session {
    return self.captureSession;
}

- (void)chooseQRCodeFromAlbum {
    [self chooseQRCodeFromAlbum:nil];
}
/**
 Description 从相册选取照片
 */
- (void)chooseQRCodeFromAlbum:(void(^)(UIImage *image))completionHandler {
    self.chooseFromAblumCompletionHandler = completionHandler;
    [self stopRun];
    [self openAlbum];
}

/**
 新增扫码遮罩
 */
- (void)addInterestWithScanView:(UIView*)scanview {
    CGRect rect = [self convertToRectOfInterest];
    PreviewView *preview  = [[PreviewView alloc] initWithRectOfInterest:rect];
    [scanview insertSubview:preview atIndex:1];
    _preview = preview;
    if (UIScreen.mainScreen.bounds.size.height == 480) {
        preview.height = 604;
    }
}

/**
 打开相机
 */
- (void)openAlbum {
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    pc.delegate = self;
    pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.presentedViewController presentViewController:pc animated:YES completion:nil];
}

/**
 识别image中的二维码信息
 
 @param image 从相册获取的二维码图片
 */
- (void)createDetectorForImage:(CIImage*)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features= [detector featuresInImage:image];
    NSString *messageStr = @"";
    for (CIQRCodeFeature *feature in features) {
        if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
            NSLog(@"messageString: %@",feature.messageString);
            if (feature.messageString) {
                messageStr = [messageStr stringByAppendingString:feature.messageString];
            }
        }
    }
    if (messageStr.length > 0) {
       !_handler?:_handler(messageStr);
    }
}

/**
 授权
 */
- (void)checkAVAuthorizationStatus {
    [self createAVSession2];
}

- (void)setupDelegate {
    [_lightDataOutput setSampleBufferDelegate:self queue:self.sampleBufferCallbackQueue];
    [_codeDataOutput setMetadataObjectsDelegate:self queue:self.sampleBufferCallbackQueue];
}

#pragma  mark public method

- (void)startRun {
    dispatch_async(self.sampleBufferCallbackQueue,^{
        self.isFinish = NO;
        if (!self.captureSession) {
            SWRunOnMainThreadDo(^{
                [self createAVSession2];
            });
        }
        else {
            if (!self.captureSession.isRunning) {
                [self.captureSession startRunning];
            }
        }
        NSLog(@"============startRun==%@===========",NSThread.currentThread);
    });
}

- (void)stopRun {
    dispatch_async(self.sampleBufferCallbackQueue,^{
        self.scanResult = nil;
        if (self.captureSession.isRunning) {
            [self.captureSession stopRunning];
        }
        NSLog(@"============stopRun==%@===========",NSThread.currentThread);
    });
}

#pragma mark 创建AVSession

- (void)createAVSession2 {
    // 1.获取硬件设备
    SWAVSessionManager *shareAVSession = [SWAVSessionManager shareAVSession];
    self.captureSession = shareAVSession.captureSession;
    self.captureDevice = shareAVSession.captureDevice;
    self.deviceInput = shareAVSession.deviceInput;
    self.lightDataOutput = shareAVSession.lightDataOutput;
    self.codeDataOutput = shareAVSession.codeDataOutput;

    [shareAVSession.lightDataOutput setSampleBufferDelegate:self queue:self.sampleBufferCallbackQueue];
    [shareAVSession.codeDataOutput setMetadataObjectsDelegate:self queue:self.sampleBufferCallbackQueue];
    
    // AVCaptureSession
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:shareAVSession.captureSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = _previewLayerView.bounds;
    [self.previewLayerView.layer insertSublayer:layer atIndex:0];
    
    dispatch_async(self.sampleBufferCallbackQueue,^{
        if (!shareAVSession.captureSession.isRunning) {
            [shareAVSession.captureSession startRunning];
            NSLog(@"startRunning...........==%@===========",NSThread.currentThread);

        }
        SWRunOnMainThreadDo(^{
            self->_codeDataOutput.rectOfInterest = [layer metadataOutputRectOfInterestForRect:CGRectInset(self.rectOfInterest, -40, -40)];
        });
    });
    
}


- (void)createAVSession {
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    // 创建AVCaptureSession
    self.captureSession = [[AVCaptureSession alloc]init];
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = _previewLayerView.bounds;
    [self.previewLayerView.layer insertSublayer:layer atIndex:0];
    
    dispatch_async(self.sampleBufferCallbackQueue,^{
        [self.captureSession beginConfiguration];
        // 1.获取硬件设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.captureDevice = device;
        if ([device lockForConfiguration:nil]) {
#if 0
            //自动白平衡
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
#endif
            //自动对焦
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
#if 0
            if ([device isAutoFocusRangeRestrictionSupported]) {
                [device setAutoFocusRangeRestriction:(AVCaptureAutoFocusRangeRestrictionNear)];
            }
#endif
            if ([device isSmoothAutoFocusSupported]) {
                [device setSmoothAutoFocusEnabled:YES];
            }
            [device unlockForConfiguration];
        }
        
        // 2.创建输入流
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {NSLog(@"createDeviceInputError:%@",error.localizedDescription); return;}
        // 3.创建设备输出流
        self.lightDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.lightDataOutput setSampleBufferDelegate:self queue:self.sampleBufferCallbackQueue];
        
        self.codeDataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.codeDataOutput setMetadataObjectsDelegate:self queue:self.sampleBufferCallbackQueue];
        
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
       
        // 添加会话输入和输出
        if ([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
        }
        if ([self.captureSession canAddOutput:self.lightDataOutput]) {
            [self.captureSession addOutput:self.lightDataOutput];
        }
        if ([self.captureSession canAddOutput:self.codeDataOutput]) {
            [self.captureSession addOutput:self.codeDataOutput];
        }
        
        NSMutableArray *metaDataTypes = @[].mutableCopy;
        if ([[self.codeDataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
            [metaDataTypes addObject:AVMetadataObjectTypeQRCode];
        }
        
        if ([[self.codeDataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeCode128Code]) {
            [metaDataTypes addObject:AVMetadataObjectTypeCode128Code];
        }
        [self.codeDataOutput setMetadataObjectTypes:metaDataTypes.copy];
        // 配置完成
        [self.captureSession commitConfiguration];
        
        if (!self.captureSession.isRunning) {
            // 启动session
            [self.captureSession startRunning];
        }
  
        SWRunOnMainThreadDo(^{
            // 预埋解决方案
            __unused void(^blk)(void) = ^(void) {
                CGSize size = self.previewLayerView.size;
                CGRect cropRect = self.rectOfInterest;
                CGFloat p1 = size.height/size.width;
                CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
                if (p1 < p2) {
                    CGFloat fixHeight = self.previewLayerView.size.width * 1920. / 1080.;
                    CGFloat fixPadding = (fixHeight - size.height)/2;
                    self->_codeDataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                                cropRect.origin.x/size.width,
                                                                cropRect.size.height/fixHeight,
                                                                cropRect.size.width/size.width);
                } else {
                    CGFloat fixWidth = self.previewLayerView.size.height * 1080. / 1920.;
                    CGFloat fixPadding = (fixWidth - size.width)/2;
                    self->_codeDataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                                (cropRect.origin.x + fixPadding)/fixWidth,
                                                                cropRect.size.height/size.height,
                                                                cropRect.size.width/fixWidth);
                }
            };
        
            self->_codeDataOutput.rectOfInterest = [layer metadataOutputRectOfInterestForRect:CGRectInset(self.rectOfInterest, -40, -40)];
        });
    });
    
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = self.captureDevice;
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (device.isFocusPointOfInterestSupported) {
            device.focusPointOfInterest = point;
        }
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        [device unlockForConfiguration];
    }
}

- (void)setupDeviceFocus {
    if ([self.previewLayerView.layer.sublayers.firstObject isKindOfClass:AVCaptureVideoPreviewLayer.class]) {
        [self focusAtPoint: [(AVCaptureVideoPreviewLayer*)self.previewLayerView.layer.sublayers.firstObject captureDevicePointOfInterestForPoint:CGPointMake(CGRectGetMidX(self.rectOfInterest), CGRectGetMidY(self.rectOfInterest))]];
    }
}


#pragma mark convertToRectOfInterest

- (CGRect)convertToRectOfInterest {
    return self.rectOfInterest;
}


#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

//    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
//    int bufferWidth = (int) CVPixelBufferGetWidth(cameraFrame);
//    int bufferHeight = (int) CVPixelBufferGetHeight(cameraFrame);
//    NSLog(@"bufferWidth: %d, bufferHeight: %d", bufferWidth, bufferHeight);
    __weak typeof(self) ws = self;
    //    NSLog(@"%f",brightnessValue);
    // 根据brightnessValue的值来打开和关闭闪光灯
    AVCaptureDevice *device = self.captureDevice?:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL result = [device hasTorch];// 判断设备是否有闪光灯
    if (!result) return;
    if (!ws.captureSession.isRunning) return;
    if (ws.isFinish) {
        _scanResult = nil;
        return;
    }
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    SWRunOnMainThreadDo(^{
        [ws setupDeviceFocus];
        if ((brightnessValue < -0.1)) {// 打开闪光灯
            ws.isOpenTorch = YES;
            ws.preview.torchBtn.hidden = NO;
        }else {// 关闭闪光灯
            ws.preview.torchBtn.hidden = !ws.preview.torchBtn.selected;
            if (!ws.isFinish) {
                ws.isOpenTorch = ws.torchHandler ? ws.torchHandler(ws.isOpenTorch) : NO;
            }
        }
    });
}

#pragma mark override setter

- (void)setIsOpenTorch:(BOOL)isOpenTorch {
    _isOpenTorch = isOpenTorch;
    if (_isFinish) {return;}
    __weak typeof(self) ws = self;
    __unused BOOL b = !ws.torchHandler?:ws.torchHandler(isOpenTorch);
}

- (void)setScanResult:(id)scanResult {
    _scanResult = scanResult;
    if (!scanResult) {
        return;
    }
    __weak typeof(self) ws = self;
    !ws.handler?:ws.handler(scanResult);
}




#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataObject *obj = [metadataObjects lastObject];
    if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        NSString *string = [(AVMetadataMachineReadableCodeObject*)obj stringValue];
        NSLog(@"string:%@",string);
        if (ISSTRINGCLASS(string) && string.length > 0 && !self.isFinish) {
            [self.captureSession stopRunning];
            self.isFinish = YES;
            [self playScanCodeSound];
            SWRunOnMainThreadDo(^{
                self.scanResult = string;
            });
        }
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    !self.chooseFromAblumCompletionHandler?:self.chooseFromAblumCompletionHandler(image);
    [self createDetectorForImage:[[CIImage alloc] initWithImage:image]];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        !self.chooseFromAblumCompletionHandler?:self.chooseFromAblumCompletionHandler(image);
        [self createDetectorForImage:[[CIImage alloc] initWithImage:image]];
    }];
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    !self.chooseFromAblumCompletionHandler?:self.chooseFromAblumCompletionHandler(nil);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 播放提示音

- (void)playScanCodeSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:kSoundKey ofType:nil];
    if (path == nil) {
        return;
    }
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&soundID);
    AudioServicesPlayAlertSound(soundID);
}



@end
