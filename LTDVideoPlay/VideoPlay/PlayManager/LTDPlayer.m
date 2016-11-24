//
//  LTDPlayer.m
//  LTDVideoPlay
//
//  Created by ybk on 16/5/3.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import "LTDPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewExt.h"
#import "LTDNotificationKey.h"
#import <MediaPlayer/MediaPlayer.h>

#define LBottomViewHeight 44.0f
#define LeastDistance 15
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HETGHT [[UIScreen mainScreen] bounds].size.height

//创建一个唯一的指针,防止kvo的context重复
static void * PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface LTDPlayer (){
    
    CGPoint _touchBeginPoint;

}

/**
 *  @b AVPlayer播放器
 */
@property(nonatomic,retain) AVPlayer * player;
/**
 *  @b 播放器管理资源的对象
 */
@property(nonatomic, retain) AVPlayerItem * currentItem;
/**
 *  @b AVPlayer播放器图层
 */
@property(nonatomic,retain) AVPlayerLayer * playerLayer;
/**
 *  @b 背景
 */
@property(nonatomic,strong)UIView * backView;
/**
 *  @b 关闭按钮
 */
@property(nonatomic,retain)UIButton * closeButton;
/**
 *  @b 标题栏
 */
@property(nonatomic, retain)UIView *titleView;
/**
 *  @b 播放按钮
 */
@property(nonatomic,retain)UIButton * playOrPauseBtn;
/**
 *  @b 工具栏
 */
@property(nonatomic,retain)UIView * bottomView;
/**
 *  @b 全屏按钮
 */
@property(nonatomic,retain)UIButton * fullScreenBtn;
/**
 *  @b 播放时间
 */
@property(nonatomic,retain)UILabel * rightTimeLabel;

@property(nonatomic,retain)UILabel * leftTimeLabel;

@property(nonatomic, retain)NSDateFormatter * dateFormatter;
/**
 *  @b 进度条
 */
@property (nonatomic,retain) UISlider * progressBar;
@property (nonatomic,retain) UIProgressView * loadProgres;
/**
 *  @b 定时器
 */
@property(strong, nonatomic) NSTimer * handleBackTime;

@property(assign, nonatomic) BOOL isTouchDownProgressBar;


@end

@implementation LTDPlayer

#pragma mark **初始化**
- (instancetype)init{
    
    if (self == [super init]) {
        
//      用纯代码创建的view在init的时候都会调用initWithFrame
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {
        
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(SingleTapAction)];
        
        singleTap.numberOfTapsRequired = 1;
        
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
        
        doubleTap.numberOfTapsRequired = 2;
        
        [self addGestureRecognizer:doubleTap];
        
        // 双击手势确定监测失败才会触发单击手势的相应操作
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
    }
    return self;
}

