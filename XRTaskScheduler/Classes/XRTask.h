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

typedef void(^XRSuccessBlock)(id __nullable data);
typedef void(^XRTaskBlock)(XRTask *task, XRSuccessBlock successBlock, NSInteger retryCount);
typedef BOOL(^XRParseIsSuccess)(id data);

typedef NS_ENUM(NSInteger, XRTaskStatus) {
    /// 空
    XRTaskStatusIdle,
    /// 执行中
    XRTaskStatusExecuting,
    /// 执行成功
    XRTaskStatusSuccess,
    /// 执行失败
    XRTaskStatusFailure,
    /// 需要重试
    XRTaskStatusNeedRetry,
    /// 被取消
    XRTaskStatusCanceled,
};

@interface XRTask : NSObject

#pragma mark 配置型参数
/// 只在XRTaskSchedulerTypePriority类型的任务中生效（默认：XRTaskPriorityDefault）
@property (nonatomic, assign) XRTaskPriority priority;
/// 任务唯一ID
@property (nonatomic, strong) NSString *taskID;
/// 任务成功时，需要执行的task
@property (nonatomic, strong) XRTaskScheduler *successTaskScheduler;
/// 任务完成后，task是否需要缓存（默认：NO）
@property (nonatomic, assign) BOOL ifNeedCacheWhenSuccessed;
/**
 * 是否允许执行下一个任务（默认：nil，请传@YES/@NO）
 * 为nil时：checkAllowExecuteNext方法会通过taskStatus来决定
 * 不为nil时：checkAllowExecuteNext方法会通过本属性来决定
 * （此参数非必填，默认会用内部逻辑来决定）
 */
@property (nonatomic, strong) NSNumber * __nullable allowExecuteNext;
/// 任务失败后，重试次数（默认：0）
@property (nonatomic, assign) NSInteger maxRetryCount;
/// 是否等待successTaskScheduler执行完才执行下一个taskBlock（默认：NO）
@property (nonatomic, assign) BOOL waitSuccessTaskFinish;

#pragma mark Block型参数
/**
 * task任务
 * retryCount：重试次数，从1开始。0表示没有重试过。
 * 注意：任务执行完成后，一定要执行successBlock() ！！！！！！！！！！！！！！！。
 * 因为，successTaskScheduler，block中异步转同步，responseData。都依赖于successBlock！
 */
#warning Bear 不过还是可以优化的。可以捕获block。
// 必须：block中异步转同步。
// 可选：successTaskScheduler，responseData
@property (nonatomic, copy) XRTaskBlock taskBlock;
/**
 * 解析如何判定taskBlock是否执行成功
 *（调用方需要提供解析方法，默认：返回YES）
 */
@property (nonatomic, copy) XRParseIsSuccess parseIsSuccess;

#pragma mark 只读型参数
/// 任务状态（默认：Idle）
@property (nonatomic, assign, readonly) XRTaskStatus taskStatus;
/// successBlock生成的返回数据
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

/// 是否可以执行
- (BOOL)ifCanExecute;
/// 绑定生命周期
- (void)disposeBy:(id)bindDisposeObj;
/// 是否允许执行下一个任务
- (BOOL)checkAllowExecuteNext;

@end

NS_ASSUME_NONNULL_END
