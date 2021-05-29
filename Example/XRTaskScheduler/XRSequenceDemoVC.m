//
//  XRSequenceDemoVC.m
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRSequenceDemoVC.h"

@interface XRSequenceDemoVC ()

@end

@implementation XRSequenceDemoVC

- (void)startTest {
    [super startTest];
    
    for (int i = 0; i < 3; i++) {
        [self.taskScheduler addTask:[self generateTestTaskWithIndex:i]];
    }
    [self.taskScheduler startExecute];
}

@end