#pragma mark **屏幕手势处理**
- (void)SingleTapAction{

    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        if (self.backView.alpha == 0.0) {
            
            self.backView.alpha = 1.0;
            
        }else{
            
            self.backView.alpha = 0.0;
            
        }
        
    } completion:^(BOOL finished) {
        //            显示之后，3秒钟隐藏
        if (self.backView.alpha == 1.0) {
            
            [self removeHandleBackTime];
            
            weakSelf.handleBackTime = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(SingleTapAction) userInfo:nil repeats:NO];
            
            [[NSRunLoop mainRunLoop] addTimer:weakSelf.handleBackTime forMode:NSDefaultRunLoopMode];
            
        }else{
            
            [weakSelf.handleBackTime invalidate];
            
            weakSelf.handleBackTime = nil;
        }
    }];
    
}
- (void)doubleTapAction:(UITapGestureRecognizer *)topGsture{
    
    [self PlayOrPause:_playOrPauseBtn];
    
}
#pragma mark **触摸屏幕**
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    UITouch * touch = (UITouch*)touches.anyObject;
    
    if ([touch tapCount] > 1 || touches.count > 1 || event.allTouches.count > 1 ) {
        
        return;
        
    }
    
    if (![[(UITouch*)touches.anyObject view] isEqual:self]) {
        
        return;
        
    }
    
    _touchBeginPoint = [touches.anyObject locationInView:self];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch * touch = (UITouch*)touches.anyObject;
    
    if ([touch tapCount] > 1 || touches.count > 1 || event.allTouches.count > 1 ) {
        
        return;
        
    }
    
    if (![[(UITouch*)touches.anyObject view] isEqual:self]) {
        
        return;
        
    }
    
    CGPoint tempPoint = [touches.anyObject locationInView:self];
    
    if (fabs(tempPoint.x - _touchBeginPoint.x) < LeastDistance && fabs(tempPoint.y - _touchBeginPoint.y) < LeastDistance ) {
        
        return;
        
    }
    float tan =fabs(tempPoint.x - _touchBeginPoint.x)/fabs(tempPoint.y - _touchBeginPoint.y);
    
    if (tan < 1/sqrt(3)) {
        //当滑动角度小于30度的时候, 进度手势
        NSLog(@"x = %f  y = %f",tempPoint.x,tempPoint.y);
        
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"触摸结束\n");
    
}

#pragma mark **变成全频**
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    [self removeFromSuperview];
    
    self.transform = CGAffineTransformIdentity;
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        
    }
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HETGHT);
    
    self.playerLayer.frame =  CGRectMake(0,0, SCREEN_HETGHT,SCREEN_WIDTH);
    
    [self changeFrame];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.fullScreenBtn.selected = YES;
    
    self.screenType = LTDPlayerSizeFullScreenType;
}
/**
 *  @b 改变播放器的位置时候,其上面的控件的大小位置调整都是在这里处理
 */
- (void)changeFrame{
    
    self.backView.frame = self.playerLayer.frame;
    
    _closeButton.frame = CGRectMake(self.backView.frame.size.width-35, 5, 30, 30);
    UIImage *img = [UIImage imageNamed:@"pause"];
    
    self.playOrPauseBtn.frame = CGRectMake((_backView.width - img.size.width)/2, (_backView.height - img.size.height)/2, img.size.width, img.size.height);
    
    _bottomView.frame = CGRectMake(0, self.backView.height-LBottomViewHeight , self.backView.width, LBottomViewHeight);
    
    [_bottomView viewWithTag:10001].frame = _bottomView.bounds;
    
    self.fullScreenBtn.frame = CGRectMake(_bottomView.width-img.size.width - 10, (_bottomView.height-img.size.height)/2,img.size.width ,img.size.height);
    
    self.leftTimeLabel.frame = CGRectMake(0, 0, 60, self.bottomView.height);
    
    self.rightTimeLabel.frame = CGRectMake(_bottomView.width - self.fullScreenBtn.width-self.leftTimeLabel.width - 5,self.leftTimeLabel.top, self.leftTimeLabel.width, self.leftTimeLabel.height);
    
    float width = _bottomView.width - (self.leftTimeLabel.right) - (_bottomView.width - self.rightTimeLabel.left);
    
    self.progressBar.frame = CGRectMake(self.leftTimeLabel.right, 0, width ,_bottomView.height);
    
    self.loadProgres.frame = CGRectMake(self.progressBar.left+2,self.progressBar.height/2-1,width-2,0);
    
    self.titleView.frame = CGRectMake(0, 0, self.backView.width, self.titleView.height);
    
    [self.titleView viewWithTag:100].frame = CGRectMake(15, 0, _backView.width - 30, _titleView.height);
    
    for (CALayer *layer in _titleView.layer.sublayers) {
        
        if ([layer isMemberOfClass:[CAGradientLayer class]]) {
            
            CAGradientLayer *gradientLayer = (CAGradientLayer *)layer;
            
            gradientLayer.bounds = _titleView.bounds;
            
            gradientLayer.frame = _titleView.bounds;
        }
    }
}

