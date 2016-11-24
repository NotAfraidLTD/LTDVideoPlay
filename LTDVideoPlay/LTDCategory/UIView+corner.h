//
//  UIView+corner.h
//  LTDVideoPlay
//
//  Created by ybk on 16/4/29.
//  Copyright © 2016年 ybk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (corner)

/**
 *  IBInspectable  关键字修饰的作用就是在xib能出现这个属性
 */

@property (nonatomic, assign) IBInspectable CGFloat     Ltd_cornerRadius;

@property (nonatomic, assign) IBInspectable BOOL        Ltd_hasBorder;

@end
