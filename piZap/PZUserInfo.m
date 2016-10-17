//
//  PZUserInfo.m
//  piZap
//
//  Created by Assure Developer on 6/13/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZUserInfo.h"

@implementation PZUserInfo

- (id)initWithJson:(id)jsonObj{
    self = [super init];
    if(self) {
        self.strCountryCode = [jsonObj objectForKey:@"CountryCode"];
        self.createdTimeStamp = [[jsonObj objectForKey:@"Created"] longValue];
        self.strFBUserId = [jsonObj objectForKey:@"FBUserId"];
        self.followerCount = [[jsonObj objectForKey:@"FollowerCount"] intValue];
        self.followingCount = [[jsonObj objectForKey:@"FollowingCount"] intValue];
        self.strGalleryStyle = [jsonObj objectForKey:@"GalleryStyle"];
        self.strGender = [jsonObj objectForKey:@"Gender"];
        self.strGooglePlusUserId = [jsonObj objectForKey:@"GooglePlusUserId"];
        self.lastLoginTimeStamp = [[jsonObj objectForKey:@"LastLogin"] longValue];
        self.nLikes = [[jsonObj objectForKey:@"Likes"] intValue];
        self.strName = [jsonObj objectForKey:@"Name"];
        self.numberPhotos = [[jsonObj objectForKey:@"NumberPhotos"] intValue];
        self.pointCount = [[jsonObj objectForKey:@"PointCount"] intValue];
        self.strProfileImageURL = [jsonObj objectForKey:@"ProfileImage"];
        self.strTagline = [jsonObj objectForKey:@"Tagline"];
        self.strTwitterUserId = [jsonObj objectForKey:@"TwitterUserId"];
        self.strUserName = [jsonObj objectForKey:@"UserName"];
        self.hasPassword = [[jsonObj objectForKey:@"hasPassword"] boolValue];
        self.strTumblrId = [jsonObj objectForKey:@"tumblrId"];
        
        if ([jsonObj objectForKey:@"token"]) {
            self.strToken = [jsonObj objectForKey:@"token"];
        }
        else{
            self.strToken = [[jsonObj objectForKey:@"fragment"] objectForKey:@"access_token"];
        }
        
        if ([jsonObj objectForKey:@"coinz"]) {
            self.coinz = [[jsonObj objectForKey:@"coinz"] intValue];
        }
        
        if ([jsonObj objectForKey:@"totalCoinz"]) {
            self.totalCoinz = [[jsonObj objectForKey:@"totalCoinz"] intValue];
        }
        
        if ([jsonObj objectForKey:@"Achievements"]) {   
            NSArray *arrayAchInfo = [jsonObj objectForKey:@"Achievements"];
            NSMutableArray *tmpArray = [NSMutableArray array];
            for (id achieveInfoObj in arrayAchInfo) {
                PZAchievementInfo *achieveInfo = [[PZAchievementInfo alloc] init];
                achieveInfo.strAchievementID = [achieveInfoObj objectForKey:@"AchievementID"];
                achieveInfo.completedTimeStamp = [[achieveInfoObj objectForKey:@"Completed"] longValue];
                achieveInfo.IsProgress = [[achieveInfoObj objectForKey:@"Progress"] boolValue];
                achieveInfo.startedTimeStamp = [[achieveInfoObj objectForKey:@"Started"] longValue];
                achieveInfo.strUserName = [achieveInfoObj objectForKey:@"UserName"];
                [tmpArray addObject:achieveInfo];
            }
            self.arrayAchievement = [NSArray arrayWithArray:tmpArray];
        }
    }
    return self;
}

@end
