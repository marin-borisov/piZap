//
//  PZUserInfo.h
//  piZap
//
//  Created by Assure Developer on 6/13/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZAchievementInfo.h"

@interface PZUserInfo : NSObject

@property (nonatomic, strong) NSString *strCountryCode;
@property                     long      createdTimeStamp;
@property (nonatomic, strong) NSString *strFBUserId;
@property                     int       followerCount;
@property                     int       followingCount;
@property (nonatomic, strong) NSString *strGalleryStyle;
@property (nonatomic, strong) NSString *strGender;
@property (nonatomic, strong) NSString *strGooglePlusUserId;
@property                     long      lastLoginTimeStamp;
@property                     int       nLikes;
@property (nonatomic, strong) NSString *strName;
@property                     int       numberPhotos;
@property                     int       pointCount;
@property (nonatomic, strong) NSString *strProfileImageURL;
@property (nonatomic, strong) NSString *strTagline;
@property (nonatomic, strong) NSString *strTwitterUserId;
@property (nonatomic, strong) NSString *strUserName;
@property                     BOOL      hasPassword;
@property (nonatomic, strong) NSString *strId;
@property (nonatomic, strong) NSString *strToken;
@property (nonatomic, strong) NSString *strTumblrId;
@property                     int       coinz;
@property                     int       totalCoinz;

@property (nonatomic, strong) NSArray *arrayAchievement;

- (id)initWithJson:(id)jsonObj;

@end
