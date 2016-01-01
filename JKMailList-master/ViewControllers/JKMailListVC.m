//
//  JKMailListVC.m
//  JKMailList
//
//  Created by 王锐锋 on 15/12/24.
//  Copyright © 2015年 jack_wang. All rights reserved.
//

#import "JKMailListVC.h"
#import "JKMailListManger.h"
#import "JKLinkman.h"
#import "JKIndexBarView.h"
#import "UIView+MBProgressHUD.h"
#import "JKMailListTBCell.h"
#import "UIViewController+ASWAlertView.h"
#import <AddressBook/AddressBook.h>
#import "MJRefresh.h"
#import "JKAddMailListView.h"


//屏幕宽度
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//屏幕高度
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface JKMailListVC ()<JKIndexBarViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) JKMailListMangerModel *mailListMangerModel;

@property (nonatomic, strong) NSMutableArray *searchedItems;

@property (nonatomic, strong) JKIndexBarView *indexBarView;

@property (nonatomic, strong) UISearchBar *jkSearchBar;

@property (nonatomic, strong) UILabel *indexLabe;

@property (nonatomic, assign) ABAddressBookRef addressBook;

@property (nonatomic, copy) NSArray *myContacts;

@property (nonatomic, assign) BOOL handelAddressBookChanged;

@property (nonatomic, strong) JKAddMailListView *addMailListView;

@property (nonatomic, assign) UIImagePickerControllerSourceType imagePickeSourceType;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, assign) ABRecordRef clickedRecordRef;

@end

static NSString *cellIdentifier = @"cellIdentifier";

