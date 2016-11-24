//
//  LTDPlayer.h
//  LTDVideoPlay
//
//  Created by ybk on 16/5/3.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LTDPlayerSizeType) {
    LTDPlayerSizeFullScreenType     = 0, //全屏
    LTDPlayerSizeSmallScreenType    = 1,//小屏
    LTDPlayerSizeDetailScreenType   = 2,//详情页面显示
    LTDPlayerSizeRecoveryScreenType = 3//恢复大小
};

typedef NS_ENUM(NSInteger, LTDPlayerStatusChangeType) {
    LTDPlayerStatusLoadingType          = 0, //正在加载
    LTDPlayerStatusReadyToPlayTyep      = 1,//开始播放
    LTDPlayeStatusrLoadedTimeRangesType = 2//开始缓存
};

typedef void (^PlayerStatusChange) (LTDPlayerStatusChangeType status);

typedef void (^tableViewReloadData)();

@interface LTDPlayer : UIView

@property (nonatomic,copy) PlayerStatusChange playStatus;

@property (nonatomic,copy) tableViewReloadData reloadData;

@property (assign, nonatomic) LTDPlayerSizeType screenType;


/**
 *  @b 获取播放的链接
 */

- (void)setVideoURLStr:(NSString *)videoURLStr;

/**
 *  @b 旋转变成全频播放
 */

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation;

/**
 *  @b 缩小到cell播放
 */

- (void)reductionWithInterfaceInCell:(UIView*)cell;

- (void)toSmallScreen;

-(void)releaseWMPlayer;

@end
