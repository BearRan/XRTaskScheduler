//
//  XRTaskSchedulerProtocol.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import "XRTask.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XRTaskSchedulerProtocol <NSObject>

- (void)addTask:(XRTask *)task;
- (void)removeTask:(XRTask *)task;
- (void)removeTaskWithTaskID:(NSString *)taskID;
- (void)clearTasks;
- (BOOL)taskIsEmpty;

@end

NS_ASSUME_NONNULL_END
