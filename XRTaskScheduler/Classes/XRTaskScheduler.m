//
//  XRTaskScheduler.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTaskScheduler.h"
#import "XRTaskSchedulerEnum.h"
#import <pthread.h>
#import "XRTaskQueueManager.h"

typedef NS_ENUM(NSInteger, XRSchedulerStatus) {
    /// 空
    XRSchedulerStatusIdle,
    /// 尝试执行
    XRSchedulerStatusTryExecute,
    /// 执行中
    XRSchedulerStatusExecuting,
    /// 暂停
    XRSchedulerStatusPause,
    /// 停止
    XRSchedulerStatusStop,
};

@interface XRTaskScheduler()
{
    pthread_mutex_t _arrayLock;
    pthread_mutex_t _dictLock;
    pthread_mutex_t _statusLock;
}

@property (nonatomic, strong) NSMutableArray <XRTask *> *taskArray;
@property (nonatomic, strong) NSMutableDictionary <NSString *, XRTask *> *taskCacheDict;
@property (nonatomic, assign) XRSchedulerStatus schedulerStatus;
/// 在执行前，是否需要排序
@property (nonatomic, assign) BOOL ifNeedOrder;

@end

@implementation XRTaskScheduler

+ (instancetype)shareInstance {
    static XRTaskScheduler *sharedScheduler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedScheduler = [XRTaskScheduler new];
    });
    
    return sharedScheduler;
}

- (instancetype)init
{
    return [self initWithSchedulerType:XRTaskSchedulerTypeSequence];
}

/// 初始化
/// @param schedulerType 任务调度类型
- (instancetype)initWithSchedulerType:(XRTaskSchedulerType)schedulerType
{
    self = [super init];
    if (self) {
        self.schedulerType = schedulerType;
        self.maxTaskCount = -1;
        self.concurrentCount = 1;
        self.taskQueueBlock = nil;
        self.schedulerStatus = XRSchedulerStatusIdle;
        self.ifNeedOrder = YES;
        
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
        pthread_mutex_init(&_arrayLock, &attr);
        pthread_mutex_init(&_dictLock, &attr);
        pthread_mutex_init(&_statusLock, &attr);
        pthread_mutexattr_destroy(&attr);
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_arrayLock);
    pthread_mutex_destroy(&_dictLock);
    pthread_mutex_destroy(&_statusLock);
}

