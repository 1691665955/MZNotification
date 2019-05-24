//
//  MZRemoteNotification.h
//  MZNotification
//
//  Created by 曾龙 on 2019/5/24.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MZRemoteNotificationDelegate <NSObject>

@optional

/**
 远程推送获取deviceToken

 @param token NSData类型deviceToken
 @param tokenString NSString类型deviceToken
 */
- (void)mz_didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token tokenString:(NSString *)tokenString;

/**
 app处于前台时收到推送数据
 
 @param userInfo 推送数据
 */
- (void)mz_didReceiveRemoteNotificationOnApplicationActiveWithUserInfo:(NSDictionary *)userInfo;

/**
 app处于后台时收到推送，点击推送后会调用该代理
 
 @param userInfo 推送数据
 */
- (void)mz_didReceiveRemoteNotificationOnApplicationBackgroundWithUserInfo:(NSDictionary *)userInfo;
@end


@interface MZRemoteNotification : NSObject <UIApplicationDelegate>
/**
 MZRemoteNotification推送数据回调代理
 */
@property (nonatomic, weak) id<MZRemoteNotificationDelegate> delegate;

/**
 当app处于前台时是否弹出推送框，默认弹出（此方法只对iOS10以后的系统有效，因为iOS10之前的app处于前台时，app是不能弹出推送弹框的）
 */
@property (nonatomic, assign) BOOL showNotificationWhenApplicationActice;

+ (instancetype)shareInstance;

/**
 注册远程推送，获取授权
 */
- (void)registerRemoteNotification;

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