- (void)toSmallScreen{
    //放widow上
    [self removeFromSuperview];
    
    self.transform = CGAffineTransformIdentity;
    
    self.frame = CGRectMake(SCREEN_WIDTH, SCREEN_HETGHT - ((SCREEN_WIDTH/2)*0.65), SCREEN_WIDTH/2, (SCREEN_WIDTH/2)*0.65);
    
    self.playerLayer.frame =  self.bounds;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [self changeFrame];
    
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    
    self.screenType = LTDPlayerSizeSmallScreenType;
    
    [UIView animateWithDuration:0.5f animations:^{
        
        self.left = SCREEN_WIDTH - self.width;
        
    } completion:^(BOOL finished) {
        
        //        if (self.playerAnimateFinish)self.playerAnimateFinish();
        
    }];

}

- (void)reductionWithInterfaceInCell:(UIView*)cell{
    
    if (self.screenType == LTDPlayerSizeSmallScreenType) {
        
        [self smallToRight:^(BOOL finished) {
            
            [self reduction:cell];
            
            if (self.reloadData) {
                
                self.reloadData();
                
            }
        }];
        
    }else [self reduction:cell];
    
   
}
- (void)smallToRight:(void (^ __nullable)(BOOL finished))completion
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.left = SCREEN_WIDTH;
        
    } completion:^(BOOL finished) {
        
        completion(finished);
        
    }];
}

- (void)reduction:(UIView *)view{
    
    [self removeFromSuperview];
    
    [view addSubview:self];
    
    [view bringSubviewToFront:self];
    
    self.backView.alpha= 0;
    
    float duration = self.screenType == LTDPlayerSizeFullScreenType?0.5f:0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.transform = CGAffineTransformIdentity;
        
        self.frame = view.bounds;
        
        self.playerLayer.frame =  self.bounds;
        
        [self changeFrame];
        
    }completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.7f animations:^{
            
            self.backView.alpha = 1;
            
        } completion:^(BOOL finished) {
            //   显示之后，3秒钟隐藏
            if (self.backView.alpha == 1.0) {
                
                [self removeHandleBackTime];
                
                self.handleBackTime = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(SingleTapAction) userInfo:nil repeats:NO];
                
                [[NSRunLoop mainRunLoop] addTimer:self.handleBackTime forMode:NSDefaultRunLoopMode];
            }
            //   if (self.playerAnimateFinish)self.playerAnimateFinish();
        }];
        
        self.screenType = LTDPlayerSizeRecoveryScreenType;
        
        self.fullScreenBtn.selected = NO;
    }];

}

#pragma mark **各类小的控件**
- (UIView *)backView{
    
    if (_backView) return _backView;
    
    _backView = [[UIView alloc] initWithFrame:self.bounds];
    
    _backView.alpha = 0;
    
    //   开始或者暂停按钮
    UIImage *img = [UIImage imageNamed:@"pause"];
    
    _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    
    [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playOrPauseBtn setImage:img forState:UIControlStateNormal];
    
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    
    self.playOrPauseBtn.frame = CGRectMake((_backView.width - img.size.width)/2, (_backView.height - img.size.height)/2, img.size.width, img.size.height);
    
    [_backView addSubview:self.playOrPauseBtn];
    
    [_backView addSubview:self.bottomView];
    
    [_backView addSubview:self.titleView];
    
    [_backView addSubview:self.closeButton];
    
    return _backView;
}
//关闭当前视频按钮。
- (UIButton *)closeButton{
    if (_closeButton) return _closeButton;
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _closeButton.showsTouchWhenHighlighted = YES;
    
    [_closeButton addTarget:self action:@selector(colseTheVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
    
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
    
    _closeButton.layer.cornerRadius = 30/2;
    
    _closeButton.frame = CGRectMake(SCREEN_WIDTH - 45, 5, 30, 30);
    
    return _closeButton;
}

- (UIView *)titleView{
    if (_titleView) return _titleView;
    
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _backView.width, 33)];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
    
    gradientLayer.bounds = _titleView.bounds;
    
    gradientLayer.frame = _titleView.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],(id)[[UIColor clearColor] CGColor], nil];
    
    gradientLayer.startPoint = CGPointMake(0.0, -3.0);
    
    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
    
    [_titleView.layer insertSublayer:gradientLayer atIndex:0];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _backView.width - 30, _titleView.height)];
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.text = @"坦克世界";
    
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    
    titleLabel.tag = 100;
    
    titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [_titleView addSubview:titleLabel];
    
    return _titleView;
}

