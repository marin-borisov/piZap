//
//  AppData.h
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "PZUserInfo.h"
#import "PZSecondTabbarVC.h"
#import "PZFirstTabBarVC.h"

@interface AppData : NSObject

//@property (strong, nonatomic) NSString *userAccessToken;
@property (strong, nonatomic) NSString *userRefreshToken;
@property (strong, nonatomic) PZUserInfo  *me;
@property (strong, nonatomic) PZFirstTabBarVC *firstTabBarVC;
@property (strong, nonatomic) PZSecondTabbarVC *mainTabBarVC;
@property (strong, nonatomic) id assetsJsonObj;

@property (strong, nonatomic) NSMutableArray *arrayTmpImages;
@property (strong, nonatomic) NSMutableArray *arrayFonts;

@property double latitude;
@property double longitude;
@property BOOL   isLoggedIn;
@property BOOL   isEditableCollage;
@property BOOL   isEditableLayoutCollage;

+ (AppData *)appData;

- (NSString *)username;
- (void)setUsername:(NSString *)username;

- (NSString *)firstname;
- (void)setFirstname:(NSString *)firstname;

- (NSString *)lastname;
- (void)setLastname:(NSString *)lastname;

- (NSString *)userAccessToken;
- (void)setUserAccessToken:(NSString*)userAccessToken;

- (void)goToLoggedInVC;

- (void)loggedOut;

- (BOOL)loadAssetJSON;

- (CGFloat)getActualFontSizeForLabel:(UILabel *)label;

- (NSString *)getBaseUrl;
- (BOOL)wifiAvaiable;

+ (BOOL)isFieldEmpty:(UITextField *)field;
+ (BOOL)isFieldEmail:(UITextField *)field;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image width:(float)newWidth;
+ (UIImage *)imageWithImage:(UIImage *)image height:(float)newHeight;
+ (UIImage *)imageWithImage:(UIImage *)image withSize:(CGSize)newSize;

+ (NSString *)fixURLForPizap:(NSString*)url;

+ (NSString *)urlForUserPhoto:(NSString*)username;



@end
