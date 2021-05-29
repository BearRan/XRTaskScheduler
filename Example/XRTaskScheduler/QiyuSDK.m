//
//  QiyuSDK.m
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import "QiyuSDK.h"

@implementation QiyuSDK

+ (instancetype)shareInstance {
    static QiyuSDK *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [QiyuSDK new];
    });
    
    return shared;
}

- (BOOL)startInitial {
    NSLog(@"---task Qiyu start thread:%@", [NSThread currentThread]);
    [NSThread sleepForTimeInterval:2.0f];
    NSLog(@"---task Qiyu finish");
    
    return YES;
}

- (void)startInitialWithRespBlock:(QiyuRespBlock)respBlock {
    NSLog(@"---task Qiyu start thread:%@", [NSThread currentThread]);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        static int count = 0;
        BOOL resStatus = NO;
        if (count == 2) {
            resStatus = YES;
        }
        count++;
        
        if (respBlock) {
            respBlock(resStatus);
            NSLog(@"---task Qiyu finish");
        }
    });
}

@end

