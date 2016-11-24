//
//  LTDTableViewCell.m
//  LTDVideoPlay
//
//  Created by ybk on 16/4/29.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import "LTDTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LTDTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadSubviewContentWithModel:(VideoModel*)model{
    if (model==nil) {
        return;
    }
    [self.iconseView sd_setImageWithURL:[NSURL URLWithString:model.topicImg] placeholderImage:nil];
    self.sourceLabel.text = model.title;
    [self.VideoImageView sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:nil];
}

@end
