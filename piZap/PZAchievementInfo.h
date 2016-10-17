//
//  PZAchievementInfo.h
//  piZap
//
//  Created by Assure Developer on 6/13/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PZAchievementInfo : NSObject

@property (nonatomic, strong) NSString *strAchievementID;

@property (nonatomic, strong) NSString *strUserName;

@property long completedTimeStamp;

@property long startedTimeStamp;

@property BOOL IsProgress;

@end
