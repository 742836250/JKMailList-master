//
//  JKMailListManger.h
//  JKMailList
//
//  Created by 王锐锋 on 15/12/24.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JKMailListMangerModel;

@interface JKMailListManger : NSObject

@property (nonatomic, strong) JKMailListMangerModel *mailListMangerModel;

+ (instancetype)sharedManager;

- (JKMailListMangerModel *)getAmailListMangerModel;

- (JKMailListMangerModel *)mailListsWith:(NSArray *)rawDataArray synchronous:(BOOL)synchronous;

- (NSString *)translateInToEnglishWithString:(NSString *)aString;

- (NSString *)firstCapitalizationLetterWithLanguageUnknownString:(NSString *)aString;

- (NSString *)firstCapitalizationLetterWithEnglishString:(NSString *)aString;



@end

@interface JKMailListMangerModel : NSObject <NSCoding, NSCopying>

/**
 *  按顺序排好的数组(未进行A D C D 分组)
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *   数据中转化为拼音首字母数组(内容为 A B C D)
 */
@property (nonatomic, strong) NSMutableArray *mailListContainsLettersArray;
/**
 *   按顺序排好的数组(已进行A D C D 分组)
 */
@property (nonatomic, strong) NSMutableArray *mailListsArray;

+ (void)saveModelToLocal:(JKMailListMangerModel *)aModel;


@end