- (UIView *)bottomView{
    
    if (_bottomView) return _bottomView;
    
     _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-LBottomViewHeight , self.width, LBottomViewHeight)];
    
    UIView *bottomBackView = [[UIView alloc] initWithFrame:_bottomView.bounds];
    
    bottomBackView.backgroundColor = [UIColor blackColor];
    
    bottomBackView.alpha = 0.5;
    
    bottomBackView.tag = 10001;
    
    [_bottomView addSubview:bottomBackView];
    
    UIImage *img = [UIImage imageNamed:@"fullscreen"];
    
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.fullScreenBtn setImage:img forState:UIControlStateNormal];
    
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"nonfullscreen"] forState:UIControlStateSelected];
    
    self.fullScreenBtn.frame = CGRectMake(_bottomView.width-img.size.width - 10, (_bottomView.height-img.size.height)/2,img.size.width ,img.size.height);
    
    [_bottomView addSubview:self.fullScreenBtn];
    
    //视频播放时间
    self.leftTimeLabel = [[UILabel alloc]init];
    
    self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    
    self.leftTimeLabel.backgroundColor = [UIColor clearColor];
    
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    
    self.leftTimeLabel.adjustsFontSizeToFitWidth = YES;
    
    self.leftTimeLabel.frame = CGRectMake(0, 0, 60, self.bottomView.height);
    [_bottomView addSubview:self.leftTimeLabel];
    
    self.rightTimeLabel = [[UILabel alloc]init];
    
    self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    
    self.rightTimeLabel.backgroundColor = [UIColor clearColor];
    
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    
    self.rightTimeLabel.adjustsFontSizeToFitWidth = YES;
    
    self.rightTimeLabel.frame = CGRectMake(_bottomView.width - self.fullScreenBtn.width-self.leftTimeLabel.width - 5,self.leftTimeLabel.top, self.leftTimeLabel.width, self.leftTimeLabel.height);
    
    [_bottomView addSubview:self.rightTimeLabel];
    
    float width = _bottomView.width - (self.leftTimeLabel.right) - (_bottomView.width - self.rightTimeLabel.left);
    
    self.progressBar = [[UISlider alloc]initWithFrame:CGRectMake(self.leftTimeLabel.right, 0, width,_bottomView.height)];
    
    self.progressBar.maximumTrackTintColor = [UIColor clearColor];
    
    self.progressBar.minimumValue = 0.0;
    
    self.progressBar.minimumTrackTintColor = [UIColor redColor];
    
    self.progressBar.value = 0.0;
    
    [self.progressBar setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
    // slider开始滑动事件
    [self.progressBar addTarget:self action:@selector(TouchBeganProgress:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.progressBar addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.progressBar addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    
    self.loadProgres = [[UIProgressView alloc]initWithFrame:CGRectMake(self.progressBar.left+2,self.progressBar.height/2-1,width-2,0)];
    
    self.loadProgres.progressTintColor = [UIColor grayColor];
    
    [_bottomView addSubview:self.loadProgres];
    
    [_bottomView addSubview:self.progressBar];
    
    [self bringSubviewToFront:_bottomView];
    
    return _bottomView;
}

#pragma mark **关闭按钮的点击事件**
- (void)colseTheVideoPlayer:(UIButton *)sender{
    
    [self.player pause];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LTDPlayerCloseVideoNotificationKey object:sender];
}

#pragma mark **全频按钮的点击事件**
- (void)fullScreenAction:(UIButton *)sender{
    
    if (self.backView.alpha == 0.0) return;
    
    sender.selected = !sender.selected;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LTDPlayerFullScreenNotificationKey object:sender];
}

