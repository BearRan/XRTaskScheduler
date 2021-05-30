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
    [self.taskScheduler startExecute];
    
    
}

- (void)generateQiYuTask {
    XRTask *task = [XRTask new];
    task.taskID = @"Qiyu";
    task.ifNeedCacheWhenSuccessed = YES;
    task.subTaskScheduler.maxTaskCount = 1;
    task.customData = @"allowNext";
    task.maxRetryCount = 3;
    /// 添加block方法一
    task.taskBlock = ^(XRTask * _Nonnull task, XRResponseBlock  _Nonnull responseBlock, NSInteger retryCount) {
        BOOL resValue = [[QiyuSDK shareInstance] startInitial];
        if (responseBlock) {
            responseBlock(@(resValue));
        }
    };
    /// 添加block方法二
//    task.taskBlock = ^(XRTask * _Nonnull task, XRResponseBlock  _Nonnull responseBlock, NSInteger retryCount) {
//        [[QiyuSDK shareInstance] startInitialWithRespBlock:^(BOOL value) {
//            if (responseBlock) {
//                responseBlock(@(value));
//            }
//
////            [self delayResumeTask];
//        }];
//    };
    /// 配置解析是否success
    task.parseIsSuccess = ^BOOL(id  _Nonnull data) {
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
