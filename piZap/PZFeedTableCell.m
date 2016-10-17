//
//  PZFeedTableCell.m
//  piZap
//
//  Created by Assure Developer on 7/27/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZFeedTableCell.h"
#import "EXPhotoViewer.h"

@implementation PZFeedTableCell

-(void)awakeFromNib{
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2.;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.profileImageView.layer.borderWidth = 0.5f;
}

- (IBAction)onButtonForZoom:(id)sender {
    [EXPhotoViewer showImageFrom:self.photoImageView];
}


@end
