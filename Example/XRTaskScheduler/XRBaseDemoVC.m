//
//  XRBaseDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRBaseDemoVC.h"

@interface XRBaseDemoVC ()

@end

@implementation XRBaseDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self startTest];
}

- (void)dealloc
{
    [self.taskScheduler stopAndClearTasks];
}

- (void)startTest {}

- (XRTask *)generateTestTaskWithIndex:(NSInteger)index {
    XRTask *task = [XRTask new];
    task.customData = [NSString stringWithFormat:@"task-%ld", (long)index];
    task.taskBlock = ^(XRTask * _Nonnull task) {
        NSLog(@"---task start:%ld thread:%@", (long)index, [NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0f];
        NSLog(@"---task finish:%ld", (long)index);
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
