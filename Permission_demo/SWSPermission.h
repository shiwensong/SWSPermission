//
//  Permission.h
//  Permission_demo
//
//  Created by NetClue on 16/3/30.
//  Copyright © 2016年 Shiwensong. All rights reserved.
//





#define GetPermission(type) ([[Permission sharePermission] useGetPermissionTypeToMethod:type]);

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h> //  照相机使用的框架 （内含媒体类型）
#import <AVFoundation/AVFoundation.h> // 照相机使用的框架
#import <AssetsLibrary/AssetsLibrary.h> // 相册使用的框架
#import <AddressBook/AddressBook.h>    // 照相机使用的框架
#import <MapKit/MapKit.h>   //地图使用的框架

@class SystemPhotoValues;
/*!
 *  @brief 获取权限的类型
 */
typedef NS_ENUM(NSUInteger, SWKGetPermissionType) {
    /*!
     *  照相机
     */
    SWKGetPermissionType_isCamera = 1,
    /*!
     *  特殊类型
     */
    //    KGetPermissionType_isMicrophone,
    /*!
     *  相册
     */
    SWKGetPermissionType_isPhotoAlbum,
    /*!
     *  通讯录
     */
    SWKGetPermissionType_isAddressBook,
    /*!
     *  定位服务
     */
    SWKGetPermissionType_isLocation
};
@interface SWSPermission : NSObject

/*!
 *  @brief 单例（返回权限访问对象）
 *
 *  @return <#return value description#>
 */
+ (instancetype)sharePermission;


/*!
 *  @brief 获取麦克风的权限  （这是特殊情况）
 *
 *  @param block 回调的block， 这个block的返回值是 NSNumber ，里面的值是:  @(BOOL)
 */
- (void)getMicrophonePermission:(void(^)(id info)) block;


/*!
 *  @brief 统一调用的接口
 *
 *  @param type <#type description#>
 */
- (BOOL)useGetPermissionTypeToMethod:(SWKGetPermissionType)type ;


/*!
 *  @brief 保存图片到相册中去
 *
 *  @param values    <#values description#>
 *  @param backBlock <#backBlock description#>
 */
-(void)saveLibrayToImage:(SystemPhotoValues *)values backBlcok:(void (^)(BOOL flag, id info))backBlock ;

/**
 *  显示 图片选择器
 *
 *  @param vc <#vc description#>
 */
-(void)showPhotoWithVC:(UIViewController*)vc withBlock:(void(^)(UIImage *image))chooseImageBlock;

//图片是否能编辑
@property (assign,nonatomic) BOOL canEidit;

//图片导航栏颜色
@property (strong,nonatomic) UIColor *navColor;



/***************************************  Property  *************************************************/

/*!
 *  @brief  取消的文字
 */
@property (copy, nonatomic) NSString *cancleString;

/*!
 *  @brief 在 iOS 系统上的按钮文字
 */
@property (copy, nonatomic) NSString *cancleStringIniOS7;

/*!
 *  @brief  设置的文字
 */
@property (copy, nonatomic) NSString *settingString;

/*!
 *  @brief  提示title的文字
 */
@property (copy, nonatomic) NSString *alertString;


/*!
 *  @brief 照相机的提示去设置的文字
 */
@property (copy, nonatomic) NSString *camerMessageTitle;

/*!
 *  @brief 麦克风的提示去设置的文字
 */
@property (copy, nonatomic) NSString *microPhoneMessageTitle;

/*!
 *  @brief 相册的提示去设置的文字
 */
@property (copy, nonatomic) NSString *photoAlbumMessageTitle;

/*!
 *  @brief 通讯录的提示去设置的文字
 */
@property (copy, nonatomic) NSString *addressBookMessageTitle;

/*!
 *  @brief 定位服务的提示去设置的文字
 */
@property (copy, nonatomic) NSString *locationMessageTitle;

@end


/***************************  SystemPhotoValues   *****************************************/

@interface SystemPhotoValues : NSObject

/*!
 *  @brief 传入要保存的image对象
 */
@property (strong,nonatomic) UIImage * image;

/*!
 *  @brief 自定义保存图片失败后的返回提示语
 */
@property (copy,nonatomic) NSString * error;

/*!
 *  @brief 自定义保存图片成功后的返回提示语
 */
@property (copy,nonatomic) NSString * success;

@end
