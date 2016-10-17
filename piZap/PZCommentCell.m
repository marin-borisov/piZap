//
//  PZCommentCell.m
//  piZap
//
//  Created by Assure Developer on 7/29/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZCommentCell.h"

@implementation PZCommentCell

-(void)awakeFromNib{
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2.;
    self.profileImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
