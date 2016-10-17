//
//  PZSelectPhotoVC.h
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PZSelectPhotoVCDelegate;

@interface PZSelectPhotoVC : UIViewController

@property (nonatomic, weak) id<PZSelectPhotoVCDelegate> delegate;

@property                   BOOL multiSelection;

@property                   int multiSelectionCount;

@end

@protocol PZSelectPhotoVCDelegate <NSObject>

- (void)selectPhotoController:(PZSelectPhotoVC*)viewController
               didChooseImage:(UIImage*)image;

- (void)selectPhotoController:(PZSelectPhotoVC*)viewController
          didChooseMultiImages:(NSArray*)imageArray;

@end