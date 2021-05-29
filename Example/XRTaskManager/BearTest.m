//
//  BearTest.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "BearTest.h"
#import "QiyuSDK.h"
#import "XRTaskScheduler.h"

@interface BearTest()

@property (nonatomic, strong) XRTaskScheduler *taskScheduler;

@end

@implementation BearTest

- (void)registerSDK {
    XRTask *task = [XRTask new];
    task.taskID = @"Qiyu";
    task.ifNeedCacheWhenCompleted = YES;
    task.taskSchedulerWhenCompleted.maxTaskCount = 1;
    /// 添加block方法一
    task.taskBlock = ^(XRTask * _Nonnull task) {
        BOOL resValue = [[QiyuSDK shareInstance] startInitial];
        if (task.completeBlock) {
            task.completeBlock(@(resValue));
        }
    };
    /// 添加block方法二
    task.taskBlock = ^(XRTask * _Nonnull task) {
        [[QiyuSDK shareInstance] startInitialWithRespBlock:^(BOOL value) {
            if (task.completeBlock) {
                task.completeBlock(@(value));
            }
        }];
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

- (void)jumpChatRoom {
    XRTask *task = [self.taskScheduler getTaskWihtTaskID:@"Qiyu"];
    BOOL checkIsFinish = task.parseIsComplete(task.responseData);
    if (checkIsFinish) {
        /// hud.....
    }
    [task tryToExecuteCompletedTaskBlock:^(XRTask * _Nonnull task) {
        [[QiyuSDK shareInstance] pushToChatRoom];
    }];
}

#pragma Setter & Getter
- (XRTaskScheduler *)taskScheduler {
    if (!_taskScheduler) {
        _taskScheduler = [[XRTaskScheduler alloc] initWithSchedulerType:XRTaskSchedulerTypeSequence];
    }
    
    return _taskScheduler;
}

@end
