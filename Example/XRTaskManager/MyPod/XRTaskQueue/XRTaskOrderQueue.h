//
//  XRTaskOrderQueue.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import "XRTaskSchedulerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XRTaskOrderQueue : NSObject <XRTaskSchedulerProtocol>

/// 初始化
/// @param reverse 是否倒序
- (instancetype)initWithReverse:(BOOL)reverse;

@end

NS_ASSUME_NONNULL_END
