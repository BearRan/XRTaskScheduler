//
//  XRTaskRunLoopConfig.m
//  XRTaskManager_Example
//
//  Created by Bear on 2021/5/28.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRTaskRunLoopConfig.h"

@implementation XRTaskRunLoopConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.executeBaseRunLoop = NO;
    }
    return self;
}

@end
