//
//  MZRemoteNotification.m
//  MZNotification
//
//  Created by 曾龙 on 2019/5/24.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import "MZRemoteNotification.h"
#import <UserNotifications/UserNotifications.h>

@interface MZRemoteNotification () <UNUserNotificationCenterDelegate>

@end

@implementation MZRemoteNotification
+ (instancetype)shareInstance {
    static MZRemoteNotification *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MZRemoteNotification alloc] init];
        instance.showNotificationWhenApplicationActice = YES;
    });
    return instance;
}

- (void)registerRemoteNotification {
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
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)setApplicationIconBadgeNumber:(NSInteger)badge {
    if (badge < 0) {
        badge = 0;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
}

- (void)clearApplicationIconBadge {
    [self setApplicationIconBadgeNumber:0];
}

#pragma mark -UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    if (self.showNotificationWhenApplicationActice) {
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    } else {
        NSDictionary *userInfo = notification.request.content.userInfo;
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
        completionHandler(0);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveRemoteNotificationOnApplicationBackgroundWithUserInfo:)]) {
            [self.delegate mz_didReceiveRemoteNotificationOnApplicationBackgroundWithUserInfo:userInfo];
        }
    }
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveRemoteNotificationOnApplicationBackgroundWithUserInfo:)]) {
            [self.delegate mz_didReceiveRemoteNotificationOnApplicationBackgroundWithUserInfo:userInfo];
        }
    }
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didRegisterForRemoteNotificationsWithDeviceToken:tokenString:)]) {
        if (@available(iOS 13.0, *)) {
            NSMutableString *deviceString = [NSMutableString string];
            const char *bytes = deviceToken.bytes;
            NSInteger count = deviceToken.length;
            for (int i = 0; i < count; i++) {
                [deviceString appendFormat:@"%02x", bytes[i]&0x000000FF];
            }
            [self.delegate mz_didRegisterForRemoteNotificationsWithDeviceToken:deviceToken tokenString:deviceString];
        } else {
            NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
            NSString *deviceString = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                   stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
            [self.delegate mz_didRegisterForRemoteNotificationsWithDeviceToken:deviceToken tokenString:deviceString];
        }
    }
}

@end
