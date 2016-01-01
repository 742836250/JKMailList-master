//
//  ASWAlertView.h
//  ASWLeaders
//
//  Created by 王锐锋 on 15/11/20.
//  Copyright © 2015年 pengjinwei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelCallBack)(void);
typedef void(^ConfirmCallBack)(void);

@interface ASWAlertView : UIAlertView

+ (void)showCancelAlertWithTitle:(NSString *)title
                         message:(NSString *)message
               cancelButtonTitle:(NSString *)cancelTitle
                          cancel:(CancelCallBack)cancelCallBack;

+ (void)showCancelAndConfirmAlertWithTitle:(NSString *)title
                                   message:(NSString *)message
                         cancelButtonTitle:(NSString *)cancelTitle
                        confirmButtonTitle:(NSString *)confirmTitle
                                    cancel:(CancelCallBack)cancelCallBack
                                   confirm:(ConfirmCallBack)confirmCallBack;

@end
