//
//  MZLocalNotification.m
//  MZNotification
//
//  Created by 曾龙 on 2019/5/24.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import "MZLocalNotification.h"

@implementation MZLocalNotification
+ (instancetype)shareInstance {
    static MZLocalNotification *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MZLocalNotification alloc] init];
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

- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params fireDate:(nullable NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval identifier:(nonnull NSString *)identifier {
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    if (identifier) {
        [dic setValue:identifier forKey:@"MZNotification_identifier"];
    }
    notification.userInfo = dic;
    notification.applicationIconBadgeNumber = badge;
    notification.repeatInterval = repeatInterval;
    if (fireDate) {
        notification.fireDate = fireDate;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    } else {
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params trigger:(nullable UNNotificationTrigger *)trigger identifier:(nonnull NSString *)identifier  API_AVAILABLE(ios(10.0)) {
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
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)updateLocalNotificationWithBadge:(NSInteger)badge sound:(NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params fireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval identifier:(nonnull NSString *)identifier {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *info = notification.userInfo;
        if (info) {
            NSString *currentIdentifier = [info valueForKey:@"MZNotification_identifier"];
            if ([identifier isEqualToString:currentIdentifier]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
    [self pushLocalNotificationWithBadge:badge sound:sound title:title message:message params:params fireDate:fireDate repeatInterval:repeatInterval identifier:identifier];
}

- (void)updateLocalNotificationWithBadge:(NSInteger)badge sound:(NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params trigger:(UNNotificationTrigger *)trigger identifier:(NSString *)identifier {
    [self pushLocalNotificationWithBadge:badge sound:sound title:title message:message params:params trigger:trigger identifier:identifier];
}

- (void)cancelLocalNotificationWithIdentifier:(nonnull NSString *)identifier {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
    } else {
        NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *notification in localNotifications) {
            NSDictionary *info = notification.userInfo;
            if (info) {
                NSString *currentIdentifier = [info valueForKey:@"MZNotification_identifier"];
                if ([identifier isEqualToString:currentIdentifier]) {
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                    break;
                }
            }
        }
    }
}

- (void)cancelAllLocalNotification {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
        completionHandler(0);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveLocalNotificationOnApplicationBackgroundWithUserInfo:)]) {
            [self.delegate mz_didReceiveLocalNotificationOnApplicationBackgroundWithUserInfo:userInfo];
        }
    }
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:)]) {
            [self.delegate mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:userInfo];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mz_didReceiveLocalNotificationOnApplicationBackgroundWithUserInfo:)]) {
            [self.delegate mz_didReceiveLocalNotificationOnApplicationBackgroundWithUserInfo:userInfo];
        }
    }
}

@end
