//
//  XRTaskOrderQueue.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTaskOrderQueue.h"
#import <pthread.h>

@interface XRTaskOrderQueue()
{
    pthread_mutex_t _lock;
}

@property (nonatomic, strong) NSMutableArray <XRTask *> *taskArray;
@property (nonatomic, assign) BOOL reverse;

@end

@implementation XRTaskOrderQueue

/// 初始化
/// @param reverse 是否倒序
- (instancetype)initWithReverse:(BOOL)reverse
{
    self = [super init];
    if (self) {
        self.reverse = reverse;
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
        pthread_mutex_init(&_lock, &attr);
        pthread_mutexattr_destroy(&attr);
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
}

- (BOOL)checkIsXRTask:(XRTask * __nullable)task {
    if (task && [task isKindOfClass:[XRTask class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - XRTaskSchedulerProtocol
- (void)addTask:(XRTask * __nullable)task {
    if (![self checkIsXRTask:task]) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    [self.taskArray addObject:task];
    pthread_mutex_unlock(&_lock);
}

- (void)removeTask:(XRTask * _Nullable)task {
    if (![self checkIsXRTask:task]) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    [self.taskArray removeObject:task];
    pthread_mutex_unlock(&_lock);
}

- (void)removeTaskWithTaskID:(NSString * __nullable)taskID {
    __block NSUInteger resIndex = -1;
    pthread_mutex_lock(&_lock);
    [self.taskArray enumerateObjectsUsingBlock:^(XRTask * _Nonnull tmpTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([tmpTask.taskID isEqualToString:taskID]) {
            resIndex = idx;
            *stop = YES;
        }
    }];
    if (resIndex >= 0) {
        [self.taskArray removeObjectAtIndex:resIndex];
    }
    pthread_mutex_unlock(&_lock);
}

- (XRTask * _Nullable)getTaskWihtTaskID:(NSString * _Nullable)taskID {
    if (!taskID || taskID.length == 0) {
        return nil;
    }
    
    __block XRTask *resTask;
    pthread_mutex_lock(&_lock);
    [self.taskArray enumerateObjectsUsingBlock:^(XRTask * _Nonnull tmpTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([tmpTask.taskID isEqualToString:taskID]) {
            resTask = tmpTask;
            *stop = YES;
        }
    }];
    pthread_mutex_unlock(&_lock);
    return resTask;
}

- (void)clearTasks {
    pthread_mutex_lock(&_lock);
    [self.taskArray removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (BOOL)taskIsEmpty {
    return self.taskArray.count == 0;
}

- (void)startExecute {
    pthread_mutex_lock(&_lock);
    if ([self taskIsEmpty]) {
        pthread_mutex_unlock(&_lock);
        return;
    }
    
    XRTask *task;
    if (!self.reverse) {
        task = [self.taskArray firstObject];
        [self.taskArray removeObjectAtIndex:0];
    } else {
        task = [self.taskArray lastObject];
        [self.taskArray removeLastObject];
    }
    if (task.taskBlock) {
        task.taskBlock();
    }
    pthread_mutex_unlock(&_lock);
}

#pragma mark - Setter & Getter
- (NSMutableArray<XRTask *> *)taskArray {
    if (!_taskArray) {
        _taskArray = [NSMutableArray new];
    }

    return _taskArray;
}

@end
