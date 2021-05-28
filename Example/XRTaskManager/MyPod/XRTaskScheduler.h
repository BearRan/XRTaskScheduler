//
//  XRTaskScheduler.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import "XRTask.h"
#import "XRTaskRunLoopConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface XRTaskScheduler : NSObject

/// 任务执行顺序
@property (nonatomic, assign) XRTaskSchedulerType schedulerType;
/**
 * runloop配置
 * （是否依据住线程的runloop执行任务）
 */
@property (nonatomic, strong) XRTaskRunLoopConfig *runloopConfig;
/// 最大任务量（默认：-1，表示不限数量。调度策略为XRTaskSchedulerTypePriority时无效）
@property (nonatomic, assign) NSInteger maxTaskCount;
/// 任务并行数量（默认：1）
@property (nonatomic, assign) NSInteger concurrentCount;

- (instancetype)initWithSchedulerType:(XRTaskSchedulerType)schedulerType;

- (void)addTask:(XRTask * __nullable)task;
- (void)removeTask:(XRTask * __nullable)task;
/// 如果总task数量不是非常大的情况下可以使用，不然查询效率会很低
- (void)removeTaskWithTaskID:(NSString * __nullable)taskID;
/// 如果总task数量不是非常大的情况下可以使用，不然查询效率会很低
- (XRTask * __nullable)getTaskWihtTaskID:(NSString * __nullable)taskID;
- (void)clearTasks;
- (BOOL)taskIsEmpty;
- (void)startExecute;

@end

NS_ASSUME_NONNULL_END
