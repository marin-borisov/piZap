//
//  PZCommentCell.h
//  piZap
//
//  Created by Assure Developer on 7/29/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PZCommentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic, weak) IBOutlet UILabel *lblUsername;

@property (nonatomic, weak) IBOutlet UILabel *lblComment;

@property (nonatomic, weak) IBOutlet UILabel *lblTimeStamp;

@property (nonatomic, weak) IBOutlet UIButton *btnProfile;

@property (nonatomic, weak) IBOutlet UIButton *btnProfileImg;

@end
