//
//  XRTaskScheduler.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import "XRTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef dispatch_queue_t _Nullable (^XRTaskQueueBlock)(NSInteger index);

@interface XRTaskScheduler : NSObject

/// 任务执行顺序
@property (nonatomic, assign) XRTaskSchedulerType schedulerType;
/// 最大任务量（默认：-1，表示不限数量。调度策略为XRTaskSchedulerTypePriority时无效）
@property (nonatomic, assign) NSInteger maxTaskCount;
/// 任务并行数量（默认：1）
@property (nonatomic, assign) NSInteger concurrentCount;
/// 自定义执行任务所在的队列（默认：nil）
@property (nonatomic, copy) XRTaskQueueBlock taskQueueBlock;

+ (instancetype)shareInstance;
- (instancetype)initWithSchedulerType:(XRTaskSchedulerType)schedulerType;

#pragma mark - 添加/移除/获取任务相关
- (void)addTask:(XRTask * __nullable)task;
- (void)removeTask:(XRTask * __nullable)task;
/// 如果总task数量不是非常大的情况下可以使用，不然查询效率会很低
- (void)removeTaskWithTaskID:(NSString * __nullable)taskID;
/// 如果总task数量不是非常大的情况下可以使用，不然查询效率会很低
- (XRTask * __nullable)getTaskWihtTaskID:(NSString * __nullable)taskID;

#pragma mark - 查询任务数量相关
- (BOOL)taskIsEmpty;
- (NSUInteger)taskCount;

#pragma mark - 执行任务相关
- (void)startExecute;
- (void)pauseExecute;
- (void)resumeExecute;
- (void)stopAndClearTasks;

@end

NS_ASSUME_NONNULL_END
