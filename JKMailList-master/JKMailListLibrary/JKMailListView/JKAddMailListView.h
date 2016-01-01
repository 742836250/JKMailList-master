//
//  JKAddMailListView.h
//  JKMailList-master
//
//  Created by 王锐锋 on 15/12/27.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^CancelCallBack)(void);

typedef void(^SureCallBack)(NSString *str1,NSString *str2,NSString *str3);

@interface JKAddMailListView : UIView

+ (void)showWithFirstTFPlaceholder:(NSString *)aPlaceholder
               secondTFPlaceholder:(NSString *)bPlaceholder
                thirdTFPlaceholder:(NSString *)cPlaceholder
                             title:(NSString *)aTitle
                    cancelBtnTitle:(NSString *)cancelBtnTitle
                      sureBtnTitle:(NSString *)sureBtnTitle
                    cancelCallBack:(CancelCallBack)cancelCallBack
                      sureCallBack:(SureCallBack)sureCallBack;


@end
