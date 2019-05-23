//
//  AppDelegate+MZNotification.m
//  MZNotification
//
//  Created by 曾龙 on 2019/5/23.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import "AppDelegate+MZNotification.h"
#import "MZNotification.h"
#import <objc/runtime.h>

@implementation AppDelegate (MZNotification)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mz_swizzleSelector([self class], @selector(application:didReceiveLocalNotification:),@selector(mz_application:didReceiveLocalNotification:));
    });
}

- (void)mz_application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[MZNotification shareInstance] application:application didReceiveLocalNotification:notification];
}

static inline void mz_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(theClass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(theClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@end
