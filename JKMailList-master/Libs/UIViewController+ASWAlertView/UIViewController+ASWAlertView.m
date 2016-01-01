//
//  UIViewController+JKCategory.m
//  ASWLeaders
//
//  Created by 王锐锋 on 15/11/20.
//  Copyright © 2015年 pengjinwei. All rights reserved.
//

#import "UIViewController+ASWAlertView.h"
#import "ASWAlertView.h"

//>=8.0
#define IOS_VERSION_8_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

@implementation UIViewController (ASWAlertView)
- (void)showCancelAlertWithTitle:(NSString *)title
                         message:(NSString *)message
               cancelButtonTitle:(NSString *)cancelTitle
                          cancel:(CancelCallBack)cancelCallBack
{
    if (IOS_VERSION_8_OR_ABOVE)
    {
        UIAlertController*alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (cancelCallBack)
            {
               cancelCallBack ();
            }
            
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }
    else
    {
        [ASWAlertView showCancelAlertWithTitle:title message:message cancelButtonTitle:cancelTitle cancel:^{
            
            if (cancelCallBack)
            {
                cancelCallBack ();
            }
        }];
    }
}
- (void)showCancelAndConfirmAlertWithTitle:(NSString *)title
                                   message:(NSString *)message
                         cancelButtonTitle:(NSString *)cancelTitle
                        confirmButtonTitle:(NSString *) confirmTitle
                                    cancel:(CancelCallBack)cancelCallBack
                                   confirm:(ConfirmCallBack)confirmCallBack
{
      if (IOS_VERSION_8_OR_ABOVE)
      {
          UIAlertController*alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
          UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
              if (cancelCallBack)
              {
                  cancelCallBack ();
              }
              
          }];
          UIAlertAction *otherAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
              if (confirmCallBack)
              {
                  confirmCallBack ();
              }
          }];
          [alertController addAction:cancelAction];
          [alertController addAction:otherAction];
          [self presentViewController:alertController animated:YES completion:nil];

      }
    else
    {
        [ASWAlertView showCancelAndConfirmAlertWithTitle:title message:message cancelButtonTitle:cancelTitle confirmButtonTitle:confirmTitle cancel:^{
            
            if (cancelCallBack)
            {
                cancelCallBack ();
            }
            
        } confirm:^{
            
            if (confirmCallBack)
            {
                  confirmCallBack ();
            }
            
        }];
    }
    
}
@end
