//
//  MZNotification.h
//  MZNotification
//
//  Created by 曾龙 on 2019/5/21.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate+MZNotification.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MZNotificationDelegate <NSObject>

@optional

/**
 app处于前台时收到推送数据

 @param userInfo 推送数据
 */
- (void)mz_didReceiveNotificationOnApplicationActiveWithUserInfo:(NSDictionary *)userInfo;

/**
 app处于后台时收到推送，点击推送后会调用该代理

 @param userInfo 推送数据
 */
- (void)mz_didReceiveNotificationOnApplicationBackgroundWithUserInfo:(NSDictionary *)userInfo;

@end

@interface MZNotification : NSObject <UIApplicationDelegate, UNUserNotificationCenterDelegate>

/**
 MZNotification推送数据回调代理
 */
@property (nonatomic, weak) id<MZNotificationDelegate> delegate;

/**
 当app处于前台时是否弹出推送框，默认弹出（此方法只对iOS10以后的系统有效，因为iOS10之前的app处于前台时，app是不能弹出推送弹框的）
 */
@property (nonatomic, assign) BOOL showNotificationWhenApplicationActice;

+ (instancetype)shareInstance;

/**
 注册本地推送，获取授权
 */
- (void)registerLocalNotification;

/**
 iOS8-iOS10发送本地推送

 @param badge 角标
 @param sound 推送声音（nil代表系统默认声音，可填写自定义推送声音名称）
 @param title 推送标题
 @param message 推送内容
 @param params 推送额外附带数据，会在推送数据回调代理中获取到
 @param fireDate 触发时间（nil代表立即触发）
 @param repeatInterval 重复时间间隔，0代表不重复
 */
- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params fireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval;

/**
 iOS10之后发送本地推送

 @param badge 角标
 @param sound 推送声音（nil代表系统默认声音，可填写自定义推送声音名称）
 @param title 推送标题
 @param message 推送内容
 @param params 推送额外附带数据，会在推送数据回调代理中获取到
 @param trigger 推送触发器
 */
- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params trigger:(nullable UNNotificationTrigger *)trigger API_AVAILABLE(ios(10.0));
@end

NS_ASSUME_NONNULL_END
