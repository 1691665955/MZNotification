//
//  MZLocalNotification.h
//  MZNotification
//
//  Created by 曾龙 on 2019/5/24.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MZLocalNotificationDelegate <NSObject>

@optional

/**
 app处于前台时收到推送数据
 
 @param userInfo 推送数据
 */
- (void)mz_didReceiveLocalNotificationOnApplicationActiveWithUserInfo:(NSDictionary *)userInfo;

/**
 app处于后台时收到推送，点击推送后会调用该代理
 
 @param userInfo 推送数据
 */
- (void)mz_didReceiveLocalNotificationOnApplicationBackgroundWithUserInfo:(NSDictionary *)userInfo;

@end

@interface MZLocalNotification : NSObject <UIApplicationDelegate, UNUserNotificationCenterDelegate>

/**
 MZLocalNotification推送数据回调代理
 */
@property (nonatomic, weak) id<MZLocalNotificationDelegate> delegate;

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
 @param identifier 通知标志符，可用来更新和删除本地通知
 */
- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params fireDate:(nullable NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval identifier:(nonnull NSString *)identifier;

/**
 iOS10之后发送本地推送
 
 @param badge 角标
 @param sound 推送声音（nil代表系统默认声音，可填写自定义推送声音名称）
 @param title 推送标题
 @param message 推送内容
 @param params 推送额外附带数据，会在推送数据回调代理中获取到
 @param trigger 推送触发器
 @param identifier 通知标志符，可用来更新和删除本地通知
 */
- (void)pushLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params trigger:(nullable UNNotificationTrigger *)trigger identifier:(nonnull NSString *)identifier API_AVAILABLE(ios(10.0));

/**
 iOS8-iOS10更新本地推送(相同identifier的推送会替换)
 
 @param badge 角标
 @param sound 推送声音（nil代表系统默认声音，可填写自定义推送声音名称）
 @param title 推送标题
 @param message 推送内容
 @param params 推送额外附带数据，会在推送数据回调代理中获取到
 @param fireDate 触发时间（nil代表立即触发）
 @param repeatInterval 重复时间间隔，0代表不重复
 @param identifier 通知标志符，可用来更新和删除本地通知
 */
- (void)updateLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params fireDate:(nullable NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval identifier:(nonnull NSString *)identifier;

/**
 iOS10之后更新本地推送(相同identifier的推送会替换)
 
 @param badge 角标
 @param sound 推送声音（nil代表系统默认声音，可填写自定义推送声音名称）
 @param title 推送标题
 @param message 推送内容
 @param params 推送额外附带数据，会在推送数据回调代理中获取到
 @param trigger 推送触发器
 @param identifier 通知标志符，可用来更新和删除本地通知
 */
- (void)updateLocalNotificationWithBadge:(NSInteger)badge sound:(nullable NSString *)sound title:(NSString *)title message:(NSString *)message params:(NSDictionary *)params trigger:(nullable UNNotificationTrigger *)trigger identifier:(nonnull NSString *)identifier API_AVAILABLE(ios(10.0));

/**
 取消指定标志符的本地推送
 
 @param identifier 通知标志符
 */
- (void)cancelLocalNotificationWithIdentifier:(nonnull NSString *)identifier;

/**
 取消所有本地推送
 */
- (void)cancelAllLocalNotification;

/**
 设置app角标数量

 @param badge 角标数量
 */
- (void)setApplicationIconBadgeNumber:(NSInteger)badge;

/**
 去除app角标
 */
- (void)clearApplicationIconBadge;

@end

NS_ASSUME_NONNULL_END
