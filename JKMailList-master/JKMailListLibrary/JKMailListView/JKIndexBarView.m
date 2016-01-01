//
//  CustomIndexBarView.m
//  CustomIndexBar
//
//  Created by jackwang on 14/12/25.
//  Copyright (c) 2014年 jackwang. All rights reserved.
//

#import "JKIndexBarView.h"
#import "JKMailListManger.h"

@interface JKIndexBarView ()

//存储字母的数组
@property (nonatomic,strong) NSArray *lettersArray;

@end

@implementation JKIndexBarView

-(instancetype)initWithFrame:(CGRect)frame

{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.lettersArray = [[JKMailListManger sharedManager] valueForKey:@"lettersArray"];
        [self.lettersArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UILabel *indexLable = [[UILabel alloc] init];;
            float height = self.frame.size.height/ self.lettersArray.count;
            indexLable.frame = CGRectMake(0, height*idx, self.frame.size.width, height);
            indexLable.text = [ self.lettersArray objectAtIndex:idx];
            indexLable.textAlignment = NSTextAlignmentCenter;
            indexLable.font = [UIFont systemFontOfSize:12.0];
            indexLable.textColor = [UIColor blackColor];
            indexLable.backgroundColor = [UIColor clearColor];
            [self addSubview:indexLable];
            
        }];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleViewTouchs:touches withEvent:event];
   
}
- (void)handleViewTouchs:(NSSet *)touches withEvent:(UIEvent *)event
{
    //获得触屏点中的一个
    UITouch *touch = [touches anyObject];
    //得到触屏点在当前坐标系中的坐标
    CGPoint point = [touch locationInView:self];
    if (point.x>0&&point.y>0)
    {
        //根据点击的坐标Y值获得一个索引
        NSInteger idx = point.y/(self.frame.size.height/self.lettersArray.count);
        if (idx>=0&&idx<self.lettersArray.count)
        {
            if ([self.delegate respondsToSelector:@selector(viewTouch:letter:)])
            {
                [self.delegate viewTouch:self letter:[self.lettersArray objectAtIndex:idx]];
            }
        }
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleViewTouchs:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(viewTouchEnd:)])
    {
        [self.delegate viewTouchEnd:self ];
    }
}
- (void)dealloc
{
    NSLog(@"%@ has been released",[self class]);
}
@end
