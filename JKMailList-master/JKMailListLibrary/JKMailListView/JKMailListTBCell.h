//
//  mailListTBCell.h
//  JKMailList
//
//  Created by 王锐锋 on 15/12/25.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PhoneBtnCallBck)();

typedef void(^HeadImageViewCallBack)();

@interface JKMailListTBCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

@property (nonatomic, strong) PhoneBtnCallBck phoneBtnBlock;
@property (nonatomic, strong) HeadImageViewCallBack headImageViewCallBack;

- (IBAction)phoneBtnClick:(id)sender;

+ (CGFloat)cellHeight;

@end
