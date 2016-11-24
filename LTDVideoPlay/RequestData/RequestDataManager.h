//
//  RequestDataManager.h
//  LTDVideoPlay
//
//  Created by ybk on 16/4/28.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestSuccess)(NSArray * sidArray,NSArray * videoArray);

typedef void(^RequsetFail)(NSError * error);

@interface RequestDataManager : NSObject

@property(nonatomic,copy)NSArray *sidArray;

@property(nonatomic,copy)NSArray *videoArray;

+(RequestDataManager *)shareManager;

- (void)getSIDArrayWithURLString:(NSString *)URLString success:(RequestSuccess)success failed:(RequsetFail)failed;


@end
