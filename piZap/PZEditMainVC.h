//
//  PZEditMainVC.h
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CollageView;

@interface PZEditMainVC : UIViewController{
    CollageView *collageView;
}

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSDictionary *dicCollageInfo;


//Sticker
- (void)stickerSelected:(NSString *)strStickerImgURL;




//Collage
- (void)removeCollageBackgroundImage;
- (void)setCollageBackgroundImage:(UIImage*)image;
- (void)setCollageBackgroundColor:(UIColor*)color;
- (void)setCollageSpacing:(float)spacingValue;
- (void)setCollageCorner:(float)cornerValue;

- (void)pickPhotosForCollageWithDelegate:(CollageView*)colView;

- (float)getCollageSpacing;
- (float)getCollageCorner;
- (UIColor*)getCollageBGColor;
- (BOOL)hasCollageBGImage;

- (void)saveCurrentImages;

//Text
- (void)textSelected:(NSString *)stringText withBubbleIndex:(int)bubbleIndex;
- (void)deselectCurrentTextObject;

//Meme
- (void)memeClicked;


@end
