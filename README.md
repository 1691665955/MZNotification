# MZNotification
## 前言
最近开发一个项目是关于门禁系统的，会有门口机呼叫app的功能。本项目运用了voip来进行推送并唤醒app，然后利用本地推送来进行弹框提醒，目前该项目也已基本完成。联想到本人之前也做过类似闹钟功能的项目也用到了本地推送，所以想到对本地推送和远程推送进行简单的封装，待下次使用的时候能够更方便一点。

### 本地推送
#### UILocalNotification（iOS8-iOS10）
在iOS10之前我们是使用UILocalNotification来进行本地推送的，接下来我们来介绍下简单的流程。
- 注册本地通知
```
UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
```
- 创建通知
```
UILocalNotification *notification = [[UILocalNotification alloc] init];
if (@available(iOS 8.2, *)) {
notification.alertTitle = title;//设置推送的标题
}
notification.alertBody = message;//设置推送的内容
notification.soundName = UILocalNotificationDefaultSoundName;//设置推送的声音，可设置自定义铃声，但是不可超过30s
notification.userInfo = @{@"tag":@"zzzz"};//设置本地推送附带信息
notification.applicationIconBadgeNumber = badge;//设置app角标
notification.repeatInterval = repeatInterval;//推送重复间隔，0代表不重复
if (fireDate) {
notification.fireDate = fireDate;//设置fireDate可设置推送时间
[[UIApplication sharedApplication] scheduleLocalNotification:notification];
} else {
[[UIApplication sharedApplication] presentLocalNotificationNow:notification];//立即执行推送
}
```
- 删除通知
1. 删除指定通知，在notification的userInfo中存储指定的标志符，但删除的时候在找出对应的标志符的notification来删除。
```
NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];//获取所有本地推送
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
```
2. 删除所有通知
```
[[UIApplication sharedApplication] cancelAllLocalNotifications];
```
- 更新通知
先找到要更新的通知，删除该通知，再重新创建一个新的通知，具体操作步骤请参考上面的删除通知和创建通知。

- 通知代理回调
当app处于前台时收到推送信息时或app处于后台时点击推送时
```
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
NSDictionary *userInfo = notification.userInfo;
if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//app处于前台时收到推送信息时
} else {
//app处于后台时点击推送时
}
}
```

#### UNUserNotificationCenter（iOS10之后）
在iOS10之后我们使用UNUserNotificationCenter来创建和管理本地通知，接下来我们同样介绍下简单的流程。
- 注册本地通知
```
UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
[center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
if (!error) {
NSLog(@"request authorization succeeded!");
}
}];
center.delegate = self;
```
- 创建通知
```
UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];//通知管理中心
UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];//创建推送内容对象
content.title = title;//推送标题
content.body = message;//推送内容
content.sound = UNNotificationSound.defaultSound;//设置推送铃声
//content.sound = [UNNotificationSound soundNamed:sound];//设置自定义铃声，sound为铃声名称
content.userInfo = @{@"tag":@"zzzz"};//设置本地推送附带信息
content.badge = [NSNumber numberWithInteger:badge];//设置app角标
//初始化本地通知请求，具体参数这里就不多赘述了，大家可以自行baidu
UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
content:content trigger:trigger];
[center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {

}];
```
- 删除通知
1. 删除指定通知,这里只要知道通知的identifier，就可以删除指定的通知
```
[[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
```
2. 删除所有通知
```
[[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
```
- 更新通知
iOS10之后的更新通知比UILocalNotification简单些，只需要重新创建一个相同identifier的本地通知即可，此时新的通知会自动替换掉相同identifier的通知，具体的创建通知的操作请参考上面的创建通知。

- 通知代理回调
app处于前台时
```
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
```
app点击推送消息时
```
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) {
completionHandler();
}
```

### 远程推送

- 远程推送的注册和本地通知的基本一样，最后多加一个一行代码去请求deviceToken即可
```
[[UIApplication sharedApplication] registerForRemoteNotifications];
```
注册完远程通知后获取到deviceToken，将deviceToken通过接口传给后台，后台通过deviceToken就可以推送通知到指定设备了。

- 远程推送的消息代理回调基本和本地推送的一样，只是iOS8-iOS10的推送到达的代理回调变为
```
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
completionHandler(UIBackgroundFetchResultNoData);
}
```

## 针对本地通知和远程推送的功能进行简单的封装
- 本地通知
```
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
```

- 远程推送
```
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
```
