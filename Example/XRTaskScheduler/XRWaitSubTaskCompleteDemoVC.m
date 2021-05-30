//
//  XRWaitSubTaskCompleteDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/30.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRWaitSubTaskCompleteDemoVC.h"
#import "QiyuSDK.h"

@interface XRWaitSubTaskCompleteDemoVC ()

@end

@implementation XRWaitSubTaskCompleteDemoVC

- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 6; i++) {
        if (i == 3) {
            [self generateQiYuTask];
        } else {
            [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
        }
    }
    [self.taskScheduler startExecute];
}

- (void)generateQiYuTask {
    XRTask *task = [XRTask new];
    task.taskID = @"Qiyu";
    task.ifNeedCacheWhenSuccessed = YES;
    task.customData = @"allowNext";
    task.maxRetryCount = 3;
//    task.waitSuccessTaskFinish = YES;
    /// 添加block方法二
    task.taskBlock = ^(XRTask * _Nonnull task, XRSuccessBlock  _Nonnull successBlock, NSInteger retryCount) {
        [[QiyuSDK shareInstance] startInitialWithRespBlock:^(BOOL value) {
            if (successBlock) {
                successBlock(@(value));
            }
        }];
    };
    /// 配置解析是否success
    task.parseIsSuccess = ^BOOL(id  _Nonnull data) {
        if ([data boolValue] == YES) {
            return YES;
        }
        return NO;
    };
    [self.taskScheduler addTask:task];
    
    [self configSubTask:task];
}

/// 配置子任务
- (void)configSubTask:(XRTask *)mainTask {
    for (int i = 0; i < 2; i++) {
        [mainTask.successTaskScheduler addTask:[self generateTestSubTaskWithIndex:i]];
    }
}

@end
