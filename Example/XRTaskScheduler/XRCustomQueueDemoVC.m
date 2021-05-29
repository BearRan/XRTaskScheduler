//
//  XRCustomQueueDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRCustomQueueDemoVC.h"

@interface XRCustomQueueDemoVC ()

@end

@implementation XRCustomQueueDemoVC

#pragma mark - 指定队列测试
- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 4; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    dispatch_queue_t customQueue = dispatch_queue_create("com.bear.custom.queue", NULL);
    self.taskScheduler.getTaskQueueBlock = ^dispatch_queue_t _Nullable(NSInteger index) {
        return customQueue;
    };
    [self.taskScheduler startExecute];
}

@end
