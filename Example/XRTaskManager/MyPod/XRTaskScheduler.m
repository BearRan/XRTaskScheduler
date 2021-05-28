//
//  XRTaskScheduler.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTaskScheduler.h"
#import "XRTaskSchedulerEnum.h"
#import <pthread.h>

@interface XRTaskScheduler()
{
    pthread_mutex_t _arrayLock;
    pthread_mutex_t _dictLock;
}

@property (nonatomic, assign) XRTaskSchedulerType schedulerType;
@property (nonatomic, strong) NSMutableArray <XRTask *> *taskArray;
@property (nonatomic, strong) NSMutableDictionary <NSString *, XRTask *> *taskCacheDict;

@end

@implementation XRTaskScheduler

/// 初始化
/// @param schedulerType 任务调度类型
- (instancetype)initWithSchedulerType:(XRTaskSchedulerType)schedulerType
{
    self = [super init];
    if (self) {
        self.schedulerType = schedulerType;
        
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
        pthread_mutex_init(&_arrayLock, &attr);
        pthread_mutex_init(&_dictLock, &attr);
        pthread_mutexattr_destroy(&attr);
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_arrayLock);
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
    
    switch (self.schedulerType) {
        case XRTaskSchedulerTypePriority:
        {
#warning Bear 这里加下排序的逻辑
            pthread_mutex_lock(&_arrayLock);
            [self.taskArray addObject:task];
            pthread_mutex_unlock(&_arrayLock);
        }
            break;
        case XRTaskSchedulerTypeSequence:
        case XRTaskSchedulerTypeReverse:
        {
            pthread_mutex_lock(&_arrayLock);
            [self.taskArray addObject:task];
            pthread_mutex_unlock(&_arrayLock);
        }
            break;
    }
}

- (void)removeTask:(XRTask * _Nullable)task {
    if (![self checkIsXRTask:task]) {
        return;
    }
    
    /// 因为字典和数组，最多只会有一处存有task。所以判断一次
    BOOL containInDict = NO;
    pthread_mutex_lock(&_dictLock);
    if ([self.taskCacheDict objectForKey:task.taskID]) {
        containInDict = YES;
        [self.taskCacheDict removeObjectForKey:task.taskID];
    }
    pthread_mutex_unlock(&_dictLock);
    
    if (!containInDict) {
        pthread_mutex_lock(&_arrayLock);
        [self.taskArray removeObject:task];
        pthread_mutex_unlock(&_arrayLock);
    }
}

- (void)removeTaskWithTaskID:(NSString * __nullable)taskID {
    __block NSUInteger resIndex = -1;
    pthread_mutex_lock(&_arrayLock);
    [self.taskArray enumerateObjectsUsingBlock:^(XRTask * _Nonnull tmpTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([tmpTask.taskID isEqualToString:taskID]) {
            resIndex = idx;
            *stop = YES;
        }
    }];
    if (resIndex >= 0) {
        [self.taskArray removeObjectAtIndex:resIndex];
    }
    pthread_mutex_unlock(&_arrayLock);
}

- (XRTask * _Nullable)getTaskWihtTaskID:(NSString * _Nullable)taskID {
    if (!taskID || taskID.length == 0) {
        return nil;
    }
    
    __block XRTask *resTask;
    pthread_mutex_lock(&_arrayLock);
    [self.taskArray enumerateObjectsUsingBlock:^(XRTask * _Nonnull tmpTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([tmpTask.taskID isEqualToString:taskID]) {
            resTask = tmpTask;
            *stop = YES;
        }
    }];
    pthread_mutex_unlock(&_arrayLock);
    return resTask;
}

- (void)clearTasks {
    pthread_mutex_lock(&_arrayLock);
    [self.taskArray removeAllObjects];
    pthread_mutex_unlock(&_arrayLock);
}

- (BOOL)taskIsEmpty {
    pthread_mutex_lock(&_arrayLock);
    BOOL emptyValue = self.taskArray.count == 0;
    pthread_mutex_unlock(&_arrayLock);
    
    return emptyValue;
}

- (void)startExecute {
    if ([self taskIsEmpty]) {
        return;
    }
    
    XRTask *task;
    switch (self.schedulerType) {
        case XRTaskSchedulerTypePriority:
        case XRTaskSchedulerTypeSequence:
        {
            pthread_mutex_lock(&_arrayLock);
            task = [self.taskArray lastObject];
            [self.taskArray removeLastObject];
            pthread_mutex_unlock(&_arrayLock);
            
            pthread_mutex_lock(&_dictLock);
            [self.taskCacheDict setObject:task forKey:task.taskID];
            pthread_mutex_unlock(&_dictLock);
        }
            break;
        case XRTaskSchedulerTypeReverse:
        {
            pthread_mutex_lock(&_arrayLock);
            task = [self.taskArray firstObject];
            [self.taskArray removeObjectAtIndex:0];
            pthread_mutex_unlock(&_arrayLock);
            
            pthread_mutex_lock(&_dictLock);
            [self.taskCacheDict setObject:task forKey:task.taskID];
            pthread_mutex_unlock(&_dictLock);
        }
            break;
    }
    
    if (task.taskBlock) {
        task.taskBlock();
    }
}

#pragma mark - Setter & Getter
- (NSMutableArray<XRTask *> *)taskArray {
    if (!_taskArray) {
        _taskArray = [NSMutableArray new];
    }

    return _taskArray;
}

- (NSMutableDictionary<NSString *,XRTask *> *)taskCacheDict {
    if (!_taskCacheDict) {
        _taskCacheDict = [NSMutableDictionary new];
    }
    
    return _taskCacheDict;
}

@end
