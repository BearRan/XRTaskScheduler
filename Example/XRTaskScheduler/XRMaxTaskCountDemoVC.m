//
//  XRMaxTaskCountDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRMaxTaskCountDemoVC.h"

@interface XRMaxTaskCountDemoVC ()

@end

@implementation XRMaxTaskCountDemoVC

#pragma mark - 最大任务量测试
- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 10; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.schedulerType = XRTaskSchedulerTypeReverse;
    self.taskScheduler.concurrentCount = 2;
    self.taskScheduler.maxTaskCount = 3;
    [self.taskScheduler startExecute];
}

@end
