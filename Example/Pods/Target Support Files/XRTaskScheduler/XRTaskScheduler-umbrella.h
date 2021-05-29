#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XRTask.h"
#import "XRTaskQueueManager.h"
#import "XRTaskScheduler.h"
#import "XRTaskSchedulerEnum.h"
#import "XRTaskSchedulerGroup.h"

FOUNDATION_EXPORT double XRTaskSchedulerVersionNumber;
FOUNDATION_EXPORT const unsigned char XRTaskSchedulerVersionString[];

