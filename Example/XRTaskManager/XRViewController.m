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
	
    [self addTestTaskWithIndex:0];
    [self addTestTaskWithIndex:1];
    [self addTestTaskWithIndex:2];
    [self.taskScheduler startExecute];
}

- (void)addTestTaskWithIndex:(NSInteger)index {
    XRTask *task = [XRTask new];
    task.taskBlock = ^{
        NSLog(@"---start%ld", (long)index);
        [NSThread sleepForTimeInterval:2.0f];
        NSLog(@"---finish%ld", (long)index);
    };
    [self.taskScheduler addTask:task];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (XRTaskScheduler *)taskScheduler {
    if (!_taskScheduler) {
        _taskScheduler = [XRTaskScheduler new];
    }
    return _taskScheduler;
}

@end
