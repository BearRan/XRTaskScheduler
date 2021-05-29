//
//  XRProcessCompleteDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRProcessCompleteDemoVC.h"
#import "QiyuSDK.h"

@interface XRProcessCompleteDemoVC ()

@end

@implementation XRProcessCompleteDemoVC

- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 6; i++) {
        if (i == 3) {
            [self generateQiYuTask];
        } else {
            [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
        }
    }
    dispatch_queue_t customQueue = dispatch_queue_create("com.bear.custom.queue", NULL);
    self.taskScheduler.taskQueueBlock = ^dispatch_queue_t _Nullable(NSInteger index) {
        return customQueue;
    };
    [self.taskScheduler startExecute];
    
    
}

- (void)generateQiYuTask {
    XRTask *task = [XRTask new];
    task.taskID = @"Qiyu";
    task.ifNeedCacheWhenCompleted = YES;
    task.taskSchedulerWhenCompleted.maxTaskCount = 1;
//    task.customData = @"allowNext";
    /// 添加block方法一
//    task.taskBlock = ^(XRTask * _Nonnull task) {
//        BOOL resValue = [[QiyuSDK shareInstance] startInitial];
//        if (task.completeBlock) {
//            task.completeBlock(@(resValue));
//        }
//        if ([(NSString *)task.customData isEqualToString:@"allowNext"]) {
//            task.allowExecuteNext = YES;
//        } else {
//            task.allowExecuteNext = NO;
//        }
//    };
    /// 添加block方法二
    task.taskBlock = ^(XRTask * _Nonnull task) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [[QiyuSDK shareInstance] startInitialWithRespBlock:^(BOOL value) {
            if ([(NSString *)task.customData isEqualToString:@"allowNext"]) {
                task.allowExecuteNext = YES;
            } else {
                task.allowExecuteNext = NO;
            }
            if (task.completeBlock) {
                task.completeBlock(@(value));
            }
            
            dispatch_semaphore_signal(semaphore);
            
            [self delayResumeTask];
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    };
    /// 配置解析是否finish
    task.parseIsComplete = ^BOOL(id  _Nonnull data) {
        if ([data boolValue] == YES) {
            return YES;
        }
        return NO;
    };
    [self.taskScheduler addTask:task];
}

- (void)delayResumeTask {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.taskScheduler resumeExecute];
    });
}

@end
