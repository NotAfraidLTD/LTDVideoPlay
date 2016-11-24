//
//  LTDTableViewCell.h
//  LTDVideoPlay
//
//  Created by ybk on 16/4/29.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface LTDTableViewCell : UITableViewCell
/**
 *  @b 播放view
 */
@property (weak, nonatomic) IBOutlet UIView *VideoView;
/**
 *  @b 视频图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *VideoImageView;
/**
 *  @b 头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconseView;
/**
 *  @b 来源
 */
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
/**
 *  @b 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;

- (void)loadSubviewContentWithModel:(VideoModel*)model;


@end
