//
//  JKIndexBar.h
//  JKMailList
//
//  Created by 王锐锋 on 15/12/25.
//  Copyright © 2015年 jack_wang. All rights reserved.
//
 #import <Foundation/Foundation.h>

@class JKIndexBarView;

@protocol JKIndexBarViewDelegate <NSObject>

- (void)viewTouchEnd:(JKIndexBarView *)view;

- (void)viewTouch:(JKIndexBarView *)view letter:(NSString *)letter;


@end