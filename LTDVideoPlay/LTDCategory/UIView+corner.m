//
//  UIView+corner.m
//  LTDVideoPlay
//
//  Created by ybk on 16/4/29.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import "UIView+corner.h"

@implementation UIView (corner)


/*

 使用Category需要注意的点：
 
 (1) Category的方法不一定非要在@implementation中实现，也可以在其他位置实现，但是当调用Category的方法时，依据继承树没有找到该方法的实现，程序则会崩溃。
 
 (2) Category理论上不能添加变量，但是可以使用@dynamic 来弥补这种不足。 (即运行时Runtime)
 
 分类的名字（也就是括号括起来的corner）表示的是：对于声明于其他地方的这个类（UIView），在此处添加的方法是额外的，而不是表示这是一个新的类。
 
 */

@dynamic Ltd_cornerRadius,Ltd_hasBorder;

- (void)setLtd_cornerRadius:(CGFloat)Ltd_cornerRadius {
    self.layer.cornerRadius = Ltd_cornerRadius;
    self.layer.masksToBounds = YES;
}


- (void)setLtd_hasBorder:(BOOL)Ltd_hasBorder {
    if (Ltd_hasBorder) {
        self.layer.borderColor = [UIColor cyanColor].CGColor;
        self.layer.borderWidth = 1;
    }
}


@end
