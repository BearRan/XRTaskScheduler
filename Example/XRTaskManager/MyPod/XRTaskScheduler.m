//
//  XRTaskScheduler.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTaskScheduler.h"
#import "XRTaskSchedulerEnum.h"
#import "XRTaskSchedulerProtocol.h"
#import "XRTaskPriorityQueue.h"
#import "XRTaskOrderQueue.h"
#import "XRTask.h"

@interface XRTaskScheduler()

@property (nonatomic, assign) XRTaskSchedulerType schedulerType;
@property (nonatomic, strong) id <XRTaskSchedulerProtocol> taskQueue;

@end

@implementation XRTaskScheduler

/// 初始化
/// @param schedulerType 任务调度类型
- (instancetype)initWithSchedulerType:(XRTaskSchedulerType)schedulerType
{
    self = [super init];
    if (self) {
        self.schedulerType = schedulerType;
    }
    return self;
}

- (void)addTask:(XRTask *)task {
    [self.taskQueue addTask:task];
}

- (void)removeTask:(XRTask *)task {
    [self.taskQueue removeTask:task];
}

- (XRTask *)getTaskWihtTaskID:(NSString *)taskID {
    return [self.taskQueue getTaskWihtTaskID:taskID];
}

- (void)removeTaskWithTaskID:(NSString *)taskID {
    [self.taskQueue removeTaskWithTaskID:taskID];
}

- (void)clearTasks {
    [self.taskQueue clearTasks];
}

- (BOOL)taskIsEmpty {
    return [self.taskQueue taskIsEmpty];
}

- (void)startExecute {
    [self.taskQueue startExecute];
}


#pragma Setter & Getter
- (id<XRTaskSchedulerProtocol>)taskQueue {
    if (!_taskQueue) {
        switch (self.schedulerType) {
            case XRTaskSchedulerTypeSequence:
            {
                _taskQueue = [[XRTaskOrderQueue alloc] initWithReverse:NO];
            }
                break;
            case XRTaskSchedulerTypeReverse:
            {
                _taskQueue = [[XRTaskOrderQueue alloc] initWithReverse:YES];
            }
                break;
            case XRTaskSchedulerTypePriority:
            {
                _taskQueue = [XRTaskPriorityQueue new];
            }
                break;
        }
    }
    
    return _taskQueue;
}

@end