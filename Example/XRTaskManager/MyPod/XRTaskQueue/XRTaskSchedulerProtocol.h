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

- (void)addTask:(XRTask * __nullable)task;
- (void)removeTask:(XRTask * __nullable)task;
- (XRTask * __nullable)getTaskWihtTaskID:(NSString * __nullable)taskID;
- (void)removeTaskWithTaskID:(NSString * __nullable)taskID;
- (void)clearTasks;
- (BOOL)taskIsEmpty;
- (void)startExecute;

@end

NS_ASSUME_NONNULL_END
