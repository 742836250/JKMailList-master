//
//  JKMailListManger.m
//  JKMailList
//
//  Created by 王锐锋 on 15/12/24.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import "JKMailListManger.h"
#import "JKLinkman.h"
#import <AddressBook/AddressBook.h>
#import "PinYinForObjc.h"
#import "TMCache.h"


static NSString *mailListMangerModelSaveKey = @"mailListMangerModelSaveKey";

@interface JKMailListManger ()

@property (nonatomic, copy) NSArray *lettersArray;

@end

@implementation JKMailListManger

+ (instancetype)sharedManager
{
    static JKMailListManger *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[JKMailListManger alloc] init];
    });
    return manger;
}
- (id)init
{
    if (self = [super init])
    {
        self.lettersArray = @[@"🔍",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
    }
    return self;
}
- (JKMailListMangerModel *)mailListsWith:(NSArray *)rawDataArray synchronous:(BOOL)synchronous
{
    if (!synchronous)
    {
        if ([self getAmailListMangerModel])
        {
            return self.mailListMangerModel;
        }
        else
        {
            self.mailListMangerModel = [[JKMailListMangerModel alloc] init];
        }
    }
    else
    {
        self.mailListMangerModel = [[JKMailListMangerModel alloc] init];
    }
    NSMutableArray *mailLists = [NSMutableArray array];
    [rawDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JKLinkman *man = [[JKLinkman alloc] init];
        
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue((__bridge ABRecordRef)(obj), kABPersonFirstNameProperty);
        firstName = firstName?firstName:@"";
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue((__bridge ABRecordRef)(obj), kABPersonLastNameProperty);
        lastName = lastName?lastName:@"";
        NSString *name = [NSString stringWithFormat:@"%@%@",lastName,firstName];
        ABMultiValueRef phonesRef = ABRecordCopyValue((__bridge ABRecordRef)(obj),
                                                         kABPersonPhoneProperty);
        if(phonesRef)
        {
            NSMutableArray *phoneNumbers = [NSMutableArray array];
            NSInteger count = ABMultiValueGetCount(phonesRef);
            for(NSInteger i = 0; i < count; i++)
            {
                CFStringRef numberRef = ABMultiValueCopyValueAtIndex(phonesRef, i);
                NSString *phoneNumber = (__bridge NSString *)numberRef;
                phoneNumber = [self telephoneWithReformat:phoneNumber];
                [phoneNumbers addObject:phoneNumber];
                if(numberRef)
                {
                    CFRelease(numberRef);
                }
            }
            man.phoneNumbers = phoneNumbers;
            CFRelease(phonesRef);
        }
        
        //用户头像
        NSData *headData = (__bridge_transfer NSData*)ABPersonCopyImageData(objc_unretainedPointer(obj));
        if (headData)
        {
            man.headImage = [UIImage imageWithData:headData];
        }
        ABRecordID recordID = ABRecordGetRecordID((__bridge ABRecordRef)(obj));
        man.recordID = recordID;
        
        NSString *english = [self translateInToEnglishWithString:name];
        const char *a = [[[[english componentsSeparatedByString:@" "] objectAtIndex:0]substringToIndex:1] cStringUsingEncoding:NSASCIIStringEncoding];
        man.firstLetter = a?[self firstCapitalizationLetterWithEnglishString:english]:@"#";
        man.chinese = (NSString *)name;
        man.english = english;
        [mailLists addObject:man];
    }];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
//    [mailLists addObjectsFromArray:[mailLists mutableCopy]];
    self.mailListMangerModel.dataArray = [mailLists mutableCopy];
    return [self screeningAccordingToTheFirstLetterWithData:mailLists];
}

