//
//  AppDelegate.m
//  MZNotification
//
//  Created by 曾龙 on 2019/5/21.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import "AppDelegate.h"
#import "MZNotification/MZNotification.h"

@interface AppDelegate ()<MZLocalNotificationDelegate,MZRemoteNotificationDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[MZLocalNotification shareInstance] setDelegate:self];
    [[MZRemoteNotification shareInstance] setDelegate:self];
    [[MZLocalNotification shareInstance] setShowNotificationWhenApplicationActice:NO];
    [[MZRemoteNotification shareInstance] setShowNotificationWhenApplicationActice:NO];
    
    //当本地推送和远程推送同时存在时，只需注册远程推送即可
    [[MZRemoteNotification shareInstance] registerRemoteNotification];
    return YES;
}

#pragma mark -MZLocalNotificationDelegate
- (void)mz_didReceiveLocalNotificationOnApplicationBackgroundWithUserInfo:(NSDictionary *)userInfo {
    NSLog(@"localNotification_ApplicationBackgroundWithUserInfo:%@",userInfo.description);
}

- (void)mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:(NSDictionary *)userInfo {
    NSLog(@"localNotification_ApplicationActiveWithUserInfo:%@",userInfo.description);
}

#pragma mark-MZRemoteNotificationDelegate
- (void)mz_didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token tokenString:(NSString *)tokenString {
    NSLog(@"remoteNotification_deviceTokenString:%@",tokenString);
}

- (void)mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:(NSDictionary *)userInfo {
    NSLog(@"remoteNotification_ApplicationActiveWithUserInfo:%@",userInfo.description);
}

- (void)mz_didReceiveRemoteNotificationOnApplicationBackgroundWithUserInfo:(NSDictionary *)userInfo {
    NSLog(@"remoteNotification_ApplicationBackgroundWithUserInfo:%@",userInfo.description);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[MZLocalNotification shareInstance] clearApplicationIconBadge];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
