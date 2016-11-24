//
//  LTDNavigationController.m
//  LTDVideoPlay
//
//  Created by ybk on 16/5/17.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import "LTDNavigationController.h"

@interface LTDNavigationController()<UIGestureRecognizerDelegate>

@end

@implementation LTDNavigationController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    /**
     *  interactivePopGestureRecognizer是iOS7推出的解决VeiwController滑动后退的新功能
     */
    __weak LTDNavigationController * weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        
    }

    [self setupNavigationBar];
}
//设置导航栏主题
- (void)setupNavigationBar{
    
    //按钮点击的颜色
    UINavigationBar * appearance = [UINavigationBar appearance];
    [appearance setTintColor:[UIColor blackColor]];
    
    //设置title的字体大小和颜色
    NSMutableDictionary * textAttribute = [NSMutableDictionary dictionary];
    textAttribute[NSForegroundColorAttributeName] = [UIColor greenColor];
    textAttribute[NSFontAttributeName] = [UIFont boldSystemFontOfSize:14];
    [appearance setTitleTextAttributes:textAttribute];

}
/**
 *  重写这个方法目的：能够拦截所有push进来的控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        
        UIButton * backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
        [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    }
}
- (void)back{
    
    [self popViewControllerAnimated:YES];
}
//手势代理
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.childViewControllers.count > 1;
}

@end
