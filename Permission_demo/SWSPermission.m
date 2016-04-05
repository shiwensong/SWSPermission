//
//  Permission.m
//  Permission_demo
//
//  Created by NetClue on 16/3/30.
//  Copyright © 2016年 Shiwensong. All rights reserved.
//


#define SWKSystemVersion  [[[UIDevice currentDevice] systemVersion] floatValue]
#define SWKChooseImageActionSheetTag 100


#import "SWSPermission.h"
#import "UIAlertView+BlocksKit.h"

@interface SWSPermission () <UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (assign, nonatomic) SWKGetPermissionType type;

/*!
 *  @brief 保存图片回调的block
 */
@property (copy, nonatomic) id backBlock;

@property (strong, nonatomic) SystemPhotoValues *systemPhotoValues;

/*!
 *  @brief 保存图片需要临时保存VC
 */
@property (weak, nonatomic) UIViewController *currentVC;
/*!
 *  @brief 选择图片回调的block
 */
@property (copy, nonatomic) id chooseImageBlock;


@end

@implementation SWSPermission

/*!
 *  @brief 单例（返回权限访问对象）
 *
 *  @return <#return value description#>
 */
+ (instancetype)sharePermission{
    
    static SWSPermission *permission = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        permission = [[SWSPermission alloc] init];
        
    });
    return permission;
}


- (instancetype)init{
    
    self = [super init];
    if (self) {
        [self setDefalutValue];
        
        
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"内存释放--%@",NSStringFromClass([self class]) );
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


#pragma mark - Private

/*!
 *  @brief 设置默认值的属性值s
 */
- (void)setDefalutValue{
    
    self.cancleString = @"取消";
    self.cancleStringIniOS7 = @"知道了";
    self.settingString = @"设置";
    self.alertString = @"提示信息";
    self.camerMessageTitle = @"请在设备的 设置-隐私-相机 中允许访问照相机。";
    self.microPhoneMessageTitle = @"请在设备的 设置-隐私-麦克风 中允许访问麦克风。";
    self.photoAlbumMessageTitle = @"请在设备的 设置-隐私-相册 中允许访问相册。";
    self.addressBookMessageTitle = @"请在设备的 设置-隐私-通讯录 中允许访问通讯录。";
    self.locationMessageTitle = @"请在设备的 设置-隐私-定位服务 中允许访问定位服务。";
    
}

/*!
 *  @brief 这里显示我们要弹出的提示语 （麦克风除外，因为类型不存在）
 *
 *  @return <#return value description#>
 */
- (NSString*)alertMessage{
    
    // 说明： 其他的麦克风没有卸载这里面，因为他是特殊类型的，type中没有麦克风的类型
    switch (self.type) {
        case SWKGetPermissionType_isCamera: {
            return self.camerMessageTitle;
            break;
        }
        case SWKGetPermissionType_isPhotoAlbum: {
            return self.photoAlbumMessageTitle;
            break;
        }
        case SWKGetPermissionType_isAddressBook: {
            return self.addressBookMessageTitle;
            break;
        }
        case SWKGetPermissionType_isLocation: {
            return self.locationMessageTitle;
            break;
        }
    }
    
}

/*!
 *  @brief 统一弹出 UIAlertView，
 *
 *  @param isCustomAlertMessageString 用来确定是否需要自定义提示语
 *  @param alertMessage               如果需要自定义提示语，那么需要传入提示语的字符串
 */
- (void)showAlertViewIsCustomString:(BOOL)isCustomAlertMessageString alertMessage:(NSString *)alertMessage {
    
    if (isCustomAlertMessageString == YES) {
        NSAssert(alertMessage.length>0, @"alertMessage can't nil");
    }
    NSString *cancle = self.cancleString;
    NSArray * others = @[self.settingString];
    
    if (SWKSystemVersion < 8.0) {
        cancle = self.cancleStringIniOS7;
        others = nil;
    }
    NSString *alertString = nil;
    if (isCustomAlertMessageString == YES) {
        alertString = alertMessage;
    }else{
        alertString = [self alertMessage];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

    UIAlertView * alertView = [UIAlertView bk_showAlertViewWithTitle:self.alertString message:alertString cancelButtonTitle:cancle otherButtonTitles:others handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
#pragma clang diagnostic pop

    [alertView show];
}


/*!
 *  @brief 获取照相机的权限
 *
 *  @return <#return value description#>
 */
- (BOOL)getCameraPermissions{
    
    self.type = SWKGetPermissionType_isCamera;
        
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [self showAlertViewIsCustomString:NO alertMessage:nil];
        return NO;
    }else {
        return YES;
    }
}


/*!
 *  @brief 获取相册权限
 *
 *  @return <#return value description#>
 */
- (BOOL)getPhotoAlbumPermission{
    
    self.type = SWKGetPermissionType_isPhotoAlbum;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        [self showAlertViewIsCustomString:NO alertMessage:nil];
        return NO;
    }else {
        return YES;
    }
#pragma clang diagnostic pop

}

/*!
 *  @brief 获取通讯录权限
 *
 *  @return <#return value description#>
 */
- (BOOL)getAddressBookPermission{
    self.type = SWKGetPermissionType_isAddressBook;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined || status == kABAuthorizationStatusDenied) {
#pragma clang diagnostic pop

        [self showAlertViewIsCustomString:NO alertMessage:nil];
        
        return NO;
    
    }else{
        return YES;
    }
    

}

