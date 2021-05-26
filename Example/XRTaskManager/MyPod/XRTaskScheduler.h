//
//  XRTaskScheduler.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import "XRTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface XRTaskScheduler : NSObject

/// 基于RunLoop执行
@property (nonatomic, assign) BOOL executeBaseRunLoop;
/// 最大任务量（调度策略为XRTaskSchedulerTypePriority时无效）
@property (nonatomic, assign) NSInteger maxTaskCount;

- (instancetype)initWithSchedulerType:(XRTaskSchedulerType)schedulerType;

- (void)addTask:(XRTask *)task;
- (void)removeTask:(XRTask *)task;
- (XRTask *)getTaskWihtTaskID:(NSString *)taskID;
- (void)removeTaskWithTaskID:(NSString *)taskID;
- (void)clearTasks;
- (BOOL)taskIsEmpty;
- (void)startExecute;

@end

NS_ASSUME_NONNULL_END
