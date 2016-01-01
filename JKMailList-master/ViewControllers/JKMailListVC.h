//
//  JKMailListVC.h
//  JKMailList
//
//  Created by 王锐锋 on 15/12/24.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKMailListVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchResultsUpdating,UISearchControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mailListTBView;

@property (nonatomic, strong) UIImage *clearImage;



@end
