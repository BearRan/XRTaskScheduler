//
//  XRTaskQueueManager.h
//  XRTaskManager_Example
//
//  Created by Bear on 2021/5/28.
//  Copyright © 2021 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XRTaskQueueManager : NSObject

+ (instancetype)shareInstance;
- (dispatch_queue_t)getQueue;

@end

NS_ASSUME_NONNULL_END
