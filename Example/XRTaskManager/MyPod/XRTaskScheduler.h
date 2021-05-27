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
