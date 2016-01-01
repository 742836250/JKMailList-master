//
//  JKAddMailListView.m
//  JKMailList-master
//
//  Created by 王锐锋 on 15/12/27.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import "JKAddMailListView.h"
#import <objc/runtime.h>

@interface JKAddMailListView ()<UITextFieldDelegate>

@property (nonatomic, strong) CancelCallBack cancelCallBack;

@property (nonatomic, strong) SureCallBack sureCallBack;

@property (nonatomic, strong) UIView *alertBgView;

@property (nonatomic , strong) UITextField *firstTF;

@property (nonatomic , strong) UITextField *secondTF;

@property (nonatomic , strong) UITextField *thirdTF;

@property (nonatomic, strong) UIButton *sureBtn;

@end

@implementation JKAddMailListView

@synthesize alertBgView,firstTF,secondTF,thirdTF,sureBtn;

+ (void)showWithFirstTFPlaceholder:(NSString *)aPlaceholder
               secondTFPlaceholder:(NSString *)bPlaceholder
                thirdTFPlaceholder:(NSString *)cPlaceholder
                             title:(NSString *)aTitle
                    cancelBtnTitle:(NSString *)cancelBtnTitle
                      sureBtnTitle:(NSString *)sureBtnTitle
                    cancelCallBack:(CancelCallBack)cancelCallBack
                      sureCallBack:(SureCallBack)sureCallBack;
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    JKAddMailListView *bgView = (JKAddMailListView *)objc_getAssociatedObject(window, (__bridge const void *)(@"bgView"));
    if (!bgView)
    {
        bgView = [[JKAddMailListView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                       firstTFPlaceholder:aPlaceholder
                                      secondTFPlaceholder:bPlaceholder
                                       thirdTFPlaceholder:cPlaceholder
                                                    title:(NSString *)aTitle
                                           cancelBtnTitle:(NSString *)cancelBtnTitle
                                             sureBtnTitle:(NSString *)sureBtnTitle
                                           cancelCallBack:cancelCallBack
                                             sureCallBack:sureCallBack];
        objc_setAssociatedObject(window, (__bridge const void *)(@"bgView"), bgView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [window addSubview:bgView];
    }
    else
    {
        bgView.hidden = NO;
        [bgView initJKAddMailListViewData];
    }
    
}
- (void)initJKAddMailListViewData
{
    self.firstTF.text = nil;
    self.secondTF.text = nil;
    self.thirdTF.text = nil;
    self.sureBtn.enabled = NO;
}
- (id)initWithFrame:(CGRect)frame
     firstTFPlaceholder:(NSString *)aPlaceholder
    secondTFPlaceholder:(NSString *)bPlaceholder
     thirdTFPlaceholder:(NSString *)cPlaceholder
              title:(NSString *)aTitle
         cancelBtnTitle:(NSString *)cancelBtnTitle
           sureBtnTitle:(NSString *)sureBtnTitle
         cancelCallBack:(CancelCallBack)cancelCallBack
           sureCallBack:(SureCallBack)sureCallBack

{
    if (self = [super initWithFrame:frame])
    {
        [self registerForKeyboardNotifications];
        
        self.cancelCallBack = cancelCallBack;
        self.sureCallBack = sureCallBack;
        
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
        alertBgView = [[UIView alloc] init];
        alertBgView.bounds = CGRectMake(0, 0, 280, 220);
        alertBgView.center = CGPointMake(CGRectGetWidth(frame)/2,CGRectGetHeight(frame)/2);
        alertBgView.layer.cornerRadius = 280*0.04;
        alertBgView.layer.masksToBounds = YES;
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:alertBgView.bounds];
        bgImageView.image = [UIImage imageNamed:@"005.jpg"];
        
        UILabel *msgLable = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,30)];
        msgLable.text = aTitle;
        msgLable.textAlignment = NSTextAlignmentCenter;
        msgLable.font = [UIFont systemFontOfSize:18];
        msgLable.textColor = [UIColor whiteColor];
        
        firstTF = [self textFieldWithPlaceholder:aPlaceholder frame:CGRectMake(25, 45, 230, 30)];
        secondTF = [self textFieldWithPlaceholder:bPlaceholder frame:CGRectMake(25, 90, 230, 30)];
        thirdTF = [self textFieldWithPlaceholder:cPlaceholder frame:CGRectMake(25, 135, 230, 30)];
        
        UIButton *cancleBtn = [self buttonWithFrame:CGRectMake(0, 180, 140, 40) title:cancelBtnTitle];
        [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        sureBtn = [self buttonWithFrame:CGRectMake(140, 180, 140, 40) title:sureBtnTitle];
        sureBtn.enabled = NO;
        [sureBtn addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionInitial context:nil];
        [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [alertBgView addSubview:bgImageView];
        [alertBgView addSubview:msgLable];
        [alertBgView addSubview:firstTF];
        [alertBgView addSubview:secondTF];
        [alertBgView addSubview:thirdTF];
        [alertBgView addSubview:cancleBtn];
        [alertBgView addSubview:sureBtn];
       
        [self addSubview:alertBgView];
        
        
    }
    return self;
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWasShown:(NSNotification *)notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;

    CGFloat baselineValue = [UIScreen mainScreen].bounds.size.height - keyboardSize.height;
    __weak JKAddMailListView *weakSelf = self;
    
    if (CGRectGetMaxY(alertBgView.frame)+20>baselineValue)
    {
        [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:50 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            
              weakSelf.alertBgView.frame = CGRectMake(weakSelf.alertBgView.frame.origin.x,baselineValue-20-CGRectGetHeight(weakSelf.alertBgView.frame), CGRectGetWidth(weakSelf.alertBgView.frame), CGRectGetHeight(weakSelf.alertBgView.frame));
            
        } completion:^(BOOL finished) {
            
        }];
      
    }
    
}
- (void) keyboardWillHidden:(NSNotification *) notif
{
     __weak JKAddMailListView *weakSelf = self;
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:50 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
       weakSelf.alertBgView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
        
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == sureBtn)
    {
        if ([keyPath isEqualToString:@"enabled"])
        {
            if (sureBtn.enabled)
            {
                [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            }
            else
            {
                [sureBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [sureBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            }
            NSLog(@"%@",change);
        }
    }
    
}

#pragma mark UIControl Method
- (void)cancleBtnClick
{
    [self hiddenKeyboard];
    if (self.cancelCallBack)
    {
        self.cancelCallBack ();
    }
    self.hidden = YES;
}
- (void)sureBtnClick
{
    [self hiddenKeyboard];
    if (self.sureCallBack)
    {
        self.sureCallBack(firstTF.text,secondTF.text,thirdTF.text);
    }
    self.hidden = YES;
}
- (void)hiddenKeyboard
{
    if ([self.firstTF isFirstResponder])
    {
        [self.firstTF resignFirstResponder];
    }
    else if ([self.secondTF isFirstResponder])
    {
        [self.secondTF resignFirstResponder];
    }
    else if ([self.thirdTF isFirstResponder])
    {
        [self.thirdTF resignFirstResponder];
    }
}
- (void)textFieldChangeValue:(UITextField *)textField
{
    if (![self stringIsEmpty:firstTF.text]&&![self stringIsEmpty:secondTF.text])
    {
        NSLog(@"%@",thirdTF.text);
        if ([self isMobileNumber:thirdTF.text])
        {
            sureBtn.enabled = YES;
            
        }
        else
        {
            sureBtn.enabled = NO;
        }
    }
    else
    {
        sureBtn.enabled = NO;
    }
}
- (UITextField *)textFieldWithPlaceholder:(NSString *)aStr frame:(CGRect)aFrame
{
    UITextField *textField = [[UITextField alloc] initWithFrame:aFrame];
    textField.placeholder = aStr;
    textField.backgroundColor = [UIColor whiteColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    [textField addTarget:self action:@selector(textFieldChangeValue:) forControlEvents:UIControlEventEditingChanged];
    
    return textField;
}

- (UIButton *)buttonWithFrame:(CGRect)aFrame title:(NSString *)atitle
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = aFrame;
    [btn setTitle:atitle forState:UIControlStateNormal];
    [btn setTitle:atitle forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    return btn;
}
// 正则判断手机号码地址格式
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 第一位必定为1，第二位大于或等于3，其他位置的可以为0-9， 总11位
     */
    NSString * MOBILE = @"1[3-9][0-9]{9}";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    if ([regextestmobile evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
//判断字符串是否为空(过滤空格)
-(BOOL)stringIsEmpty:(NSString *)str
{
    
    if (!str)
    {
        return YES;
    }
    else
    {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

- (void)dealloc
{
    [self removeObserver:sureBtn forKeyPath:@"enabled"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
