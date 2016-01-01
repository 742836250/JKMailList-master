//
//  Linkman.h
//  JKMailList
//
//  Created by 王锐锋 on 15/12/24.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>

@interface JKLinkman : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *firstLetter;

@property (nonatomic, copy) NSString *chinese;

@property (nonatomic, copy) NSString *english;

@property (nonatomic, copy) NSMutableArray *phoneNumbers;

@property (nonatomic, strong) UIImage *headImage;

@property (nonatomic, assign) ABRecordID recordID;

@end