/*!
 *  @brief 获取地图定位权限
 *
 *  @return <#return value description#>
 */
- (BOOL)getLocationPermission{

    self.type = SWKGetPermissionType_isLocation;

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        
        [self showAlertViewIsCustomString:NO alertMessage:nil];
        
        return YES;
    }else{
        return NO;
    }
}




/*!
 *  @brief 获取麦克风权限  (这是特殊情况)
 */
- (void)getMicrophonePermission:(void(^)(id info)) block{
    //检测麦克风功能是否打开
    
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted){
            [self showAlertViewIsCustomString:YES alertMessage:self.microPhoneMessageTitle];
        }else{
            
            NSLog(@"获取了权限");
            
        }
        
        if (block) {
            block(@(granted));
        }
    }];
}

#pragma mark - Public

- (BOOL)useGetPermissionTypeToMethod:(SWKGetPermissionType)type {
    
    switch (type) {
        case SWKGetPermissionType_isCamera: {
            return [self getCameraPermissions];
            break;
        }
        case SWKGetPermissionType_isPhotoAlbum: {
            return [self getPhotoAlbumPermission];
            break;
        }
        case SWKGetPermissionType_isAddressBook: {
            return [self getAddressBookPermission];
            break;
        }
        case SWKGetPermissionType_isLocation: {
            return [self getLocationPermission];
            break;
        }
    }
}


#pragma mark - SaveImageToLibray(保存图片)

-(void)saveLibrayToImage:(SystemPhotoValues *)values backBlcok:(void (^)(BOOL flag, id info))backBlock {
    self.backBlock = backBlock;
    self.systemPhotoValues = values;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied)
    {
    
        
        NSString *cancle =@"取消";
        NSArray * others = @[@"设置"];
        
        if (SWKSystemVersion < 8.0) {
            cancle = @"知道了";
            others = nil;
        }
        
        UIAlertView * test = [UIAlertView bk_showAlertViewWithTitle:@"存储失败" message:@"请打开 设置-隐私-照片 来进行设置" cancelButtonTitle:cancle otherButtonTitles:others handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex==1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [test show];
#pragma clang diagnostic pop
  
    }
    else{

        UIImageWriteToSavedPhotosAlbum(values.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{

    void(^backBlock)(BOOL, id) = self.backBlock;

    if (error) {
        // 保存失败
        if (backBlock) {
            if (self.systemPhotoValues.error.length > 0) {
                backBlock(NO, [NSString stringWithFormat:@"%@ == %@", self.systemPhotoValues.error,[error localizedDescription]]);
            }else {
                backBlock(NO, [NSString stringWithFormat:@"保存图片失败! == %@",[error localizedDescription]]);
            }
        }
        
    }else {
        // 保存成功
        if (backBlock) {
            if (self.systemPhotoValues.success.length > 0) {
                backBlock(YES, self.systemPhotoValues.success);
            }else{
                backBlock(YES, @"保存图片成功!");
            }
        }
    }
}

#pragma mark - ChooseImage (选取图片)

- (void)showPhotoWithVC:(UIViewController *)vc withBlock:(void (^)(UIImage *))chooseImageBlock
{
    NSLog(@"Current method: %@ %@",[self class],NSStringFromSelector(_cmd));
    if (chooseImageBlock) {
        self.chooseImageBlock = chooseImageBlock;
        
    }
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [window endEditing:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    UIActionSheet * action=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择相机",@"选择相册", nil];
#pragma clang diagnostic pop

    action.tag = SWKChooseImageActionSheetTag;
    [action showInView:window];
    self.currentVC=vc;
}

//FIXME: - UIActionSheetDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    

    if (actionSheet.tag == SWKChooseImageActionSheetTag ) {
        
        UIImagePickerControllerSourceType sourceType =UIImagePickerControllerSourceTypeCamera;
        
        if (buttonIndex==0) {
            
            if (![self getCameraPermissions]) {
                return;
            }
            
            sourceType=UIImagePickerControllerSourceTypeCamera ;
            
        }
        else if (buttonIndex==1){
            if (![self getPhotoAlbumPermission]) {
                return;
            }
            sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            
        }
        
        if (buttonIndex!=2) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
            
            if (self.navColor) {
                
                [picker.navigationBar setBackgroundImage:[UIImage imageNamed:@"123页眉背景"] forBarMetrics:UIBarMetricsDefault];
                
                
            }
            picker.delegate = self;
            picker.allowsEditing = self.canEidit;//设置可编辑
            picker.sourceType = sourceType;
            picker.navigationBar.tintColor = [UIColor whiteColor];
            [picker.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
            
            [self.currentVC presentViewController:picker animated:YES completion:nil];//进入照相界面
            picker=nil;
            
        }
        
    }
}
#pragma clang diagnostic pop


//FIXME: - UINavigationControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picke didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.canEidit) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    if (self.chooseImageBlock) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
#pragma clang diagnostic pop

        void (^chooseImage)(UIImage*image) = self.chooseImageBlock;
        chooseImage(image);
    }
    [picke dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
#pragma clang diagnostic pop

    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end


/*************************** SystemPhotoValues的实现  ************************************/
@implementation SystemPhotoValues

@end
