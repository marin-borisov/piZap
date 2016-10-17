//
//  PZImagePicker.h
//  piZap
//
//  Created by Assure Developer on 6/20/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PZImagePickerDelegate;

@interface PZImagePicker : UIViewController

@property (nonatomic, strong) NSString *strUsername;
@property BOOL isPublic;

@property (nonatomic, weak) id<PZImagePickerDelegate> delegate;

@end

@protocol PZImagePickerDelegate <NSObject>

- (void)imagePicker:(PZImagePicker*)viewController
     didChooseImage:(NSString*)strImageURL;

@end