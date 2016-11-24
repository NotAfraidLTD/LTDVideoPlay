//
//  RequestDataManager.m
//  LTDVideoPlay
//
//  Created by ybk on 16/4/28.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import "RequestDataManager.h"
#import "SidModel.h"
#import "VideoModel.h"

@implementation RequestDataManager


+(RequestDataManager *)shareManager{
    
    static RequestDataManager * manager = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        
        manager = [[[self class] alloc] init];
    });
    
    return manager;

}

- (void)getSIDArrayWithURLString:(NSString *)URLString success:(RequestSuccess)success failed:(RequsetFail)failed{
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL * URL = [NSURL URLWithString:URLString];
        NSMutableArray *sidArray = [NSMutableArray array];
        NSMutableArray *videoArray = [NSMutableArray array];
        
        NSMutableURLRequest * MutableRequest = [NSMutableURLRequest requestWithURL:URL];
        //请求方式
        [MutableRequest setHTTPMethod:@"GET"];
        //请求时间
        [MutableRequest setTimeoutInterval:150];
        //缓存策略
        [MutableRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        NSURLSession * session = [NSURLSession sharedSession];
        NSURLSessionDataTask * task = [session dataTaskWithRequest:MutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                
                failed(error);
                
            }else{
                
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                for (NSDictionary * video in [dict objectForKey:@"videoList"]) {
                    VideoModel * model = [[VideoModel alloc] init];
                    [model setValuesForKeysWithDictionary:video];
                    [videoArray addObject:model];
                }
                self.videoArray = [NSArray arrayWithArray:videoArray];
                // 加载头标题
                for (NSDictionary *d in [dict objectForKey:@"videoSidList"]) {
                    SidModel *model= [[SidModel alloc] init];
                    [model setValuesForKeysWithDictionary:d];
                    [sidArray addObject:model];
                }
                self.sidArray = [NSArray arrayWithArray:sidArray];
                
            }
            success(sidArray,videoArray);
            
        }];
        [task resume];
        
    });
}


@end
