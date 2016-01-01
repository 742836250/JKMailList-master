//
//  ViewController.m
//  JKMailList
//
//  Created by 王锐锋 on 15/12/24.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import "ViewController.h"
#import "JKMailListVC.h"
#import <AddressBook/AddressBook.h>
@interface ViewController ()

@property (nonatomic, strong) UILabel *backLabel;

@property (nonatomic, strong) UILabel *frontLabel;

@property (nonatomic, strong) UIView *gradientView;

@property (nonatomic, strong) UIImage *clearImage;

@property (nonatomic, assign) BOOL isTangYan;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    //若timer无效return
    if (![self.timer isValid])
    {
        return ;
    }
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:4]];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //若timer无效return
    if (![self.timer isValid])
    {
        return ;
    }
    [self.timer setFireDate:[NSDate distantFuture]];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarWithColor:[UIColor clearColor]];
    [self setUpSubViews];
    [self setFrontLabelLayer];
    [self gradientWithDuration:4];
}

-(void)setNavigationBarWithColor:(UIColor *)color
{
    self.clearImage = [self imageWithColor:color];
    [self.navigationController.navigationBar setBackgroundImage:self.clearImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setUpSubViews
{
    self.gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-100-100, CGRectGetWidth(self.view.frame), 100)];
    self.gradientView.backgroundColor = [UIColor clearColor];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(mailList:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer];
    
    self.backLabel = [[UILabel alloc] initWithFrame:self.gradientView.bounds];
    self.backLabel.text = @"⬅️左滑打开通讯录";
    self.backLabel.textColor = [UIColor colorWithRed:224/255.0 green:109/255.0 blue:43/255.0 alpha:1];
    //self.backLabel.font = [UIFont systemFontOfSize:25];
    self.backLabel.font = [UIFont fontWithName:@"Superclarendon-BlackItalic" size:25];
    self.backLabel.textAlignment = NSTextAlignmentCenter;
    
    self.frontLabel = [[UILabel alloc] initWithFrame:self.gradientView.bounds];
    self.frontLabel.text =@"⬅️左滑打开通讯录";
    self.frontLabel.textColor = [UIColor whiteColor];
    //self.frontLabel.font = [UIFont systemFontOfSize:25];
    self.frontLabel.font = [UIFont fontWithName:@"Superclarendon-BlackItalic" size:25];
    self.frontLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.gradientView addSubview:self.backLabel];
    [self.gradientView addSubview:self.frontLabel];
    [self.view addSubview:self.gradientView];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(changeGirlmageViewImage) userInfo:nil repeats:YES];
    
}

- (void)setFrontLabelLayer
{
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.gradientView.bounds;
    layer.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor redColor].CGColor,(id)[UIColor clearColor].CGColor];
    layer.locations = @[@(0.25),@(0.5),@(0.75)];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1, 0);
    self.frontLabel.layer.mask = layer;
    layer.position = CGPointMake(-self.gradientView.bounds.size.width/4.0, self.gradientView.bounds.size.height/2.0);
}
- (void)gradientWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animation];
    basicAnimation.keyPath = @"transform.translation.x";
    basicAnimation.toValue = @(0);
    basicAnimation.fromValue = @(self.gradientView.bounds.size.width+self.gradientView.bounds.size.width/2.0);
    basicAnimation.duration = duration;
    basicAnimation.repeatCount = LONG_MAX;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    [self.frontLabel.layer.mask addAnimation:basicAnimation forKey:nil];
}
- (void)mailList:(UISwipeGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        JKMailListVC *mailListVC = [[JKMailListVC alloc] init];
        mailListVC.clearImage = self.clearImage;
        [self.navigationController pushViewController:mailListVC animated:YES];
    }
}
- (void)changeGirlmageViewImage
{
    self.isTangYan = !self.isTangYan;
    if (self.isTangYan)
    {
        self.girlImageView.image = [UIImage imageNamed:@"IMG_0366.jpg"];
    }
    else
    {
        self.girlImageView.image = [UIImage imageNamed:@"IMG_0390.jpg"];
        
    }
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    //设置运动时间
    animation.duration = 3;
    //设置运动type
    animation.type = @"rippleEffect";
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [self.view.layer addAnimation:animation forKey:@"animation"];
}
/* //设置状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
// 隐藏导航栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
