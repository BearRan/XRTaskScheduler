//
//  XRConcurrentDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRConcurrentDemoVC.h"

@interface XRConcurrentDemoVC ()

@end

@implementation XRConcurrentDemoVC

#pragma mark - 并发测试
- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 16; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.concurrentCount = 5;
    [self.taskScheduler startExecute];
}

@end
