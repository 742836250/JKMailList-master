//
//  CustomIndexBarView.h
//  CustomIndexBar
//
//  Created by jackwang on 14/12/25.
//  Copyright (c) 2014年 jackwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKIndexBar.h"

@interface JKIndexBarView : UIView

@property (nonatomic,assign) id<JKIndexBarViewDelegate>delegate;

-(id)initWithFrame:(CGRect)frame;



@end
