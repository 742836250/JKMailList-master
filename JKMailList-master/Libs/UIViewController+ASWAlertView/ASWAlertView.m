//
//  ASWAlertView.m
//  ASWLeaders
//
//  Created by 王锐锋 on 15/11/20.
//  Copyright © 2015年 pengjinwei. All rights reserved.
//

#import "ASWAlertView.h"
@interface ASWAlertView ()<UIAlertViewDelegate>

@property (copy, nonatomic) CancelCallBack cancelCallBack;
@property (copy, nonatomic) ConfirmCallBack confirmCallBack;
@end

@implementation ASWAlertView

- (id)initTitle:(NSString *)title
        message:(NSString *)message
cancelButtonTitle:(NSString *)cbTitle
otherButtonTitle:(NSString *)obTitle
       cancel:(CancelCallBack)aCancelCallBack
confirm:(ConfirmCallBack)aConfirmCallBack
{
    self = [super initWithTitle:title
                        message:message
                       delegate:self
              cancelButtonTitle:cbTitle
              otherButtonTitles:obTitle, nil];
    if (self)
    {
        self.cancelCallBack = aCancelCallBack;
        self.confirmCallBack = aConfirmCallBack;
    }
    return self;
}

+ (void)showCancelAlertWithTitle:(NSString *)title
                         message:(NSString *)message
               cancelButtonTitle:(NSString *)cancelTitle
                          cancel:(CancelCallBack)cancelCallBack
{
    ASWAlertView *alert = [[ASWAlertView alloc] initTitle:title
                                                  message:message
                                        cancelButtonTitle:cancelTitle
                                         otherButtonTitle:nil
                                                   cancel:cancelCallBack
                                                  confirm:nil];
    [alert show];

}

+ (void)showCancelAndConfirmAlertWithTitle:(NSString *)title
                                   message:(NSString *)message
                         cancelButtonTitle:(NSString *)cancelTitle
                        confirmButtonTitle:(NSString *)confirmTitle
                                    cancel:(CancelCallBack)cancelCallBack
                                   confirm:(ConfirmCallBack)confirmCallBack{
    ASWAlertView *alert = [[ASWAlertView alloc] initTitle:title
                                                  message:message
                                        cancelButtonTitle:cancelTitle
                                         otherButtonTitle:confirmTitle
                                                   cancel:cancelCallBack
                                                  confirm:confirmCallBack];
    [alert show];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (self.confirmCallBack)
        {
            self.confirmCallBack();
        }
    }
    else if (buttonIndex == 0)
    {
        if (self.cancelCallBack)
        {
            self.cancelCallBack();
        }
    }
}
@end
