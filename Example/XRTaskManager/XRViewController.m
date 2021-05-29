//
//  XRViewController.m
//  XRTaskManager
//
//  Created by Bear on 05/26/2021.
//  Copyright (c) 2021 Bear. All rights reserved.
//

#import "XRViewController.h"
#import "XRTaskScheduler.h"

@interface XRViewController ()

@property (nonatomic, strong) XRTaskScheduler *taskScheduler;

@end

@implementation XRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    /// 正序测试
//    [self testSequence];
    
    /// 倒序测试
//    [self testReverse];
    
    /// 优先级测试
//    [self testPriority];
    
    /// 并发测试
//    [self testConcurrent];
    
    /// 最大任务量测试
//    [self testMaxTaskCount];
    
    /// 指定队列测试
    [self testCustomQueue];
}

#pragma mark - 正序测试
- (void)testSequence {
    for (int i = 0; i < 3; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    [self.taskScheduler startExecute];
}

#pragma mark - 倒序测试
- (void)testReverse {
    for (int i = 0; i < 3; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.schedulerType = XRTaskSchedulerTypeReverse;
    [self.taskScheduler startExecute];
}

#pragma mark - 优先级测试
- (void)testPriority {
    for (int i = 0; i < 17; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.schedulerType = XRTaskSchedulerTypePriority;
    [self.taskScheduler startExecute];
}

#pragma mark - 并发测试
- (void)testConcurrent {
    for (int i = 0; i < 16; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.concurrentCount = 5;
    [self.taskScheduler startExecute];
}

#pragma mark - 指定队列测试
- (void)testCustomQueue {
    for (int i = 0; i < 4; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    dispatch_queue_t customQueue = dispatch_queue_create("com.bear.custom.queue", NULL);
    self.taskScheduler.taskQueueBlock = ^dispatch_queue_t _Nullable(NSInteger index) {
        return customQueue;
    };
    [self.taskScheduler startExecute];
}

#pragma mark - 最大任务量测试
- (void)testMaxTaskCount {
    for (int i = 0; i < 10; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.schedulerType = XRTaskSchedulerTypeReverse;
    self.taskScheduler.concurrentCount = 2;
    self.taskScheduler.maxTaskCount = 3;
    [self.taskScheduler startExecute];
}


- (XRTask *)generateTestTaskWithIndex:(NSInteger)index {
    XRTask *task = [XRTask new];
    task.customData = [NSString stringWithFormat:@"task-%ld", (long)index];
    task.taskBlock = ^(XRTask * _Nonnull task) {
        NSLog(@"---start%ld thread:%@", (long)index, [NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0f];
        NSLog(@"---finish%ld", (long)index);
    };
    task.priority = arc4random() % 1000;
    
    return task;
}

#pragma mark - Setter & Getter
- (XRTaskScheduler *)taskScheduler {
    if (!_taskScheduler) {
        _taskScheduler = [XRTaskScheduler new];
    }
    return _taskScheduler;
}

@end
