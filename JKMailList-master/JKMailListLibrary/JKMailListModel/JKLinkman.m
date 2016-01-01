//
//  Linkman.m
//  JKMailList
//
//  Created by 王锐锋 on 15/12/24.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import "JKLinkman.h"

static NSString *modelFirstLettery = @"firstLetter";
static NSString *modelChinese = @"chinese";
static NSString *modelEnglish = @"english";
static NSString *modelPhoneNumbers = @"phoneNumbers";
static NSString *modelHeadImage = @"headImage";
static NSString *modelRecordID = @"recordID";

@implementation JKLinkman

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.firstLetter = [aDecoder decodeObjectForKey:modelFirstLettery];
    self.chinese = [aDecoder decodeObjectForKey:modelChinese];
    self.english = [aDecoder decodeObjectForKey:modelEnglish];
    self.phoneNumbers = [aDecoder decodeObjectForKey:modelPhoneNumbers];
    self.headImage = [aDecoder decodeObjectForKey:modelHeadImage];
    self.recordID = [aDecoder decodeInt32ForKey:modelRecordID];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_firstLetter forKey:modelFirstLettery];
    [aCoder encodeObject:_chinese forKey:modelChinese];
    [aCoder encodeObject:_english forKey:modelEnglish];
    [aCoder encodeObject:_phoneNumbers forKey:modelPhoneNumbers];
    [aCoder encodeObject:_headImage forKey:modelHeadImage];
    [aCoder encodeInt32:_recordID forKey:modelRecordID];
}
- (id)copyWithZone:(NSZone *)zone
{
    JKLinkman *copy = [[JKLinkman alloc] init];
    
    if (copy)
    {
        
        copy.firstLetter = [self.firstLetter copyWithZone:zone];
        copy.english = [self.english copyWithZone:zone];
        copy.chinese = [self.chinese copyWithZone:zone];
        copy.phoneNumbers = [self.phoneNumbers copyWithZone:zone];
        copy.headImage = self.headImage;
        copy.recordID = self.recordID;
    }
    return copy;
}

@end
