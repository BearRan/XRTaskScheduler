//
//  XRTaskPriorityQueue.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTaskPriorityQueue.h"
#import <pthread.h>

@interface XRTaskPriorityQueue()
{
    pthread_mutex_t _lock;
}

@property (nonatomic, strong) NSMutableArray <XRTask *> *taskArray;

@end

@implementation XRTaskPriorityQueue

/// 初始化
/// @param reverse 是否倒序
- (instancetype)init
{
    self = [super init];
    if (self) {
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

//- (void)addTask:(XRTask * _Nullable)task { 
//    <#code#>
//}
//
//- (void)clearTasks { 
//    <#code#>
//}
//
//- (XRTask * _Nullable)getTaskWihtTaskID:(NSString * _Nullable)taskID { 
//    <#code#>
//}
//
//- (void)removeTask:(XRTask * _Nullable)task { 
//    <#code#>
//}
//
//- (void)removeTaskWithTaskID:(NSString * _Nullable)taskID { 
//    <#code#>
//}
//
//- (void)startExecute { 
//    <#code#>
//}
//
//- (BOOL)taskIsEmpty { 
//    <#code#>
//}

@end
