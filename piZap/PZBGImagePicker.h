//
//  PZBGImagePicker.h
//  piZap
//
//  Created by Assure Developer on 6/14/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PZBGImagePickerDelegate;

@interface PZBGImagePicker : UIViewController

@property (nonatomic, strong) NSString *strUsername;
@property BOOL isPublic;

@property (nonatomic, weak) id<PZBGImagePickerDelegate> delegate;

@end

@protocol PZBGImagePickerDelegate <NSObject>

- (void)imagePicker:(PZBGImagePicker*)viewController didChoosePiZapImage:(NSString*)strImageURL;

- (void)imagePicker:(PZBGImagePicker*)viewController didChooseThemeImage:(NSString*)strImageURL withBGColor:(UIColor*)bgColor;

@end