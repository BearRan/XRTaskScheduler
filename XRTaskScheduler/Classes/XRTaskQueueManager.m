//
//  XRTaskQueueManager.m
//  XRTaskManager_Example
//
//  Created by Bear on 2021/5/28.
//  Copyright © 2021 Bear. All rights reserved.
//

#import "XRTaskQueueManager.h"
#import <libkern/OSAtomic.h>
#import <UIKit/UIKit.h>

static dispatch_queue_t XRAsyncLayerGetDisplayQueue() {
//最大队列数量
#define MAX_QUEUE_COUNT 16
//队列数量
    static int queueCount;
//使用栈区的数组存储队列
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
//串行队列数量和处理器数量相同
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
//创建串行队列，设置优先级
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.xiongran.xrtask", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.xiongran.xrtask", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
//轮询返回队列
    uint32_t cur = (uint32_t)OSAtomicIncrement32(&counter);
    return queues[cur % queueCount];
#undef MAX_QUEUE_COUNT
}

@interface XRTaskQueueManager()

@end

@implementation XRTaskQueueManager

+ (instancetype)shareInstance {
    static XRTaskQueueManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [XRTaskQueueManager new];
    });
    
    return sharedManager;
}

- (dispatch_queue_t)getQueue {
    return XRAsyncLayerGetDisplayQueue();
}

@end
