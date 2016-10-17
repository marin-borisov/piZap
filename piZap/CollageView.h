//
//  CollageView.h
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVGKit.h>

@class PZEditMainVC;

@interface CollageView : UIView

@property (strong, nonatomic) PZEditMainVC *containerVC;
@property (nonatomic, strong) UIImageView *imageBG;

@property                     float spacingValue;
@property                     float cornerValue;

//SVG Source
-(void)setSVGImageAsset:(SVGKImage*)image;

//Background Image
-(void)setBackgroundImage:(UIImage*)image;
-(void)removeBackgroundImage;
- (BOOL)hasBackgroundImage;

//Background Color
-(void)setBackgroundColorTheme:(UIColor*)color;

//SVG Control
-(void)setAdjustScale:(float)scale;
- (void)setRoundCorner:(float)corner;

//Filled
-(int)numberOfNonImageFilledSlot;

//Screenshot
-(BOOL)isReadForPrint;
-(void)prepareForPrint;

//Selection
- (void)deselectCurrentSelectedMask;

//Save
- (void)saveCurrentImages;
- (void)loadSavedImages;

@end
