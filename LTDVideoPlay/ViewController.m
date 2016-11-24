//
//  ViewController.m
//  LTDVideoPlay
//
//  Created by ybk on 16/4/28.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import "ViewController.h"
#import "RequestDataManager.h"
#import "VideoModel.h"
#import "LTDTableViewCell.h"
#import "MJRefresh.h"
#import "LTDPlayManager.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HETGHT [[UIScreen mainScreen] bounds].size.height
#define NavbarHeight 60

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,LDTPlayManagerDelegate>{
    
    UITableView * _VideoListTableView;
    
    NSMutableArray * _DataSource;
    
    NSIndexPath * _PlayerIndexPath;
    
    LTDTableViewCell * _CurrentCell;
}

@property (nonatomic , strong) NSArray * data;

@end

@implementation ViewController


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    _DataSource = [[NSMutableArray alloc]init];
    
    [self requestDataWithRefresh:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"视频播放";
    
    [_VideoListTableView registerClass:[LTDTableViewCell class] forCellReuseIdentifier:@"LTDTableViewCell"];
    
    [self createTableView];
}

- (void)requestDataWithRefresh:(BOOL)refresh{
    
    NSString * refreshUrl = [[NSString alloc]init];
    
    if (refresh) {
        
        [_DataSource removeAllObjects];
        
        refreshUrl = @"http://c.m.163.com/nc/video/home/0-10.html";
    }else{
        
        refreshUrl = [NSString stringWithFormat:@"http://c.m.163.com/nc/video/home/%ld-10.html",_DataSource.count - _DataSource.count%10];
    }
    
    if (_DataSource.count == 0) {
        
        [_VideoListTableView reloadData];
    }
    
    __unsafe_unretained UITableView * tableView = _VideoListTableView;

    [[RequestDataManager shareManager] getSIDArrayWithURLString:refreshUrl success:^(NSArray *sidArray, NSArray *videoArray) {
        
        if (refresh) {
            
            _DataSource =[NSMutableArray arrayWithArray:videoArray];
            
        }else{
            
            [_DataSource addObjectsFromArray:videoArray];
        }
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [tableView reloadData];

         });
        
     }
      failed:^(NSError *error) {
          
      }];
    
    if (!refresh) {
        
        [_VideoListTableView.mj_footer endRefreshing];
        
    }else{
        
        [_VideoListTableView.mj_header endRefreshing];
    }
 
}

- (void)createTableView{
    
    if (_VideoListTableView) {
        
        return;
    }
    
    _VideoListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60,SCREEN_WIDTH,SCREEN_HETGHT-60) style:UITableViewStylePlain];
    
    _VideoListTableView.delegate = self;
    
    _VideoListTableView.dataSource = self;
    
    _VideoListTableView.bounces = YES;
    
    [_VideoListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:_VideoListTableView];

    __weak ViewController * BlockSelf = self;
    
    _VideoListTableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [BlockSelf requestDataWithRefresh:YES];
        
    }];
  
    _VideoListTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [BlockSelf requestDataWithRefresh:NO];
        
    }];
    

}

#pragma mark **UITableViewDataSource**

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return _DataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath == _PlayerIndexPath) {
       
        return _CurrentCell;
    }
    
    LTDTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LTDTableViewCell"];
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LTDTableViewCell" owner:self options:nil]lastObject];
        
        VideoModel * model = [_DataSource objectAtIndex:indexPath.row];
        
        [cell.PlayButton addTarget:self action:@selector(touchWillPlay:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.PlayButton.tag = indexPath.row;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell loadSubviewContentWithModel:model];
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 270;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == _VideoListTableView) {
      
        LTDPlayManager * playManager = [LTDPlayManager sharePlayManager];
        
        if (!playManager.Player) return;
        
        if (playManager.Player.superview) {
            
            CGRect rectInTable = [_VideoListTableView rectForRowAtIndexPath:_PlayerIndexPath];
            
            CGRect rectInSuperview = [_VideoListTableView convertRect:rectInTable toView:[_VideoListTableView superview]];
        
            if (rectInSuperview.origin.y- NavbarHeight<-_CurrentCell.contentView.frame.size.height||rectInSuperview.origin.y>self.view.frame.size.height) {
                //往上拖动
                
                if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:playManager.Player]) {
                    
                    //放widow上,小屏显示
                    [playManager playerSuperviewWillDisappearAction];
                }
                
            }else{
                
                if (![_CurrentCell.VideoView.subviews containsObject:playManager.Player]) {
                    
                    //因为当前cell上的播放器已经remove,根据_PlayerIndexPath找的cell和_CurrentCell为同一个;此处注意的就是当下拉刷新后_PlayerIndexPath找到的cell就不是之前的cell了
                    
                    _CurrentCell = (LTDTableViewCell *)[_VideoListTableView cellForRowAtIndexPath:_PlayerIndexPath];
                    
                    [playManager playInTheCellWithCell:_CurrentCell];
                    
                }
            }
        }
    }
}

#pragma mark **PlayButton(播放)**
- (void)touchWillPlay:(UIButton *)button{
    
    _PlayerIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    _CurrentCell = [_VideoListTableView cellForRowAtIndexPath:_PlayerIndexPath];
        
    VideoModel * model = [_DataSource objectAtIndex:button.tag];
    
    LTDPlayManager * playManager = [LTDPlayManager sharePlayManager];
    
    playManager.delegate = self;
    
    [playManager AddPlayerForView:_CurrentCell andVideoURLStr:model.mp4_url];
    
    __unsafe_unretained UITableView * tableView = _VideoListTableView;
    
    playManager.PlayDidFinishAction = ^(){
        
        [tableView reloadData];
    };
    
}
#pragma mark **LDTPlayManagerDelegate**
- (void)tableViewReloadData{
    [_VideoListTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
