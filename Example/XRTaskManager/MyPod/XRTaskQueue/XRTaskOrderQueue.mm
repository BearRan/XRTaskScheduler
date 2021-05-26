//
//  XRTaskOrderQueue.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTaskOrderQueue.h"
#import <pthread.h>
#include <deque>

@interface XRTaskOrderQueue()

@property (nonatomic, strong) NSMutableArray <XRTask *> *taskArray;

@end

@implementation XRTaskOrderQueue

/// 初始化
/// @param reverse 是否倒序
- (instancetype)initWithReverse:(BOOL)reverse
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//- (BOOL)checkIsXRTask:(XRTask *)task {
//
//}

#pragma XRTaskSchedulerProtocol
//- (void)clearTasks {
//    <#code#>
//}
//
//
//- (XRTask * _Nullable)getTaskWihtTaskID:(NSString * _Nullable)taskID {
//    <#code#>
//}
//
//
//- (void)removeTask:(XRTask * _Nullable)task {
//    <#code#>
//}
//
//
//- (void)removeTaskWithTaskID:(NSString * _Nullable)taskID {
//    <#code#>
//}
//
//
//- (void)startExecute {
//    <#code#>
//}
//
//
//- (BOOL)taskIsEmpty {
//    <#code#>
//}


#pragma Setter & Getter
- (NSMutableArray<XRTask *> *)taskArray {
    if (!_taskArray) {
        _taskArray = [NSMutableArray new];
    }
    
    return _taskArray;
}

@end