#pragma mark **播放按钮的点击事件**
- (void)PlayOrPause:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    //指示当前播放速率；0是“停止”，1是“以当前项目的自然速率播放”
    if (self.player.rate != 1.f) {
        
        if ([self currentTime] == [self duration])
            
            [self setCurrentTime:0.f];
        
        [self.player play];
        
    } else {
        
        [self.player pause];
        
    }
}

#pragma mark **进度条手势处理**
- (void)TouchBeganProgress:(UISlider *)progressBar{
    
    [self removeHandleBackTime];
    
}

- (void)removeHandleBackTime {
    
    if (self.handleBackTime) {
        
        [self.handleBackTime invalidate];
        
        self.handleBackTime = nil;
        
    }
}

- (void)changeProgress:(UISlider *)progressBar{
    
    _isTouchDownProgressBar = YES;
    
}

- (void)updateProgress:(UISlider *)progressBar{
    
    //播放制定时间
    [self.player seekToTime:CMTimeMakeWithSeconds(progressBar.value, 1)];
    
    [self hiddenSingleTap];
    
    _isTouchDownProgressBar = NO;
    
}

- (void)hiddenSingleTap
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.backView.alpha = 0.0;
    }];
}

#pragma mark **获取到链接准备播放**
- (void)setVideoURLStr:(NSString *)videoURLStr{
    
    if (self.currentItem) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        [self removeObserverFromPlayerItem:self.currentItem];
        
    }
    
    self.currentItem = [self getPlayItemWithURLString:videoURLStr];
    
    [self addObserverFromPlayerItem:self.currentItem];
    
    [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];

    if (self.player == nil) {
        
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        self.playerLayer.frame = self.layer.bounds;
        
        if ([_playerLayer superlayer] == nil)[self.layer addSublayer:_playerLayer];
        
        if ([self.backView superview] == nil)[self addSubview:self.backView];
    }
    
    self.playOrPauseBtn.selected = NO;
    
    if (self.player.rate != 1.f) {
        
        if ([self currentTime] == self.duration) [self setCurrentTime:0.f];
        
        [self.player play];
    }
    
    if (self.playStatus)self.playStatus(LTDPlayerStatusLoadingType);
}

#pragma mark  **获取视频播放的时间**
- (double)duration{
    
    AVPlayerItem *playerItem = self.player.currentItem;
    
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        
        return CMTimeGetSeconds([[playerItem asset] duration]);
        
    }
    else{
        
        return 0.f;
        
    }
}

//当前播放到的时间
- (double)currentTime{
    
    return CMTimeGetSeconds([[self player] currentTime]);
}

- (void)setCurrentTime:(double)time{
    
    [[self player] seekToTime:CMTimeMakeWithSeconds(time, 1)];
    
}

#pragma mark **播放结束发出通知**
- (void)moviePlayDidEnd:(NSNotification *)notfication{
    
    __weak typeof(self) weakSelf = self;
    
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
        [weakSelf.progressBar setValue:0.0 animated:YES];
        
        weakSelf.playOrPauseBtn.selected = YES;
        //播放完成后的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:LTDPlayerFinishedPlayNotificationKey object:nil];
    }];
}

#pragma mark **根据链接创建播放器管理资源的对象**
- (AVPlayerItem *)getPlayItemWithURLString:(NSString * )urlString{
    
    if ([urlString containsString:@"http"]) {
        
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        return playerItem;
        
    }else{
        
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:urlString] options:nil];
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        
        return playerItem;
    }
}

