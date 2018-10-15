//
//  ErWeiMaImage.m
//  Text
//
//  Created by qiuqiu on 15/10/27.
//  Copyright © 2015年 qiuqiu. All rights reserved.
//

#import "SPQRCodeAndBarCode.h"

@implementation SPQRCodeAndBarCode


/**
 *  实例方法
 *
 *  @return 返回实例对象
 */
+(SPQRCodeAndBarCode *) sharedInstance{
    static SPQRCodeAndBarCode *shareInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareInstance = [[SPQRCodeAndBarCode alloc] init];
    });
    return shareInstance;
}

/**
 *  直接生成带logo的二维码
 *
 *  @param message 二维码内容
 *  @param size    宽或高
 *  @param logo    logo图片
 *
 *  @return 返回二维码图片
 */
+ (UIImage *)generateQRCode:(NSString *)message
                       size:(CGFloat)size
                       logo:(UIImage *)logo{
    
    // 将message转变成NSData
    NSData *stringData = [message dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];

    
    CGRect extent = CGRectIntegral(qrFilter.outputImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    size_t width1 = CGRectGetWidth(extent) * scale;
    size_t height1 = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width1, height1, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:qrFilter.outputImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    //  将logo绘制到二维码上面
    CGImageRef midImage = [UIImage imageWithCGImage:scaledImage].CGImage;
  
    UIImage *qrImage = [UIImage imageWithCGImage:midImage];
    
    CGFloat pading = 0;
    if (logo) {
        UIGraphicsBeginImageContext(qrImage.size);
        // 绘制qrcode
        [qrImage drawInRect:(CGRect){CGPointZero,qrImage.size}];
        // 保持logo是qrcode的1/5
        CGFloat maxW = MAX(qrImage.size.width, qrImage.size.height);//100
        CGFloat logoMaxW = MAX(logo.size.width, logo.size.height); // 60, 40
        CGFloat scale = MIN(logoMaxW / maxW,1/5.0); // 60/100 = 1/6 10,6.67
        CGFloat x = (1 - scale)*qrImage.size.width/2;
        CGFloat y = (1 - scale)*qrImage.size.height/2;
        CGRect logoFrame =  CGRectMake(x, y, maxW*scale, maxW*scale*logo.size.height/logo.size.width);//(CGRect){{x,y},logo.size};//
        // 绘制logo
        [logo drawInRect:logoFrame];
        
        // 获取qrcode和logo
        UIImage *img2=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIGraphicsBeginImageContext(img2.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // 反转坐标系
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -img2.size.height);

#pragma mark 特殊处理, 尽量使内填充为0
        CGContextDrawImage(ctx, CGRectMake(-pading, -pading, size+pading*2, size+pading*2), img2.CGImage);
        // 获取完整的qrcode:坐标正常,logo, qrcode正常
        UIImage *QRImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return QRImage;
    }
    else {
        return qrImage;
//        CGContextDrawImage(ctx, CGRectMake(-pading, -pading, size+pading*2, size+pading*2), midImage);
    }
    
    
//    return QRImage;
}


#pragma mark - 生成二维码
+ (UIImage *)qrCodeImageWithContent:(NSString *)content
                      codeImageSize:(CGFloat)size
                               logo:(UIImage *)logo
                          logoFrame:(CGRect)logoFrame
                                red:(CGFloat)red
                              green:(CGFloat)green
                               blue:(CGFloat)blue {
    
    UIImage *image = [self qrCodeImageWithContent:content codeImageSize:size red:red green:green blue:blue];
    //有 logo 则绘制 logo
    if (logo != nil) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        [logo drawInRect:logoFrame];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }else{
        return image;
    }
    
}

//改变二维码颜色
+ (UIImage *)qrCodeImageWithContent:(NSString *)content codeImageSize:(CGFloat)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue{
    UIImage *image = [self qrCodeImageWithContent:content codeImageSize:size];
    int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    //遍历像素, 改变像素点颜色
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i<pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red*255;
            ptr[2] = green*255;
            ptr[1] = blue*255;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    //取出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpaceRef,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    
    return resultImage;
}

//改变二维码尺寸大小
+ (UIImage *)qrCodeImageWithContent:(NSString *)content codeImageSize:(CGFloat)size{
    CIImage *image = [self qrCodeImageWithContent:content];
    CGRect integralRect = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(integralRect), size/CGRectGetHeight(integralRect));
    
    size_t width = CGRectGetWidth(integralRect)*scale;
    size_t height = CGRectGetHeight(integralRect)*scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:integralRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, integralRect, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

