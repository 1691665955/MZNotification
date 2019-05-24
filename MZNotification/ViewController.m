//
//  ViewController.m
//  MZNotification
//
//  Created by 曾龙 on 2019/5/21.
//  Copyright © 2019 com.mz. All rights reserved.
//

#import "ViewController.h"
#import "MZNotification/MZNotification.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pushLocalNotification:(id)sender {
    if (@available(iOS 10.0, *)) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
        [[MZLocalNotification shareInstance] pushLocalNotificationWithBadge:2 sound:@"notification.caf" title:@"测试1" message:@"1111111111" params:@{@"tag":@"MZ11111111"} trigger:trigger identifier:@"test"];
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5];
        [[MZLocalNotification shareInstance] pushLocalNotificationWithBadge:2 sound:@"notification.caf" title:@"测试1" message:@"1111111111" params:@{@"tag":@"MZ11111111"} fireDate:date repeatInterval:0 identifier:@"test"];
    }
}

@end
