//
//  ErWeiMaImage.h
//  Text
//
//  Created by qiuqiu on 15/10/27.
//  Copyright © 2015年 qiuqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

@interface SPQRCodeAndBarCode : NSObject

/**
 *  实例方法
 *
 *  @return 返回实例对象
 */
+(SPQRCodeAndBarCode *) sharedInstance;


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
                       logo:(UIImage *)logo;

+ (UIImage *)qrCodeImageWithContent:(NSString *)content
                      codeImageSize:(CGFloat)size
                               logo:(UIImage *)logo
                          logoFrame:(CGRect)logoFrame
                                red:(CGFloat)red
                              green:(CGFloat)green
                               blue:(CGFloat)blue;

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
                     isLabel:(BOOL)isLabel;


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
                             font:(CGFloat)font;


+ (UIImage *)barcodeImageWithContent:(NSString *)content codeImageSize:(CGSize)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blu;

+ (UIImage *)qrCodeImageWithContent:(NSString *)content codeImageSize:(CGFloat)size;
@end