#pragma mark  **给播放器添加观察者**
- (void)addObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    
    //监听播放状态的变化
    /**
     *  @b status检查错误的值属性，以确定故障的性质。此属性是可观察的关键值。
     */
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
    
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqual:@"status"]) {
        //播放状态
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        
        if (status == AVPlayerStatusReadyToPlay) {
            
            //进度条的最大值 duration:时长
            if (CMTimeGetSeconds(self.player.currentItem.duration)) {
                
                self.progressBar.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
            }
            
            [self createTimer];
            
            if (self.playStatus)self.playStatus(LTDPlayerStatusReadyToPlayTyep);
        }
        else if([keyPath isEqualToString:@"loadedTimeRanges"]){
            
//            NSArray *array=_currentItem.loadedTimeRanges;
//            CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
//            float startSeconds = CMTimeGetSeconds(timeRange.start);
//            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
//            NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
//            NSLog(@"共缓冲：%.2f",totalBuffer);
            
            if (self.alpha == 0.00) {
                
                if (self.playStatus)self.playStatus(LTDPlayeStatusrLoadedTimeRangesType);
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.alpha = 1.0;
                }];
                
            }
            
        }

    }
}

#pragma mark **创建时间显示**
- (void)createTimer{
    
    __weak typeof(self) weakSelf = self;
    
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    
    double duration = CMTimeGetSeconds(playerDuration);
    
    if (isfinite(duration)) {
        
        CGFloat width = CGRectGetWidth([weakSelf.progressBar bounds]);
        
        interval = 0.5f * duration / width;
        
    }
    //播放器定时操作
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
        
        [weakSelf PeriodicAction];
        
    }];
    
}
//Periodic 周期
- (void)PeriodicAction{
    
    CMTime playerDuration = [self playerItemDuration];
    
    if (CMTIME_IS_INVALID(playerDuration)){
        
        self.progressBar.minimumValue = 0.0; //设置进度为0
        
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    
    if (isfinite(duration)) {
        
        float maxValue = [self.progressBar maximumValue];
        
        float minValue = [self.progressBar minimumValue];
        
        double time = CMTimeGetSeconds([self.player currentTime]);
        
        _leftTimeLabel.text = [self convertTime:time];
        
        _rightTimeLabel.text =  [self convertTime:duration];
        
        NSArray *array=_currentItem.loadedTimeRanges;
        
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        
        [self.loadProgres setProgress:totalBuffer animated:YES];
        
        /**
         *  time视频播放到的时间;duration播放器播放完需要的时间
         */
        float value = (maxValue - minValue) * time / duration + minValue;
        
        if (!_isTouchDownProgressBar) {
            
            [self.progressBar setValue:value];
            
        }
    }
    
}
//转换时间
- (NSString *)convertTime:(CGFloat)second{
    
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    
    if (second/3600 >= 1) {
        
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
        
    } else {
        
        [[self dateFormatter] setDateFormat:@"mm:ss"];
        
    }
    NSString *newTime = [[self dateFormatter] stringFromDate:d];
    
    return newTime;
}

- (NSDateFormatter *)dateFormatter {
    
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        
    }
    return _dateFormatter;
}


//获取播放时长。
- (CMTime)playerItemDuration{
    
    AVPlayerItem * playerItem = [self.player currentItem];
    
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    
    [playerItem removeObserver:self forKeyPath:@"status"];
    
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)releaseWMPlayer{
    
    [self removeObserverFromPlayerItem:self.currentItem];
    
    [self.player.currentItem cancelPendingSeeks];
    
    [self.player.currentItem.asset cancelLoading];
    
    [self.player pause];
    
    [self removeFromSuperview];
    
    [self.playerLayer removeFromSuperlayer];
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    self.player = nil;
    
    self.currentItem = nil;
    
    self.playOrPauseBtn = nil;
    
    self.playerLayer = nil;
}

-(void)dealloc{
    
    [self releaseWMPlayer];
    
    _backView = nil;
    
    if(_handleBackTime) [_handleBackTime invalidate];
    
    _handleBackTime = nil;
}


@end
