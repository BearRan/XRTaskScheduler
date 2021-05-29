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
    
    /// 并发测试
//    [self testConcurrent];
    
    /// 最大任务量测试
    [self testMaxTaskCount];
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

#pragma mark - 并发测试
- (void)testConcurrent {
    for (int i = 0; i < 16; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.concurrentCount = 5;
    [self.taskScheduler startExecute];
}

#pragma mark - 最大任务量测试
- (void)testMaxTaskCount {
    for (int i = 0; i < 10; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    self.taskScheduler.schedulerType = XRTaskSchedulerTypeReverse;
    self.taskScheduler.maxTaskCount = 3;
    [self.taskScheduler startExecute];
}


- (XRTask *)generateTestTaskWithIndex:(NSInteger)index {
    XRTask *task = [XRTask new];
    task.customData = [NSString stringWithFormat:@"task-%ld", (long)index];
    task.taskBlock = ^{
        NSLog(@"---start%ld", (long)index);
        [NSThread sleepForTimeInterval:2.0f];
        NSLog(@"---finish%ld", (long)index);
    };
    
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
