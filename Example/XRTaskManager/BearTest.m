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
    __weak typeof(task) weakTask = task;
    /// 添加block方法一
    task.taskBlock = ^{
        BOOL resValue = [[QiyuSDK shareInstance] startInitial];
        if (weakTask.taskCompleteBlock) {
            weakTask.taskCompleteBlock(@(resValue));
        }
    };
    /// 添加block方法二
    task.taskBlock = ^{
        [[QiyuSDK shareInstance] startInitialWithRespBlock:^(BOOL value) {
            if (weakTask.taskCompleteBlock) {
                weakTask.taskCompleteBlock(@(value));
            }
        }];
    };
    /// 配置解析是否finish
    task.analysisIsCompleteBlock = ^BOOL(id  _Nonnull data) {
        if ([data boolValue] == YES) {
            return YES;
        }
        return NO;
    };
    [self.taskScheduler addTask:task];
}

- (void)jumpChatRoom {
    XRTask *task = [self.taskScheduler getTaskWihtTaskID:@"Qiyu"];
    BOOL checkIsFinish = task.analysisIsCompleteBlock(task.responseData);
    if (checkIsFinish) {
        /// hud.....
    }
    [task tryToExecuteNextStep:^{
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