@implementation JKMailListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self setUpSubViews];
    
    self.handelAddressBookChanged = NO;
    
    self.addressBook = ABAddressBookCreate();
    //注册通讯录更新回调
    ABAddressBookRegisterExternalChangeCallback(self.addressBook, addressBookChanged, (__bridge void *)(self));
    if ([self checkAddressBookAuthorizationStatus:nil])
    {
        [self prepareDataAndReloadSubViewsWithSynchronous:NO completeCallBack:nil];
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }  
}
- (void)applicationDidBecomeActiveNotification:(NSDictionary *)dic
{
    self.handelAddressBookChanged = YES;
    NSLog(@"dic = %@",dic);
}
- (void)setUpSubViews
{
    self.title = @"通讯录";
    self.navigationController.delegate = self;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""]forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMailListBtnClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.mailListTBView registerNib:[UINib nibWithNibName:@"JKMailListTBCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    self.mailListTBView.tableFooterView = [[UIView alloc] init];
    
    __weak JKMailListVC *weakSelf = self;
    [self.mailListTBView addHeaderWithCallback:^{
        
        if (!weakSelf.searchController.active)
        {
            [weakSelf prepareDataAndReloadSubViewsWithSynchronous:YES completeCallBack:^{
                
                [weakSelf.mailListTBView headerEndRefreshing];
            }];
        }
        else
        {
            [weakSelf.mailListTBView headerEndRefreshing];
        }
    }];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.mailListTBView.tableHeaderView = self.searchController.searchBar;
   
    self.indexBarView = [[JKIndexBarView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -20, 64+150, 20, SCREEN_HEIGHT-64-150*2)];
    self.indexBarView.delegate = self;
    self.indexBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.indexBarView];
    
    self.indexLabe = [[UILabel alloc] init];
    self.indexLabe.bounds = CGRectMake(0, 0, 80, 80);
    self.indexLabe.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    self.indexLabe.layer.cornerRadius = 4;
    self.indexLabe.clipsToBounds = YES;
    self.indexLabe.backgroundColor = [UIColor blackColor];
    self.indexLabe.textAlignment = NSTextAlignmentCenter;
    self.indexLabe.textColor = [UIColor whiteColor];
    self.indexLabe.font = [UIFont systemFontOfSize:30];
    self.indexLabe.hidden = YES;
    [self.view addSubview:self.indexLabe];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[viewController class]])
    {
        [self.navigationController.navigationBar setBackgroundImage:self.clearImage forBarMetrics:UIBarMetricsDefault];
        [self.mailListTBView setContentOffset:CGPointMake(0, -64) animated:NO];
    }
    else if ([viewController isKindOfClass:[self class]])
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""]forBarMetrics:UIBarMetricsDefault];
    }
    
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""]forBarMetrics:UIBarMetricsDefault];
}
- (void)prepareDataAndReloadSubViewsWithSynchronous:(BOOL)synchronous completeCallBack:(void(^)())completeCallBack;
{
    self.myContacts = [NSArray arrayWithArray:(__bridge_transfer NSArray*)
                       ABAddressBookCopyArrayOfAllPeople(self.addressBook)];
    BOOL showTime = NO;
    if (synchronous)
    {
        [self.view showActivityWithText:@"排序中"];
        showTime = YES;
    }
    else
    {
        if (![[JKMailListManger sharedManager] getAmailListMangerModel])
        {
            [self.view showActivityWithText:@"排序中"];
            showTime = YES;
        }
        else
        {
            showTime = NO;
        }
    }
    NSDate* tmpStartData = [NSDate date];
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        weakSelf.mailListMangerModel = [[JKMailListManger sharedManager] mailListsWith:weakSelf.myContacts synchronous:synchronous];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
            if (showTime)
            {
                [weakSelf.view showActivityWithText:[NSString stringWithFormat:@"本次数据%lu条耗时%.2fs,感谢您的使用!", (unsigned long)weakSelf.mailListMangerModel.dataArray.count,deltaTime]];
                [weakSelf performSelector:@selector(delayHideActivity) withObject:nil afterDelay:1.5];
            }
            else
            {
                [self delayHideActivity];
            }
            [weakSelf.mailListTBView reloadData];
            if (completeCallBack)
            {
                completeCallBack ();
            }
        });
        
    });
}
- (void)delayHideActivity
{
    [self.view hideActivity];
}
void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void* context)
{
    NSLog(@"Address Book Changed %@",info);
    JKMailListVC *viewController = objc_unretainedObject(context);
    if (!viewController.handelAddressBookChanged)
    {
        return;
    }
    [viewController prepareDataAndReloadSubViewsWithSynchronous:YES completeCallBack:^{
        
        viewController.handelAddressBookChanged = NO;
        
    }];
    
}
-(BOOL)checkAddressBookAuthorizationStatus:(UITableView*)tableView;
{
    //取得授权状态
    ABAuthorizationStatus authStatus =
    ABAddressBookGetAuthorizationStatus();
    
    if (authStatus != kABAuthorizationStatusAuthorized)
    {
        ABAddressBookRequestAccessWithCompletion
        (self.addressBook, ^(bool granted, CFErrorRef error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (error)
                     NSLog(@"Error: %@", (__bridge NSError *)error);
                 else if (!granted) {
                     UIAlertView *av = [[UIAlertView alloc]
                                        initWithTitle:@"Authorization Denied"
                                        message:@"Set permissions in Settings>General>Privacy."
                                        delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"OK", nil];
                     [av show];
                 }
                 else
                 {
                     //还原 ABAddressBookRef
                     ABAddressBookRevert(self.addressBook);
                     [self prepareDataAndReloadSubViewsWithSynchronous:NO completeCallBack:nil];
                 }
             });
         });
    }
    return authStatus == kABAuthorizationStatusAuthorized;
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.searchController.active?1:self.mailListMangerModel.mailListsArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return self.searchedItems.count;
    }
    else
    {
      
        NSDictionary *dic = [self.mailListMangerModel.mailListsArray objectAtIndex:section];
        if (dic&&dic.count>0)
        {
            return [[dic objectForKey:[dic allKeys][0]] count];
        }
        return 0;

    }
  
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JKMailListTBCell *cell = (JKMailListTBCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    JKLinkman *man = [[JKLinkman alloc] init];
    if (self.searchController.active)
    {
        man = [self.searchedItems objectAtIndex:indexPath.row];
    }
    else
    {
        NSDictionary *dic = [self.mailListMangerModel.mailListsArray objectAtIndex:indexPath.section];
        man = [dic objectForKey:[dic allKeys][0]][indexPath.row];
    }
    cell.nameLab.text = man.chinese;
    if (man.phoneNumbers&&man.phoneNumbers.count>0)
    {
        [cell.phoneBtn setTitle:man.phoneNumbers[0] forState:UIControlStateNormal];
        [cell.phoneBtn setTitle:man.phoneNumbers[0] forState:UIControlStateHighlighted];

    }
    else
    {
        [cell.phoneBtn setTitle:@"" forState:UIControlStateNormal];
        [cell.phoneBtn setTitle:@"" forState:UIControlStateHighlighted];
    }
    if (man.headImage)
    {
        cell.headImageView.image = man.headImage;
    }
    else
    {
        cell.headImageView.image = [UIImage imageNamed:@"ic_personalinfo_n"];
    }
    __weak JKMailListVC *weakSelf = self;
    cell.headImageViewCallBack = ^(){
        if (!weakSelf.searchController.active)
        {
            ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
            weakSelf.clickedRecordRef = ABAddressBookGetPersonWithRecordID (tmpAddressBook, man.recordID);
            UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                            initWithTitle:nil
                                            delegate:weakSelf
                                            cancelButtonTitle:@"取消"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles: @"拍照", @"从相册中选取",nil];
            [myActionSheet showInView:weakSelf.view];

        }
        
    };
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return @"";
    }
    else
    {
        NSDictionary *dic = [self.mailListMangerModel.mailListsArray objectAtIndex:section];
        return [[dic allKeys]objectAtIndex:0];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JKMailListTBCell cellHeight];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JKLinkman *man = [[JKLinkman alloc] init];
    if (self.searchController.active)
    {
        man = [self.searchedItems objectAtIndex:indexPath.row];
    }
    else
    {
        NSDictionary *dic = [self.mailListMangerModel.mailListsArray objectAtIndex:indexPath.section];
        man = [dic objectForKey:[dic allKeys][0]][indexPath.row];
    }
    if (man.phoneNumbers&&man.phoneNumbers.count>0)

    {
        [self.searchController.active?self.searchController:self showCancelAndConfirmAlertWithTitle:@"拨打电话" message:man.phoneNumbers[0] cancelButtonTitle:@"取消" confirmButtonTitle:@"确定" cancel:nil confirm:^{
            NSString *openPhoneStr = [NSString stringWithFormat:@"tel://%@",man.phoneNumbers[0]];
            NSURL *openPhoneURL = [NSURL URLWithString:openPhoneStr];
            if ([[UIApplication sharedApplication] canOpenURL:openPhoneURL])
            {
                [[UIApplication sharedApplication] openURL:openPhoneURL];
            }
            
        }];
    }
   
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return  self.searchController.active?NO:YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.searchController.active)
    {
        NSDictionary *dic = [self.mailListMangerModel.mailListsArray objectAtIndex:indexPath.section];
        JKLinkman *man = [dic objectForKey:[dic allKeys][0]][indexPath.row];
        ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
        self.clickedRecordRef = ABAddressBookGetPersonWithRecordID (tmpAddressBook, man.recordID);
    }
    return  self.searchController.active?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.searchController.active)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSDictionary *dic = [self.mailListMangerModel.mailListsArray objectAtIndex:indexPath.section];
            JKLinkman *man = [dic objectForKey:[dic allKeys][0]][indexPath.row];
            [self showCancelAndConfirmAlertWithTitle:@"删除该联系人" message:man.chinese cancelButtonTitle:@"取消" confirmButtonTitle:@"删除" cancel:^{
                
                [tableView setEditing:NO];
                
            } confirm:^{
                
                [self DeletePeopleWithName:man.chinese];
            }];
          
           
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.searchController.searchBar isFirstResponder])
    {
        [self.searchController.searchBar resignFirstResponder];
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""]forBarMetrics:UIBarMetricsDefault];
}
#pragma mark UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (!self.searchController.searchBar.showsCancelButton)
    {
        [self.searchController.searchBar setShowsCancelButton:YES];
        for(UIView *view in  [[[self.searchController.searchBar subviews] objectAtIndex:0] subviews])
        {
            
            if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
                UIButton * cancel =(UIButton *)view;
                [cancel setTitle:@"取消" forState:UIControlStateNormal];
                [cancel  setTintColor:[UIColor blackColor]];
                [cancel.titleLabel setTextColor:[UIColor blackColor]];
            }
        }

    }
    if (self.searchedItems&&self.searchedItems.count>0)
    {
        [self.searchedItems removeAllObjects];
    }
    //过滤数据
    NSString *searchString = [self.searchController.searchBar text];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"chinese CONTAINS[cd] %@",searchString];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"english BEGINSWITH[cd] %@",searchString];
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate1, predicate2]];
    NSMutableArray *dataArray = [self.mailListMangerModel.dataArray mutableCopy];
    NSArray *resultArray = [dataArray filteredArrayUsingPredicate:predicate];
    self.searchedItems = [resultArray mutableCopy];
    //刷新表格
    [self.mailListTBView reloadData];
}
#pragma mark UISearchControllerDelegate
- (void)willPresentSearchController:(UISearchController *)searchController
{
    self.indexBarView.hidden = YES;
}
- (void)willDismissSearchController:(UISearchController *)searchController
{
    self.indexBarView.hidden = NO;
}
#pragma mark JKIndexBarViewDelegate
- (void)viewTouch:(JKIndexBarView *)view letter:(NSString *)letter
{
    if ([letter isEqualToString:@"🔍"])
    {
        [self.mailListTBView setContentOffset:CGPointMake(0, -64) animated:NO];
    }
    if ([self.mailListMangerModel.mailListContainsLettersArray containsObject:letter])
    {
         NSInteger idx = [self.mailListMangerModel.mailListContainsLettersArray indexOfObject:letter];
         [self.mailListTBView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    self.indexLabe.text = letter;
    self.indexLabe.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""]forBarMetrics:UIBarMetricsDefault];
}
- (void)viewTouchEnd:(JKIndexBarView *)view
{
    self.indexLabe.hidden = YES;
}
- (void)addMailListBtnClick:(UIBarButtonItem *)barBtnItem
{
     __weak JKMailListVC *weakSelf = self;
    [JKAddMailListView showWithFirstTFPlaceholder:@"姓氏" secondTFPlaceholder:@"名字" thirdTFPlaceholder:@"电话" title:@"添加联系人" cancelBtnTitle:@"取消" sureBtnTitle:@"添加" cancelCallBack:^{
        
    } sureCallBack:^(NSString *str1,NSString *str2,NSString *str3) {
        
        [weakSelf AddPeopleWithFirstName:str2 lastName:str1 phoneNum:str3];
        
    }];
}
//新增联系人
-(void)AddPeopleWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phoneNum:(NSString *)phoneNum
{
    //取得本地通信录名柄
    ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
    //创建一条联系人记录
    ABRecordRef tmpRecord = ABPersonCreate();
    
    CFErrorRef error;
    BOOL tmpSuccess = NO;
    //Nickname
//    CFStringRef tmpNickname = CFSTR();
//    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonNicknameProperty, tmpNickname, &error);
//    CFRelease(tmpNickname);
    //First name
    CFStringRef tmpFirstName = (__bridge CFStringRef)(firstName);
    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonFirstNameProperty, tmpFirstName, &error);
    //CFRelease(tmpFirstName);
    //Last name
    CFStringRef tmpLastName = (__bridge CFStringRef)(lastName);
    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonLastNameProperty, tmpLastName, &error);
    //CFRelease(tmpLastName);
    //phone number
    CFTypeRef tmpPhones = (__bridge CFTypeRef)(phoneNum);
    ABMultiValueRef tmpMutableMultiPhones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    //ABMutableMultiValueRef tmpMutableMultiPhones = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(tmpMutableMultiPhones, tmpPhones, kABPersonPhoneMobileLabel, NULL);
    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonPhoneProperty, tmpMutableMultiPhones, &error);
    //CFRelease(tmpPhones);
    
    self.handelAddressBookChanged = YES;
    
    //保存记录
    tmpSuccess = ABAddressBookAddRecord(tmpAddressBook, tmpRecord, &error);
    CFRelease(tmpRecord);
    //保存数据库
    tmpSuccess = ABAddressBookSave(tmpAddressBook, &error);
    CFRelease(tmpAddressBook);
}
//删除联系人
-(void)DeletePeopleWithName:(NSString *)name
{
    //取得本地通信录名柄
    ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
    //NSArray* tmpPersonArray = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    ABAddressBookRemoveRecord(tmpAddressBook,self.clickedRecordRef, nil);
    self.handelAddressBookChanged = YES;
    //保存电话本
    ABAddressBookSave(tmpAddressBook, nil);
    //释放内存
    CFRelease(tmpAddressBook);
}

