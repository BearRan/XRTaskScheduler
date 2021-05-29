//
//  XRPriorityDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRPriorityDemoVC.h"

@interface XRPriorityDemoVC ()

@end

@implementation XRPriorityDemoVC

#pragma mark - 优先级测试
- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 17; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.schedulerType = XRTaskSchedulerTypePriority;
    [self.taskScheduler startExecute];
}

@end
