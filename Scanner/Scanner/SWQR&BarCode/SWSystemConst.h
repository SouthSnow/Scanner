//
//  SWSystemConst.h
//  Wallet
//
//  Created by 章子云 on 2017/12/22.
//  Copyright © 2017年 SwiftPass. All rights reserved.
//

#ifndef SWSystemConst_h
#define SWSystemConst_h

#import <UIKit/UIKit.h>


#define iOS_VERSION ([[UIDevice currentDevice].systemVersion floatValue])


#define iOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
#define iOS11 ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0)

#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kMaxScreenLength (MAX(kScreenWidth, kScreenHeight))
#define kMinScreenLength (MIN(kScreenWidth, kScreenHeight))

#define iPhone4_5 (iPhone && kScreenWidth == 320.0)

/// 屏幕宽
#define Width_iPhoneX_6_7_8 (iPhone && kScreenWidth == 375.0)

#define iPhone4 (iPhone && kMaxScreenLength == 480.0)
#define iPhone5 (iPhone && kMaxScreenLength == 568.0)
#define iPhone6 (iPhone && kMaxScreenLength == 667.0)
#define iPhone6P (iPhone && kMaxScreenLength == 736.0)
#define iPhoneX (iPhone && (kMaxScreenLength == 812.0 || kMaxScreenLength == 896.0))




// 屏幕的宽、高
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define iPhone4Width 320.0
#define iPhone5Width 320.0
#define iPhone6Width 375.0
#define iPhone6PWidth 414.0
#define iPhoneXWidth 375.0


// 状态栏 导航栏 标签栏高度
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavigationBarHeight [[UINavigationController alloc] init].navigationBar.frame.size.height
#define kTabBarHeight [[UITabBarController alloc] init].tabBar.frame.size.height

// 竖屏安全区域
#define kSafeAreaHeight (iPhoneX ? 34.0 : 0.0)
//
//#define kStatusBarSafeAreaHeight (iPhoneX ? 24.0 : 0.0)

// 当前app的版本
#define kAppVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define kAppName [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]


#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >>8))/255.0 blue:((s & 0xFF))/255.0 alpha:1.0]

#define kLineBackgroundColor UIColorFromHex(0xe1e3e4)
#define kMColor UIColorFromHex(0x24272B)


// 国际化
#define SWLocalizedString(key) [[SpayGDLocalizableManger sharedInstance] GDLocalizedString:(key)]
// 网络判断
#define kNetworkEnabled [[SpayNetWorkManager shareInstance] isNetworkEnabled]

#define ISDATACLASS(data) (data && [data isKindOfClass:[NSData class]])
#define ISARRAYCLASS(arr) (arr && [arr isKindOfClass:[NSArray class]])
#define ISDICTIONARYCLASS(dic) (dic && [dic isKindOfClass:[NSDictionary class]])
#define ISSTRINGCLASS(str) (str && [str isKindOfClass:[NSString class]])
#define ISNULLCLASS(obj)  (obj && [obj isKindOfClass:[NSNull null]])

#define FORMATSTRING(str) [NSString stringWithFormat:@"%@",str]


#endif /* SWSystemConst_h */









