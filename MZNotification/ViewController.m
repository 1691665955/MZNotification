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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MZNotification shareInstance] setDelegate:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (@available(iOS 10.0, *)) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
        [[MZNotification shareInstance] pushLocalNotificationWithBadge:2 sound:nil title:@"测试" message:@"测试测试测试测试测试测试" params:@{@"name":@"MZ",@"age":@"25"} trigger:trigger];
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5];
        [[MZNotification shareInstance] pushLocalNotificationWithBadge:2 sound:nil title:@"测试" message:@"测试测试测试测试测试测试" params:@{@"name":@"MZ",@"age":@"25"} fireDate:date repeatInterval:0];
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
