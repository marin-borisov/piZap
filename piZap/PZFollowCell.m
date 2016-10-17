//
//  PZFollowCell.m
//  piZap
//
//  Created by Assure Developer on 7/29/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZFollowCell.h"

@implementation PZFollowCell

- (void)awakeFromNib {
    // Initialization code
    self.imgProfilePhoto.layer.cornerRadius = self.imgProfilePhoto.frame.size.width / 2.;
    self.imgProfilePhoto.clipsToBounds = YES;
    [self.imgProfilePhoto.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.imgProfilePhoto.layer setBorderWidth:0.5f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