- (BOOL)checkIsXRTask:(XRTask * __nullable)task {
    if (task && [task isKindOfClass:[XRTask class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - Private
/// 删除最久远的那个
- (void)removeRemoteOne {
    switch (self.schedulerType) {
        case XRTaskSchedulerTypePriority:
        case XRTaskSchedulerTypeSequence:
        {
            pthread_mutex_lock(&_arrayLock);
            [self.taskArray removeObjectAtIndex:0];
            pthread_mutex_unlock(&_arrayLock);
        }
            break;
        case XRTaskSchedulerTypeReverse:
        {
            pthread_mutex_lock(&_arrayLock);
            [self.taskArray removeLastObject];
            pthread_mutex_unlock(&_arrayLock);
        }
            break;
    }
}

/// 执行下一个
- (void)executeNext {
    if ([self taskIsEmpty]) {
        return;
    }
    
    XRTask *task;
    switch (self.schedulerType) {
        case XRTaskSchedulerTypePriority:
        case XRTaskSchedulerTypeSequence:
        {
            pthread_mutex_lock(&_arrayLock);
            task = [self.taskArray firstObject];
            [self.taskArray removeObjectAtIndex:0];
            pthread_mutex_unlock(&_arrayLock);
        }
            break;
        case XRTaskSchedulerTypeReverse:
        {
            pthread_mutex_lock(&_arrayLock);
            task = [self.taskArray lastObject];
            [self.taskArray removeLastObject];
            pthread_mutex_unlock(&_arrayLock);
        }
            break;
    }
    
    if (task.ifNeedCacheWhenCompleted) {
        pthread_mutex_lock(&_dictLock);
        [self.taskCacheDict setObject:task forKey:task.taskID];
        pthread_mutex_unlock(&_dictLock);
    }
    
    [task executeTask];
}

#pragma mark tryExecute
- (void)tryExecute {
    if ([self taskIsEmpty]) {
        return;
    }
    
    if (self.schedulerStatus == XRSchedulerStatusTryExecute) {
        self.schedulerStatus = XRSchedulerStatusExecuting;
    } else {
        return;
    }
    
    /// 在执行前，统一处理排序
    /// 优先级模式，并且需要排序
    if (self.schedulerType == XRTaskSchedulerTypePriority && self.ifNeedOrder == YES) {
        self.ifNeedOrder = NO;
//        [self logPriority:NO];
        /// 排序
        [self processOrder];
//        [self logPriority:YES];
    }
    
    for (int i = 0; i < self.concurrentCount; i++) {
        dispatch_queue_t queue;
        if (self.taskQueueBlock) {
            queue = self.taskQueueBlock(i);
        } else {        
            queue = [[XRTaskQueueManager shareInstance] getQueue];
        }
        dispatch_async(queue, ^{
            while (![self taskIsEmpty] && self.schedulerStatus == XRSchedulerStatusExecuting) {
                [self executeNext];
            }
            
            // 走到这里，说明任务执行完了，而不是被停止了。
            // 所以状态需要重制为TryExecute，方便有任务添加过来时，可以再次执行该防范。
            if ([self taskIsEmpty] && self.schedulerStatus == XRSchedulerStatusExecuting) {
                self.schedulerStatus = XRSchedulerStatusTryExecute;
            }
        });
    }
}

#pragma mark Order
- (void)processOrder {
    /// 降序
    NSSortDescriptor *priorityDesc = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    NSSortDescriptor *dataDesc = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES];
    NSArray *tmpArray = [self.taskArray sortedArrayUsingDescriptors:@[priorityDesc, dataDesc]];
    
    pthread_mutex_lock(&_arrayLock);
    [self.taskArray removeAllObjects];
    [self.taskArray addObjectsFromArray:tmpArray];
    pthread_mutex_unlock(&_arrayLock);
}

- (void)logPriority:(BOOL)isOrder {
    NSLog(@"--start show logPriority isOrder:%@", isOrder ? @"yes" : @"no");
    for (XRTask *task in self.taskArray) {
        NSLog(@"--task priority:%ld", (long)task.priority);
    }
    NSLog(@"--finish show logPriority isOrder:%@", isOrder ? @"yes" : @"no");
}

#pragma mark - Public
- (void)addTask:(XRTask * __nullable)task {
    if (![self checkIsXRTask:task]) {
        return;
    }
    
    if (self.maxTaskCount >= 0) {
        /// 这里多删一个
        while ([self taskCount] >= self.maxTaskCount) {
            [self removeRemoteOne];
        }
    }
    
    switch (self.schedulerType) {
        case XRTaskSchedulerTypePriority:
        {
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
    
    /// 优先级模式
    if (self.schedulerType == XRTaskSchedulerTypePriority) {
        self.ifNeedOrder = YES;
    }
    [self tryExecute];
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

- (BOOL)taskIsEmpty {
    pthread_mutex_lock(&_arrayLock);
    BOOL emptyValue = self.taskArray.count == 0;
    pthread_mutex_unlock(&_arrayLock);
    
    return emptyValue;
}

- (NSUInteger)taskCount {
    pthread_mutex_lock(&_arrayLock);
    NSUInteger count = self.taskArray.count;
    pthread_mutex_unlock(&_arrayLock);
    
    return count;
}

- (void)startExecute {
    if (self.schedulerStatus == XRSchedulerStatusExecuting) {
        return;
    }
    
    self.schedulerStatus = XRSchedulerStatusTryExecute;
    
    [self tryExecute];
}

- (void)pauseExecute {
    self.schedulerStatus = XRSchedulerStatusPause;
}

- (void)resumeExecute {
    if (self.schedulerStatus == XRSchedulerStatusExecuting) {
        return;
    }
    
    self.schedulerStatus = XRSchedulerStatusTryExecute;
    
    [self tryExecute];
}

- (void)stopAndClearTasks {
    pthread_mutex_lock(&_statusLock);
    self.schedulerStatus = XRSchedulerStatusPause;
    pthread_mutex_unlock(&_statusLock);
    
    pthread_mutex_lock(&_arrayLock);
    [self.taskArray removeAllObjects];
    pthread_mutex_unlock(&_arrayLock);
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

@synthesize schedulerStatus = _schedulerStatus;
- (void)setSchedulerStatus:(XRSchedulerStatus)schedulerStatus {
    pthread_mutex_lock(&_statusLock);
    _schedulerStatus = schedulerStatus;
    pthread_mutex_unlock(&_statusLock);
}

- (XRSchedulerStatus)schedulerStatus {
    pthread_mutex_lock(&_statusLock);
    XRSchedulerStatus tmpStatus = _schedulerStatus;
    pthread_mutex_unlock(&_statusLock);
    
    return tmpStatus;
}

- (void)setMaxTaskCount:(NSInteger)maxTaskCount {
    _maxTaskCount = maxTaskCount;
    
    if (maxTaskCount >= 0) {
        /// 这里不用多删一个
        while ([self taskCount] > maxTaskCount) {
            [self removeRemoteOne];
        }
    }
}

@end
