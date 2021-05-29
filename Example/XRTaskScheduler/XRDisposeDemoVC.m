//
//  XRDisposeDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRDisposeDemoVC.h"

@interface XRDisposeDemoVC ()

@end

@implementation XRDisposeDemoVC

#pragma mark - 生命周期测试
- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 4; i++) {
        XRTask *task = [self generateTestTaskWithIndex:i];
        [self.taskScheduler addTask:task];
        
        if (i == 2) {
            NSObject *obj = [NSObject new];
            [task disposeBy:obj];
        }
    }
    [self.taskScheduler startExecute];
}

@end
