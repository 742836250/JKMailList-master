//
//  mailListTBCell.m
//  JKMailList
//
//  Created by 王锐锋 on 15/12/25.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import "JKMailListTBCell.h"

@implementation JKMailListTBCell

- (void)awakeFromNib
{
    
    self.headImageView.layer.cornerRadius = CGRectGetWidth(self.headImageView.frame)/2;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet)];
    [self.headImageView addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (IBAction)phoneBtnClick:(id)sender
{
    if (self.phoneBtnBlock)
    {
        self.phoneBtnBlock ();
    }
}
- (void)showActionSheet
{
    if (self.headImageViewCallBack)
    {
        self.headImageViewCallBack ();
    }

}
+ (CGFloat)cellHeight
{
    return 60;
}
- (void)dealloc
{
    NSLog(@"%@ has been released",[self class]);
}
@end