- (NSString *)translateInToEnglishWithString:(NSString *)aString
{
    /***  不支持多音字识别 (弃用)   ***/
    /*CFStringRef aCFString = (__bridge  CFStringRef)(NSString *)aString;
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, aCFString);
    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *engishStr = (__bridge NSString *)string;*/
    NSString *engishStr = [PinYinForObjc chineseConvertToPinYin:aString];
    return engishStr;
}
- (NSString *)firstCapitalizationLetterWithLanguageUnknownString:(NSString *)aString
{
    NSString *engishStr = [self translateInToEnglishWithString:aString];
    return [self firstCapitalizationLetterWithEnglishString:engishStr];
}
- (NSString *)firstCapitalizationLetterWithEnglishString:(NSString *)aString
{
    const char *a = [[[[aString componentsSeparatedByString:@" "] objectAtIndex:0]substringToIndex:1] cStringUsingEncoding:NSASCIIStringEncoding];
    //用ascii码将小写字母转化为大写
    char b = *a;
    //NSLog(@"%c的ASCII码%d",*a,b);
    if (b>='A'&&b<='Z')
    {
        // NSLog(@"大写");
    }
    else if (b>='a'&&b<='z')
    {
        //NSLog(@"小写");
        b -=32;
    }
    else
    {
        b = 35;
    }
    //将大写的字母转化为oc字符串
    NSString *firstLetters = [[NSString alloc] initWithCString:&b encoding:NSASCIIStringEncoding];
    return  [firstLetters substringToIndex:1];
}
- (JKMailListMangerModel *)screeningAccordingToTheFirstLetterWithData:(NSMutableArray *)aArray
{
    NSMutableArray *mailListsArray = [NSMutableArray array];
    NSSortDescriptor *ascendingSort = [[NSSortDescriptor alloc] initWithKey:@"english" ascending:YES];
    [aArray sortUsingDescriptors:@[ascendingSort]];
    NSMutableArray *validLettersArray = [self.lettersArray mutableCopy];
    [validLettersArray removeObjectAtIndex:0];
    [validLettersArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstLetter = %@",(NSString *)obj];
        
        if ([aArray filteredArrayUsingPredicate:predicate].count>0)
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[aArray filteredArrayUsingPredicate:predicate],(NSString *)obj, nil];
            [self.mailListMangerModel.mailListContainsLettersArray addObject:obj];
            [mailListsArray addObject:dic];
        }
        
    }];
    self.mailListMangerModel.mailListsArray = mailListsArray;
    [JKMailListMangerModel saveModelToLocal:self.mailListMangerModel];
    return self.mailListMangerModel;
}
/**
 *  过滤手机号码中的特殊符号
 */
- (NSString*)telephoneWithReformat:(NSString*)tel
{
    if ([self containsString:tel targetString:@"-"])
    {
        tel = [tel stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if ([self containsString:tel targetString:@" "])
    {
        tel = [tel stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if ([self containsString:tel targetString:@"("])
    {
        tel = [tel stringByReplacingOccurrencesOfString:@"(" withString:@""];
    }
    
    if ([self containsString:tel targetString:@")"])
    {
        tel = [tel stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    
    if ([self containsString:tel targetString:@"+86"])
    {
        tel = [tel stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    }
    
    if ([self containsString:tel targetString:@" "])
    {
        tel = [tel stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return tel;
}
- (BOOL)containsString:(NSString *)sourceString targetString:(NSString*)targetString
{
    NSRange range = [[sourceString lowercaseString] rangeOfString:[targetString lowercaseString]];
    return range.location != NSNotFound;
}
- (JKMailListMangerModel *)getAmailListMangerModel
{
    if (!_mailListMangerModel)
    {
        if ([[TMCache sharedCache] objectForKey:mailListMangerModelSaveKey])
        {
            _mailListMangerModel = (JKMailListMangerModel *)[[TMCache sharedCache] objectForKey:mailListMangerModelSaveKey];
        }
        else
        {
            return nil;
        }
      
    }
    return _mailListMangerModel;
}

@end


@interface JKMailListMangerModel ()

@end

static NSString *modelDataArray = @"dataArray";
static NSString *modelMailListContainsLettersArray = @"mailListContainsLettersArray";
static NSString *modelMailListsArray = @"mailListsArray";

@implementation JKMailListMangerModel


- (id)init
{
    if (self = [super init])
    {
        self.mailListsArray = [NSMutableArray array];
        self.mailListContainsLettersArray = [NSMutableArray array];
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.dataArray = [aDecoder decodeObjectForKey:modelDataArray];
    self.mailListContainsLettersArray = [aDecoder decodeObjectForKey:modelMailListContainsLettersArray];
    self.mailListsArray = [aDecoder decodeObjectForKey:modelMailListsArray];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_dataArray forKey:modelDataArray];
    [aCoder encodeObject:_mailListContainsLettersArray forKey:modelMailListContainsLettersArray];
    [aCoder encodeObject:_mailListsArray forKey:modelMailListsArray];
}
- (id)copyWithZone:(NSZone *)zone
{
    JKMailListMangerModel *copy = [[JKMailListMangerModel alloc] init];
    
    if (copy)
    {
        
        copy.dataArray = [self.dataArray copyWithZone:zone];
        copy.mailListContainsLettersArray = [self.mailListContainsLettersArray copyWithZone:zone];
        copy.mailListsArray = [self.mailListsArray copyWithZone:zone];
    }
    return copy;
}

+ (void)saveModelToLocal:(JKMailListMangerModel *)aModel
{
    [[TMCache sharedCache] setObject:aModel forKey:mailListMangerModelSaveKey];
}

@end
