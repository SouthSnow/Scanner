//
//  UIApplication+TopViewController.m
//  SWallet
//
//  Created by swifter on 2018/8/10.
//  Copyright © 2018年 SwiftPass. All rights reserved.
//

#import "UIApplication+TopViewController.h"

@implementation UIApplication (TopViewController)

+ (UIViewController *)topViewController {
    return [self topViewController:nil];
}

+ (UIViewController *)topViewController:(UIViewController*)controller {
    UIViewController *vc = controller ?: self.sharedApplication.delegate.window.rootViewController;
    
    // 同一个层级
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController*)vc;
        vc = tab.selectedViewController;
    }
    
    if ([vc isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav = (UINavigationController*)vc;
        vc = nav.topViewController;
    }
    
    if ([vc isKindOfClass:NSClassFromString(@"JTWrapViewController")]) {
        vc = [vc childViewControllers].firstObject.childViewControllers.firstObject?:[vc childViewControllers].firstObject?:vc;
    }
    
    // 另一个层级
    if (vc.presentedViewController) {
        vc = vc.presentedViewController;
        vc = [self topViewController:vc];
    }
    
    return vc;
}


@end
