//
//  ViewController.m
//  MZNotification
//
//  Created by 曾龙 on 2019/5/21.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import "ViewController.h"
#import "MZNotification/MZNotification.h"

@interface ViewController ()<MZNotificationDelegate>
@property (nonatomic, assign) NSInteger count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.count = 0;
    [[MZNotification shareInstance] setDelegate:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.count++;
    if (self.count == 1) {
        if (@available(iOS 10.0, *)) {
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
            [[MZNotification shareInstance] pushLocalNotificationWithBadge:2 sound:nil title:@"测试1" message:@"1111111111" params:@{@"tag":@"MZ11111111"} trigger:trigger identifier:@"test"];
        } else {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5];
            [[MZNotification shareInstance] pushLocalNotificationWithBadge:2 sound:nil title:@"测试1" message:@"1111111111" params:@{@"tag":@"MZ11111111"} fireDate:date repeatInterval:0 identifier:@"test"];
        }
    } else if (self.count == 2) {
        if (@available(iOS 10.0, *)) {
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
            [[MZNotification shareInstance] updateLocalNotificationWithBadge:2 sound:@"notification.caf" title:@"测试2" message:@"222222222222" params:@{@"tag":@"MZ22222222"} trigger:trigger identifier:@"test"];
        } else {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5];
            [[MZNotification shareInstance] updateLocalNotificationWithBadge:2 sound:@"notification.caf" title:@"测试2" message:@"222222222222" params:@{@"tag":@"MZ22222222"} fireDate:date repeatInterval:0 identifier:@"test"];
        }
    } else if (self.count == 3) {
        [[MZNotification shareInstance] cancelAllLocalNotification];
    }
}

#pragma mark -MZNotificationDelegate
- (void)mz_didReceiveNotificationOnApplicationBackgroundWithUserInfo:(NSDictionary *)userInfo {
    NSLog(@"ApplicationBackgroundWithUserInfo:%@",userInfo.description);
}

- (void)mz_didReceiveNotificationOnApplicationActiveWithUserInfo:(NSDictionary *)userInfo {
    NSLog(@"ApplicationActiveWithUserInfo:%@",userInfo.description);
}


@end
