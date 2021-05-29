//
//  XRBaseDemoVC.h
//  XRTaskScheduler_Example
//
//  Created by Bear on 2021/5/29.
//  Copyright © 2021 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XRTaskScheduler.h"

NS_ASSUME_NONNULL_BEGIN

@interface XRBaseDemoVC : UIViewController

@property (nonatomic, strong) XRTaskScheduler *taskScheduler;

- (void)startTest;
- (XRTask *)generateTestTaskWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