- (void)changePeopleImageData:(NSData *)imageData
{
    ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
    CFErrorRef error;
    BOOL tmpSuccess = NO;
    self.handelAddressBookChanged = YES;
    if (ABPersonHasImageData(self.clickedRecordRef))
    {
        tmpSuccess = ABPersonRemoveImageData(self.clickedRecordRef, &error);
        tmpSuccess = ABPersonSetImageData(self.clickedRecordRef, (__bridge CFDataRef)(imageData), &error);
    }
    else
    {
         tmpSuccess = ABPersonSetImageData(self.clickedRecordRef, (__bridge CFDataRef)(imageData), &error);
    }
    //保存记录
    tmpSuccess = ABAddressBookAddRecord(tmpAddressBook, self.clickedRecordRef, &error);
    //保存数据库
    tmpSuccess = ABAddressBookSave(tmpAddressBook, &error);
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self takePhoto];
    }
    else if (buttonIndex == 1)
    {
        [self LocalPhoto];
    }
}
//从相册选择
-(void)LocalPhoto
{
    if (!self.imagePickerController)
    {
        self.imagePickerController = [[UIImagePickerController alloc] init];
    }
    //资源类型为图片库
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickerController.delegate = self;
    //设置选择后的图片可被编辑
    self.imagePickerController.allowsEditing = YES;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
//拍照
-(void)takePhoto
{
    //判断是否有相机
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        if (!self.imagePickerController)
        {
            self.imagePickerController = [[UIImagePickerController alloc] init];
        }
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.delegate = self;
        //设置拍照后的图片可被编辑
        self.imagePickerController.allowsEditing = YES;
        //资源类型为照相机
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
        
    }
    else
    {
        
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //右拍 UIImageOrientationUp
    //竖拍 UIImageOrientationRight
    //左拍 UIImageOrientationDown
    //倒拍 UIImageOrientationLeft
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImageWriteToSavedPhotosAlbum(portraitImg, self, nil, nil);// 保存图片
    }
    portraitImg = [self fixOrientation:portraitImg];
    NSData *imageData;
    if (UIImagePNGRepresentation(portraitImg) == nil)
    {
        
        imageData = UIImageJPEGRepresentation(portraitImg, 0.2);
        
    } else
    {
        
        imageData = UIImagePNGRepresentation(portraitImg);
    }
    [self changePeopleImageData:imageData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)fixOrientation:(UIImage *)aImage
{
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
- (void)dealloc
{
    NSLog(@"%@ has been released",[self class]);
    //注销通讯录更新回调
    ABAddressBookUnregisterExternalChangeCallback(self.addressBook, addressBookChanged, (__bridge void *)(self));
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
