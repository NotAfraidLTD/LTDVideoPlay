//
//  LTDPlayManager.h
//  LTDVideoPlay
//
//  Created by ybk on 16/5/3.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTDPlayer.h"
#import "LTDTableViewCell.h"

@protocol LDTPlayManagerDelegate <NSObject>

- (void)tableViewReloadData;

@end

typedef void (^PlayDidFinished)(void);

typedef void (^PlayInTheCell)(LTDTableViewCell * cell);

@interface LTDPlayManager : NSObject

@property (nonatomic,strong) id<LDTPlayManagerDelegate> delegate;

@property (nonatomic,strong) LTDPlayer * Player;

@property (nonatomic,strong) LTDTableViewCell * PlayCell;

@property (nonatomic,assign) BOOL isSmallScreen;

@property (nonatomic,copy) PlayDidFinished PlayDidFinishAction;

+ (LTDPlayManager *)sharePlayManager;

- (void)playInTheCell;

- (void)AddPlayerForView:(LTDTableViewCell *)PlayerSuperview andVideoURLStr:(NSString *)Url;

- (void)playerSuperviewWillDisappearAction;

- (void)playInTheCellWithCell:(LTDTableViewCell *)cell;

@end
