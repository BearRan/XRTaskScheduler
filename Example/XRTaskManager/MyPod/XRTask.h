//
//  XRTask.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import "XRTaskSchedulerEnum.h"
@class XRTaskScheduler, XRTask;

NS_ASSUME_NONNULL_BEGIN

typedef void(^XRTaskBlock)(XRTask *task);
typedef void(^XRCompleteBlock)(id data);
typedef BOOL(^XRParseIsComplete)(id data);

typedef NS_ENUM(NSInteger, XRTaskStatus) {
    /// 空
    XRTaskStatusIdle,
    /// 执行中
    XRTaskStatusExecuting,
    /// 执行完成
    XRTaskStatusCompleted,
    /// 被取消
    XRTaskStatusCanceled,
};

@interface XRTask : NSObject

#pragma mark 配置型参数
/// 只在XRTaskSchedulerTypePriority类型的任务中生效（默认：XRTaskPriorityDefault）
@property (nonatomic, assign) XRTaskPriority priority;
/// 任务唯一ID
@property (nonatomic, strong) NSString *taskID;
/// 任务完成时，需要执行的task
@property (nonatomic, strong) XRTaskScheduler *taskSchedulerWhenCompleted;
/// 任务完成后，task是否需要缓存（默认：NO）
@property (nonatomic, assign) BOOL ifNeedCacheWhenCompleted;

#pragma mark Block型参数
/**
 * task任务
 * block：设置型
 */
@property (nonatomic, copy) XRTaskBlock taskBlock;
/**
 * task完成时的block
 * block：执行型
 */
@property (nonatomic, copy, readonly) XRCompleteBlock completeBlock;
/**
 * 解析如何判定是否完成task
 *（调用方来提供解析方法，默认：将responseData按bool类型来解析）
 * block：设置型
 */
@property (nonatomic, copy) XRParseIsComplete parseIsComplete;

#pragma mark 只读型参数
/// 任务状态（默认：Idle）
@property (nonatomic, assign, readonly) XRTaskStatus taskStatus;
/// completeBlock生成的返回数据
@property (nonatomic, strong, readonly) id responseData;

#pragma mark 其他无关参数
/// 自定义数据（调用方可以把一些自定义信息存在这里）
@property (nonatomic, strong) id customData;
///  task创建时间
@property (nonatomic, strong, readonly) NSString *createDate;


#pragma mark - Public Func
#pragma mark task完成时，执行的任务
/// 在任务完成时尝试执行block
/// @param taskBlock 任务block
- (void)tryToExecuteCompletedTaskBlock:(XRTaskBlock)taskBlock;
/// 在任务完成时尝试执行taskScheduler
- (void)tryToExecuteCompletedScheduler;

#pragma mark 执行/取消task
/// 执行任务
- (void)executeTask;
/// 取消任务
- (void)cancelTask;

@end

NS_ASSUME_NONNULL_END
