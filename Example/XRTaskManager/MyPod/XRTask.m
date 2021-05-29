//
//  XRTask.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "XRTask.h"
#import "XRTaskScheduler.h"
#import <pthread.h>

@interface XRTask()
{
    pthread_mutex_t _lock;
}

/**
 * task完成时的block
 * （调用方只能执行）
 */
@property (nonatomic, copy, readwrite) XRCompleteBlock completeBlock;
/// 任务状态（默认：Idle）
@property (nonatomic, assign, readwrite) XRTaskStatus taskStatus;
/// block生成的返回数据
@property (nonatomic, strong, readwrite) id responseData;

@end


@implementation XRTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.priority = XRTaskPriorityDefault;
        self.ifNeedCacheWhenCompleted = NO;
        self.taskStatus = XRTaskStatusIdle;
        
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
        pthread_mutex_init(&_lock, &attr);
        pthread_mutexattr_destroy(&attr);
        
        __weak typeof(self) weakSelf = self;
        self.completeBlock = ^(id  _Nonnull data) {
#warning Bear 这里想一下complete是否应该放这里
            [weakSelf setCompleteStatus];
            
            weakSelf.responseData = data;
            if (weakSelf.parseIsComplete) {
                BOOL isComplete = weakSelf.parseIsComplete(data);
                if (isComplete) {
                    [weakSelf.taskSchedulerWhenCompleted startExecute];
                }
            }
        };
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
    NSLog(@"--task dealloc:%@", self.customData);
}

- (void)setCompleteStatus {
    pthread_mutex_lock(&_lock);
    self.taskStatus = XRTaskStatusCompleted;
    pthread_mutex_unlock(&_lock);
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
    if (self.parseIsComplete) {
        /// 尝试根据responseData来解析task是否完成
        if (self.parseIsComplete(self.responseData)) {
            [self.taskSchedulerWhenCompleted startExecute];
        } else {
            // 未完成，则会在completeBlock中执行
        }
    }
}

/// 执行任务
- (void)executeTask {
    pthread_mutex_lock(&_lock);
    BOOL needQuite = self.taskStatus != XRTaskStatusIdle;
    if (needQuite) {
        pthread_mutex_unlock(&_lock);
        return;
    }
    self.taskStatus = XRTaskStatusExecuting;
    pthread_mutex_unlock(&_lock);
    
    if (self.taskBlock) {
        self.taskBlock();
    }
}

/// 取消任务
- (void)cancelTask {
    pthread_mutex_lock(&_lock);
    if (self.taskStatus != XRTaskStatusCanceled) {
        self.taskStatus = XRTaskStatusCanceled;
    }
    pthread_mutex_unlock(&_lock);
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

- (XRParseIsComplete)parseIsComplete {
    if (!_parseIsComplete) {
        _parseIsComplete = ^BOOL(id  _Nonnull data) {
            if (data) {
                return YES;
            }
            return NO;
        };
    }
    
    return _parseIsComplete;
}

- (NSString *)taskID {
    if (!_taskID) {
        _taskID = [self currentDateStr];
    }
    
    return _taskID;
}

//获取当前时间
- (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS "];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    return dateString;
}

@end
