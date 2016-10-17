//
//  PZClickableLabelForUsername.m
//  piZap
//
//  Created by Assure Developer on 7/30/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZClickableLabelForUsername.h"

@implementation PZClickableLabelForUsername

- (id)init
{
    return [self initWithFont:[UIFont fontWithName:@"Futura-Medium" size:12.f] andUsername:@""];
}


- (id)initWithFont:(UIFont*)font andUsername:(NSString *)strUsername{
    self = [super init];
    
    if (self) {
        self.font = font;
        self.strUsername = strUsername;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
