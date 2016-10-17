//
//  PZClickableLabelForUsername.h
//  piZap
//
//  Created by Assure Developer on 7/30/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PZClickableLabelForUsername : UILabel

@property (nonatomic, strong) NSString *strUsername;

- (id)initWithFont:(UIFont*)font andUsername:(NSString *)strUsername;

@end
