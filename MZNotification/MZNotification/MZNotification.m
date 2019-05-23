//
//  MZNotification.m
//  MZNotification
//
//  Created by 曾龙 on 2019/5/21.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import "MZNotification.h"

@implementation MZNotification
+ (instancetype)shareInstance {
    static MZNotification *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MZNotification alloc] init];
        instance.showNotificationWhenApplicationActice = YES;
    });
    return instance;
}

- (void)registerLocalNotification {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        center.delegate = self;
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params fireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (@available(iOS 8.2, *)) {
        notification.alertTitle = title;
    }
    notification.alertBody = message;
    if (sound) {
        notification.soundName = sound;
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
    }
    notification.userInfo = params;
    notification.applicationIconBadgeNumber = badge;
    notification.repeatInterval = repeatInterval;
    if (fireDate) {
        notification.fireDate = fireDate;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    } else {
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params trigger:(nullable UNNotificationTrigger *)trigger API_AVAILABLE(ios(10.0)) {
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = message;
    if (sound) {
        content.sound = [UNNotificationSound soundNamed:sound];
    } else {
        content.sound = UNNotificationSound.defaultSound;
    }
    content.userInfo = params;
    content.badge = [NSNumber numberWithInteger:badge];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"MZNotification"
                                                                          content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark -UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    if (self.showNotificationWhenApplicationActice) {
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    } else {
        NSDictionary *userInfo = notification.request.content.userInfo;
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
        completionHandler(0);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveNotificationOnApplicationBackgroundWithUserInfo:)]) {
            [self.delegate mz_didReceiveNotificationOnApplicationBackgroundWithUserInfo:userInfo];
        }
    }
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveNotificationOnApplicationBackgroundWithUserInfo:)]) {
            [self.delegate mz_didReceiveNotificationOnApplicationBackgroundWithUserInfo:userInfo];
        }
    }
}

@end
