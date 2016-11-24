//
//  LTDPlayManager.m
//  LTDVideoPlay
//
//  Created by ybk on 16/5/3.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import "LTDPlayManager.h"
#import "LTDNotificationKey.h"

@implementation LTDPlayManager

+(LTDPlayManager *)sharePlayManager{
    
    static LTDPlayManager * manager = nil;
    
    static dispatch_once_t predicate;
    
    /*  
        dispatch_once保证程序在运行过程中只会被运行一次，那么假设此时线程1先执行shareInstance方法，
        创建了一个实例对象，线程2就不会再去执行dispatch_once的代码了。从而保证了只会创建一个实例对象。
     */
   
    dispatch_once(&predicate, ^{
        
        manager = [[[self class] alloc] init];
        
    });
    
    return manager;
    
}

- (instancetype)init{
    if (self = [super init]) {
        
#ifdef DEBUG
        
        NSLog(@"debug");
        
#else
        
        NSLog(@"正式");
        
#endif
        
        [self addObserve];
    }
    return self;
}

- (LTDPlayer *)Player{
    
    if (!_Player) {
        
        _Player = [[LTDPlayer alloc]init];
        
        __weak LTDPlayManager * weakSelf = self;
        
        _Player.playStatus =  ^(LTDPlayerStatusChangeType playerStatus){
            
            NSLog(@"playerStatus == %ld ",(long)playerStatus);
            
            if (playerStatus == 1) {
                
                weakSelf.PlayCell.VideoImageView.alpha = 0;
            }
            
        };
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewReloadData)]) {
            
            __weak id<LDTPlayManagerDelegate> weakDelegate = self.delegate;
            
            _Player.reloadData = ^(){
                
                [weakDelegate tableViewReloadData];
                
            };
        }
    }
    
    return _Player;
    
}
- (void)AddPlayerForView:(LTDTableViewCell *)PlayerSuperview andVideoURLStr:(NSString *)Url{
    
    _isSmallScreen = NO;

    if (self.Player.superview) {
        
        [self releaseWMPlayer];
        
    }
    
    self.PlayCell = PlayerSuperview;
    
    self.Player.frame = PlayerSuperview.VideoView.frame;
    
    [self.Player setVideoURLStr:Url];
    
    [PlayerSuperview.VideoView addSubview:self.Player];
    
    [PlayerSuperview.VideoView bringSubviewToFront:self.Player];

}

#pragma mark **观察通知**
- (void)addObserve{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayDidFinished:) name:LTDPlayerFinishedPlayNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CloseDidVideoPlay:) name:LTDPlayerCloseVideoNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FullScreenAction:) name:LTDPlayerFullScreenNotificationKey object:nil];
    
    
}
#pragma mark **响应通知**
/**
 *  @b 播放完成
 */
- (void)PlayDidFinished:(NSNotification *)notification{
    
    if (self.PlayDidFinishAction) {
        
        self.PlayDidFinishAction();
        
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.Player.alpha = 0.0;
        
        self.PlayCell.VideoImageView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        [self.Player removeFromSuperview];
        
        [self releaseWMPlayer];
        
    }];
}
/**
 *  @b 点击关闭
 */
- (void)CloseDidVideoPlay:(NSNotification *)notification{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.Player.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [self.Player removeFromSuperview];
        
        [self releaseWMPlayer];
        
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewReloadData)]) {
        
        self.PlayCell.VideoImageView.alpha = 1;
        
        [self.delegate tableViewReloadData];
    }
    
}
/**
 *  @b 点击全频播发
 */
- (void)FullScreenAction:(NSNotification *)notification{
    
    UIButton *fullScreenBtn = (UIButton *)[notification object];
    
    if (fullScreenBtn.isSelected) {
        //全屏显示
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        [self.Player toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        
    }else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        if (_isSmallScreen) {
            
            //放widow上,小屏显示
            [self playerSuperviewWillDisappearAction];
            
        }else{
            
            if (self.PlayCell) {
                
                [self playInTheCell];
                
            }
        }
    }
}

#pragma mark **在cell上播放**

- (void)playInTheCell{
    
    _isSmallScreen = NO;
    
    [self.Player reductionWithInterfaceInCell:self.PlayCell.VideoView];
}

- (void)playInTheCellWithCell:(LTDTableViewCell *)cell{
    
    _isSmallScreen = NO;
    
    [self.Player reductionWithInterfaceInCell:cell.VideoView];
}

#pragma mark **cell将要消失**

- (void)playerSuperviewWillDisappearAction{
    //放widow上
    [self.Player toSmallScreen];
    
    _isSmallScreen = YES;
}

#pragma mark **释放播放器**

-(void)releaseWMPlayer{
    
    [self.Player releaseWMPlayer];
    
    self.Player = nil;
}

-(void)dealloc{
    
    NSLog(@"%@ dealloc",[self class]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self releaseWMPlayer];
}

@end
