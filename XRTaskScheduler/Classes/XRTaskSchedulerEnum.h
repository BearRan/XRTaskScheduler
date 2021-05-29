//
//  XRTaskSchedulerEnum.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XRTaskSchedulerType) {
    /// 优先级
    XRTaskSchedulerTypePriority,
    /// 正序
    XRTaskSchedulerTypeSequence,
    /// 倒叙
    XRTaskSchedulerTypeReverse,
};

typedef NSInteger XRTaskPriority;
static const XRTaskPriority XRTaskPriorityHigh = 750;
static const XRTaskPriority XRTaskPriorityDefault = 500;
static const XRTaskPriority XRTaskPriorityLow = 250;

@interface XRTaskSchedulerEnum : NSObject

@end

NS_ASSUME_NONNULL_END
