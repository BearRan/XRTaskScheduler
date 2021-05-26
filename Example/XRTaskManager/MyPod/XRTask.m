//
//  XRTask.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTask.h"
#import "XRTaskScheduler.h"

@interface XRTask()

/**
 * task完成时的block
 * （调用方只能执行）
 */
@property (nonatomic, copy, readwrite) XRTaskCompleteBlock taskCompleteBlock;
/// block生成的返回数据
@property (nonatomic, strong, readwrite) id responseData;

@end


@implementation XRTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.removeWhenTaskFinished = YES;
        self.priority = XRTaskPriorityDefault;
        
        __weak typeof(self) weakSelf = self;
        self.taskCompleteBlock = ^(id  _Nonnull data) {
            weakSelf.responseData = data;
            if (weakSelf.analysisIsCompleteBlock) {
                BOOL isComplete = weakSelf.analysisIsCompleteBlock(data);
                if (isComplete) {
                    [weakSelf.taskSchedulerWhenCompleted startExecute];
                }
            }
        };
    }
    return self;
}

#pragma mark - Public
/// 在任务完成时尝试执行block
/// @param taskBlock 任务block
- (void)tryToExecuteTaskBlockWhenCompleted:(XRTaskBlock)taskBlock {
    XRTask *task = [XRTask new];
    task.taskBlock = taskBlock;
    [self.taskSchedulerWhenCompleted addTask:task];
    
    [self tryToExecuteTaskWhenCompleted];
}

/// 在任务完成时尝试执行taskScheduler
- (void)tryToExecuteTaskWhenCompleted {
    if (self.analysisIsCompleteBlock) {
        /// 尝试根据responseData来解析task是否完成
        if (self.analysisIsCompleteBlock(self.responseData)) {
            [self.taskSchedulerWhenCompleted startExecute];
        } else {
            // 未完成，则会在taskCompleteBlock中执行
        }
    }
}



#warning Bear 这里增加task，Scheduler递归添加，导致的死循环的问题的防护
#pragma Setter & Getter
- (XRTaskScheduler *)taskSchedulerWhenCompleted {
    if (_taskSchedulerWhenCompleted) {
        _taskSchedulerWhenCompleted = [XRTaskScheduler new];
        _taskSchedulerWhenCompleted.maxTaskCount = 1;
    }
    
    return _taskSchedulerWhenCompleted;
}

- (XRAnalysisIsCompleteBlock)analysisIsCompleteBlock {
    if (!_analysisIsCompleteBlock) {
        _analysisIsCompleteBlock = ^BOOL(id  _Nonnull data) {
            if (data) {
                return YES;
            }
            return NO;
        };
    }
    
    return _analysisIsCompleteBlock;
}

@end
