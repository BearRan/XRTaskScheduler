//
//  XRTask.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import "XRTaskSchedulerEnum.h"
@class XRTaskScheduler;

NS_ASSUME_NONNULL_BEGIN

typedef void(^XRTaskBlock)(void);
typedef void(^XRTaskCompleteBlock)(id data);
typedef BOOL(^XRAnalysisIsCompleteBlock)(id data);

@interface XRTask : NSObject

/**
 * task任务
 *（调用方只能设置block）
 */
@property (nonatomic, copy) XRTaskBlock taskBlock;
/**
 * task完成时的block
 *（调用方只能执行block）
 */
@property (nonatomic, copy, readonly) XRTaskCompleteBlock taskCompleteBlock;
/**
 * 解析如何判定是否完成task
 *（调用方来提供解析方法，默认：将responseData按bool类型来解析）
 *（调用方只能设置block）
 */
@property (nonatomic, copy) XRAnalysisIsCompleteBlock analysisIsCompleteBlock;
/// 任务完成后自动移除（默认：true）
@property (nonatomic, assign) BOOL removeWhenTaskFinished;
/// block生成的返回数据
@property (nonatomic, strong, readonly) id responseData;
/// 只在XRTaskSchedulerTypePriority类型的任务中生效
@property (nonatomic, assign) XRTaskPriority priority;
/// 任务唯一ID
@property (nonatomic, strong) NSString *taskID;
/// 任务完成时，需要执行的task
@property (nonatomic, strong) XRTaskScheduler *taskSchedulerWhenCompleted;

#pragma mark - Public
/// 在任务完成时尝试执行block
/// @param taskBlock 任务block
- (void)tryToExecuteTaskBlockWhenCompleted:(XRTaskBlock)taskBlock;

/// 在任务完成时尝试执行taskScheduler
- (void)tryToExecuteTaskWhenCompleted;

@end

NS_ASSUME_NONNULL_END
