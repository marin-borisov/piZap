//
//  PZUserShortInfo.h
//  piZap
//
//  Created by Assure Developer on 8/3/15
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PZUserShortInfo : NSObject

@property (nonatomic, strong) NSString *strUsername;

@property (nonatomic, strong) NSString *strName;

@property BOOL isFollowing;

@property (nonatomic, strong) NSString *strProfileImageURL;


@end
