//
//  QiyuSDK.h
//  XRTaskManager
//
//  Created by Bear on 2021/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QiyuRespBlock)(BOOL value);
@interface QiyuSDK : NSObject

+ (instancetype)shareInstance;
/// 初始化
- (BOOL)startInitial;
- (void)startInitialWithRespBlock:(QiyuRespBlock)respBlock;
/// 进入聊天室
- (void)pushToChatRoom;

@end

NS_ASSUME_NONNULL_END
