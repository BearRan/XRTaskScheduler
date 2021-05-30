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
@property (nonatomic, copy) XRResponseBlock responseBlock;
/// 任务状态（默认：Idle）
@property (nonatomic, assign, readwrite) XRTaskStatus taskStatus;
/// block生成的返回数据
@property (nonatomic, strong, readwrite) id responseData;
///  task创建时间
@property (nonatomic, strong, readwrite) NSString *createDate;
/// 为了将task异步转为同步
@property (nonatomic, strong) dispatch_semaphore_t responseSemaphore;
/// 当前重试次数（从1开始计算）
@property (nonatomic, assign) NSInteger currentRetryCount;
/// 绑定声明周期的对象（默认：nil）
@property (nonatomic, weak) id bindDisposeObj;
/// 是否使用dispose（默认：NO）
@property (nonatomic, assign) BOOL ifUseDispose;

@end


@implementation XRTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.priority = XRTaskPriorityDefault;
        self.ifNeedCacheWhenSuccessed = NO;
        self.allowExecuteNext = nil;
        self.taskStatus = XRTaskStatusIdle;
        self.createDate = [self currentDateStr];
        self.responseSemaphore = dispatch_semaphore_create(0);
        self.currentRetryCount = 0;
        self.maxRetryCount = 0;
        self.ifUseDispose = NO;
        self.waitSuccessTaskFinish = NO;
        
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
        pthread_mutex_init(&_lock, &attr);
        pthread_mutexattr_destroy(&attr);
        
        __weak typeof(self) weakSelf = self;
        self.responseBlock = ^(id  _Nonnull data) {
            weakSelf.responseData = data;
            if (weakSelf.parseIsSuccess) {
                BOOL isSuccess = weakSelf.parseIsSuccess(data);
                if (isSuccess) {
                    /// 成功
                    weakSelf.taskStatus = XRTaskStatusSuccess;
                    /// 执行subTaskScheduler
                    [weakSelf.subTaskScheduler startExecute];
                    
                    if (weakSelf.waitSuccessTaskFinish) {
                        /// 需要等待startExecute都执行完
                        weakSelf.subTaskScheduler.schedulerCompleteBlock = ^(NSInteger completeCount) {
                            if (completeCount == 0) {
                                /// 让异步转同步的锁得到释放
                                dispatch_semaphore_signal(weakSelf.responseSemaphore);
                            }
                        };
                    } else {
                        /// 让异步转同步的锁得到释放
                        dispatch_semaphore_signal(weakSelf.responseSemaphore);
                    }
                } else {
#warning Bear retry在task被销毁时，就不要执行了。这个逻辑加一下
                    if (weakSelf.maxRetryCount > 0) {
                        /// 失败，尝试重试
                        if (weakSelf.currentRetryCount < weakSelf.maxRetryCount) {
                            weakSelf.currentRetryCount++;
                            NSLog(@"---task retry %ld time", (long)weakSelf.currentRetryCount);
                            
                            /// 重制状态，重新执行任务
                            weakSelf.taskStatus = XRTaskStatusNeedRetry;
                            [weakSelf executeTaskIsRetry:YES];
                        } else {
                            NSLog(@"---task retry finish");
                            /// 重试多次，仍然失败
                            weakSelf.taskStatus = XRTaskStatusFailure;
                            /// 让异步转同步的锁得到释放
                            dispatch_semaphore_signal(weakSelf.responseSemaphore);
                        }
                    } else {
                        /// 无需重试，错误也可结束
                        weakSelf.taskStatus = XRTaskStatusFailure;
                        /// 让异步转同步的锁得到释放
                        dispatch_semaphore_signal(weakSelf.responseSemaphore);
                    }
                }
            }
        };
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
    NSLog(@"---task dealloc:%@", self.customData);
}

#pragma mark - Public
/// 在任务完成时尝试执行block
/// @param taskBlock 任务block
- (void)tryToExecuteCompletedTaskBlock:(XRTaskBlock)taskBlock {
    XRTask *task = [XRTask new];
    task.taskBlock = taskBlock;
    [self.subTaskScheduler addTask:task];
    
    [self tryToExecuteCompletedScheduler];
}

/// 在任务完成时尝试执行taskScheduler
- (void)tryToExecuteCompletedScheduler {
    if (self.parseIsSuccess) {
        /// 尝试根据responseData来解析task是否完成
        if (self.parseIsSuccess(self.responseData)) {
            [self.subTaskScheduler startExecute];
        } else {
            // 未完成，则会在responseBlock中执行
        }
    }
}

/// 执行任务
- (void)executeTask {
    [self executeTaskIsRetry:NO];
}

/// 执行任务
- (void)executeTaskIsRetry:(BOOL)isRetry {
    BOOL needQuite = YES;
    if (isRetry) {
        needQuite = self.taskStatus != XRTaskStatusNeedRetry;
    } else {
        needQuite = self.taskStatus != XRTaskStatusIdle;
    }
    if (needQuite) {
        return;
    }
    self.taskStatus = XRTaskStatusExecuting;
    
    if (self.taskBlock) {
        self.taskBlock(self, self.responseBlock, self.currentRetryCount);
#warning Bear 超时时间加一下
        if (!isRetry) {
            /// 常规调用的话要加锁，为了异步转同步。
            dispatch_semaphore_wait(self.responseSemaphore, DISPATCH_TIME_FOREVER);
        }
    }
}

/// 取消任务
- (void)cancelTask {
    if (self.taskStatus != XRTaskStatusCanceled) {
        self.taskStatus = XRTaskStatusCanceled;
    }
}

/// 是否可以执行
- (BOOL)ifCanExecute {
    if (self.ifUseDispose && !self.bindDisposeObj) {
        return NO;
    }
    
    return YES;
}

/// 绑定生命周期
- (void)disposeBy:(id)bindDisposeObj {
    if (bindDisposeObj) {
        self.ifUseDispose = YES;
        self.bindDisposeObj = bindDisposeObj;
    } else {
        self.ifUseDispose = NO;
        self.bindDisposeObj = nil;
    }
}

/// 是否允许执行下一个任务
- (BOOL)checkAllowExecuteNext {
    if (self.allowExecuteNext) {
        return [self.allowExecuteNext boolValue];
    }
    
    if (self.taskStatus == XRTaskStatusSuccess) {
        return YES;
    } else {
        return NO;
    }
}

#warning Bear 这里增加task，Scheduler递归添加，导致的死循环的问题的防护
#pragma Setter & Getter
- (XRTaskScheduler *)subTaskScheduler {
    if (!_subTaskScheduler) {
        _subTaskScheduler = [XRTaskScheduler new];
    }
    
    return _subTaskScheduler;
}

- (XRParseIsSuccess)parseIsSuccess {
    if (!_parseIsSuccess) {
        _parseIsSuccess = ^BOOL(id  _Nonnull data) {
            return YES;
        };
    }
    
    return _parseIsSuccess;
}

- (NSString *)taskID {
    if (!_taskID) {
        _taskID = [NSProcessInfo processInfo].globallyUniqueString;
    }
    
    return _taskID;
}

@synthesize taskStatus = _taskStatus;
- (void)setTaskStatus:(XRTaskStatus)taskStatus{
    pthread_mutex_lock(&_lock);
    _taskStatus = taskStatus;
    pthread_mutex_unlock(&_lock);
}

- (XRTaskStatus)taskStatus {
    pthread_mutex_lock(&_lock);
    XRTaskStatus tmpTaskStatus = _taskStatus;
    pthread_mutex_unlock(&_lock);
    
    return tmpTaskStatus;
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
