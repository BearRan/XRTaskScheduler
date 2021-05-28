//
//  XRTaskRunLoopConfig.h
//  XRTaskManager_Example
//
//  Created by Bear on 2021/5/28.
//  Copyright © 2021 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XRTaskRunLoopConfig : NSObject

/// 基于RunLoop执行（默认：NO）
@property (nonatomic, assign) BOOL executeBaseRunLoop;

@end

NS_ASSUME_NONNULL_END
