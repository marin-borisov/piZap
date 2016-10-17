//
//  PZAlertCell.h
//  piZap
//
//  Created by Assure Developer on 8/1/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZClickableLabelForUsername.h"

typedef enum AlertCellTypes
{
    FOLLOWING_USER,
    REPOSTING_PHOTO,
    LIKING_PHOTO,
    COMMENTING_PHOTO,
    LIKING_USER,
    FRIEND_JOIN
} AlertCellType;

@interface PZAlertCell : UITableViewCell

@property (nonatomic, weak) IBOutlet PZClickableLabelForUsername *lblName;

@property (nonatomic, weak) IBOutlet UILabel *lblAlertText;

@property (nonatomic, weak) IBOutlet UILabel *lblTimeStamp;

@property (nonatomic, weak) IBOutlet UIImageView *imgProfilePhoto;

@property (nonatomic, weak) IBOutlet UIButton *btnFollowOrUnfollow;

@property (nonatomic, weak) IBOutlet UIImageView *imgPhoto;

@property (nonatomic, weak) IBOutlet UIButton *imgPopupIcon;

@property (nonatomic, weak) IBOutlet UIButton *btnProfileImage;

@property (nonatomic, weak) IBOutlet UIButton *btnNameLabel;

@property (nonatomic, weak) IBOutlet UIButton *btnImage;

- (void)setCellType:(AlertCellType)cellType;

@end
