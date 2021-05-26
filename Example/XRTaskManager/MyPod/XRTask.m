//
//  XRTask.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTask.h"
#import "XRTaskScheduler.h"

@interface XRTask()

/// block生成的返回数据
@property (nonatomic, strong, readwrite) id responseData;

@end


@implementation XRTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        self.taskCompleteBlock = ^(id  _Nonnull data) {
            weakSelf.responseData = data;
            if (weakSelf.analysisIsCompleteBlock) {
                BOOL isFinish = weakSelf.analysisIsCompleteBlock(data);
                if (isFinish) {
                    [weakSelf.taskScheduler startExecute];
                }
            }
        };
    }
    return self;
}

/// 尝试执行block
/// @param taskBlock 任务block
- (void)tryToExecuteNextStep:(XRTaskBlock)taskBlock {
    XRTask *task = [XRTask new];
    task.taskBlock = taskBlock;
    [self.taskScheduler addTask:task];
    
    if (self.analysisIsCompleteBlock) {
        /// 尝试根据responseData来解析task是否完成
        if (self.analysisIsCompleteBlock(self.responseData)) {
            [self.taskScheduler startExecute];
        } else {
            // 未完成，则会在taskCompleteBlock中执行
        }
    }
}

#warning Bear 这里增加task，Scheduler递归添加，导致的死循环的问题的防护
#pragma Setter & Getter
- (XRTaskScheduler *)taskScheduler {
    if (_taskScheduler) {
        _taskScheduler = [XRTaskScheduler new];
        _taskScheduler.maxTaskCount = 1;
    }
    
    return _taskScheduler;
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
