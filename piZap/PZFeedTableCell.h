//
//  PZFeedTableCell.h
//  piZap
//
//  Created by Assure Developer on 7/27/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PZFeedTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic, weak) IBOutlet UILabel *lblName;

@property (nonatomic, weak) IBOutlet UILabel *lblTimeStamp;

@property (nonatomic, weak) IBOutlet UILabel *lblPhotoTitle;

@property (nonatomic, weak) IBOutlet UILabel *lblTag;

@property (nonatomic, weak) IBOutlet UILabel *lblFavoriteCount;

@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;

@property (nonatomic, weak) IBOutlet UIView *viewPhotoImage;

@property (nonatomic, weak) IBOutlet UIView *viewComment;

@property (nonatomic, weak) IBOutlet UIView *viewBottomSection;

@property (nonatomic, weak) IBOutlet UILabel *lblCommentCount;

@property (nonatomic, weak) IBOutlet UIButton *btnProfile;

@property (nonatomic, weak) IBOutlet UIButton *btnLikeButtonUp;

@property (nonatomic, weak) IBOutlet UIButton *btnLikeButtonDown;

@property (nonatomic, weak) IBOutlet UIImageView *imgLineView;

@property (nonatomic, weak) IBOutlet UIButton *viewMoreComment;

@property (nonatomic, weak) IBOutlet UIImageView *imgLikeIcon;

@property (nonatomic, weak) IBOutlet UIButton *btnMoreOptions;

@property (nonatomic, weak) IBOutlet UIButton *btnComment;

@property (nonatomic, weak) IBOutlet UIButton *btnMoreComment;

@property (nonatomic, weak) IBOutlet UIButton *btnPhoto;

@property (nonatomic, weak) IBOutlet UIButton *btnPhotoForZoom;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@end
