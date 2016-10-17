//
//  PZAlertCell.m
//  piZap
//
//  Created by Assure Developer on 8/1/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZAlertCell.h"

@implementation PZAlertCell

- (void)awakeFromNib {
    // Initialization code
    
    self.imgProfilePhoto.layer.cornerRadius = self.imgProfilePhoto.frame.size.width / 2.;
    self.imgProfilePhoto.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellType:(AlertCellType)cellType{
    switch (cellType) {
        case FOLLOWING_USER:
        {
            self.lblAlertText.text = @"Started following you";
            self.btnImage.enabled = NO;
            self.imgPhoto.hidden = YES;
            self.imgPopupIcon.hidden = YES;
            self.btnFollowOrUnfollow.hidden = NO;

        }
            break;
            
        case REPOSTING_PHOTO:
        {
            self.lblAlertText.text = @"Reposted your image";
            self.btnImage.enabled = YES;
            self.imgPhoto.hidden = NO;
            self.imgPopupIcon.hidden = YES;
            self.btnFollowOrUnfollow.hidden = YES;
        }
            break;
            
        case LIKING_PHOTO:
        {
            self.lblAlertText.text = @"Liked your image";
            self.btnImage.enabled = YES;
            self.imgPhoto.hidden = NO;
            self.imgPopupIcon.hidden = NO;
            [self.imgPopupIcon setBackgroundImage:[UIImage imageNamed:@"like_icon_bordered"] forState:UIControlStateNormal];
            self.btnFollowOrUnfollow.hidden = YES;
        }
            break;
        
        case COMMENTING_PHOTO:
        {
            self.lblAlertText.text = @"Commented your image";
            self.btnImage.enabled = YES;
            self.imgPhoto.hidden = NO;
            self.imgPopupIcon.hidden = NO;
            [self.imgPopupIcon setBackgroundImage:[UIImage imageNamed:@"comment_icon_with_border"] forState:UIControlStateNormal];
            self.btnFollowOrUnfollow.hidden = YES;
        }
            break;
            
        case LIKING_USER:
        {
            self.lblAlertText.text = @"Liked you";
            self.btnImage.enabled = NO;
            self.imgPhoto.hidden = YES;
            self.imgPopupIcon.hidden = YES;
            self.btnFollowOrUnfollow.hidden = NO;
        }
            break;
            
        case FRIEND_JOIN:
        {
            self.lblAlertText.text = @"Joined Pizap.";
            self.btnImage.enabled = NO;
            self.imgPhoto.hidden = YES;
            self.imgPopupIcon.hidden = YES;
            self.btnFollowOrUnfollow.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

@end