//生成最原始的二维码
+ (CIImage *)qrCodeImageWithContent:(NSString *)content{
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [qrFilter setValue:contentData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *image = qrFilter.outputImage;
    return image;
}


/**
 *  直接生成带数字的条形码
 *
 *  @param message 条形码内容
 *  @param width   条形码宽度(传了高度可以宽度可以传0)
 *  @param height  条形码高度(传了宽度可以高度可以传0)
 *  @param font    条形码字体大小
 *  @param isLabel 是否显示条形码下面的数字
 *
 *  @return 返回条形码图片
 */
+ (UIImage *)generateImageBarCode:(NSString *)message
                       width:(CGFloat)width
                      height:(CGFloat)height
                        font:(CGFloat)font
                     isLabel:(BOOL)isLabel{
    // 生成二维码图片
    CIImage *barcodeImage;
    NSData *data = [message dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@(0.00) forKey:@"inputQuietSpace"];

    barcodeImage = [filter outputImage];
    UIImage *image = [self getHighDefinitionImageFormCIImage:barcodeImage withSize:width];
    
    //  条形码下面的数字,label的宽度减去条形码两边的边距
    if (isLabel) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height+font+16)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [view addSubview:imageView];
        
        UILabel *lalel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bounds.size.height+16, width, font >= 20 ? font+2 : 20)];
        // 每四位一格
        NSInteger spaceCout = 0;
        NSMutableString *textString = message.mutableCopy;
        for (NSInteger i = 0; i < message.length; i ++) {
            // 最后一位不加
            if (((i+1) % 4 == 0) && (i != message.length-1)) {
                // 要加上空格数，因为插入了空格，位置就变了
                [textString insertString:@" " atIndex:i+1 + spaceCout];
                spaceCout ++;
            }
        }
        lalel.text = [textString copy];
        lalel.font = [UIFont systemFontOfSize:font];
        lalel.adjustsFontSizeToFitWidth = YES;
        lalel.backgroundColor = [UIColor clearColor];
        lalel.textAlignment = NSTextAlignmentCenter;
        [view insertSubview:lalel aboveSubview:imageView];
        UIImage *codeImage = [self imageWithUIView:view];
        return codeImage;
    }
    return image;

}


/**
 *  将UIView视图转成图片
 *
 *  @param view 传过来的UIView
 *
 *  @return 返回view转成的图片
 */
+ (UIImage*) imageWithUIView:(UIView*) view
{
    CGSize s = view.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  直接生成带数字(条形码下面)的条形码
 *
 *  @param message 条形码内容
 *  @param width   条形码宽度
 *  @param height  条形码高度
 *  @param font    条形码字体大小(
 *
 *  @return 返回条形码图片
 */
+ (UIImage *)generateImageBarCode:(NSString *)message
                            width:(CGFloat)width
                           height:(CGFloat)height
                             font:(CGFloat)font {
    return [self generateImageBarCode:message width:width height:height font:font isLabel:NO];
}


/**
 生成高清图片

 @param image image
 @param size size
 @return image
 */
+ (UIImage *)getHighDefinitionImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - 生成条形码
+ (UIImage *)barcodeImageWithContent:(NSString *)content codeImageSize:(CGSize)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    UIImage *image = [self barcodeImageWithContent:content codeImageSize:size];
    int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    //遍历像素, 改变像素点颜色
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i<pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red*255;
            ptr[2] = green*255;
            ptr[1] = blue*255;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    //取出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpaceRef,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    
    return resultImage;
}

//改变条形码尺寸大小
+ (UIImage *)barcodeImageWithContent:(NSString *)content codeImageSize:(CGSize)size{
    CIImage *image = [self barcodeImageWithContent:content];
    CGRect integralRect = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width/CGRectGetWidth(integralRect), size.height/CGRectGetHeight(integralRect));
    
    size_t width = CGRectGetWidth(integralRect)*scale;
    size_t height = CGRectGetHeight(integralRect)*scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:integralRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, integralRect, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

//生成最原始的条形码
+ (CIImage *)barcodeImageWithContent:(NSString *)content{
    CIFilter *qrFilter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [qrFilter setValue:contentData forKey:@"inputMessage"];
    [qrFilter setValue:@(0.00) forKey:@"inputQuietSpace"];
    CIImage *image = qrFilter.outputImage;
    return image;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}




@end









