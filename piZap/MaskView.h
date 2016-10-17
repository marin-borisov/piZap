//
//  MaskView.h
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol MaskViewDelegate;


@interface MaskView : UIView

@property (nonatomic, weak) id<MaskViewDelegate> delegate;

@property (nonatomic, strong) UIButton *btnAddPhoto;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) CAShapeLayer *myBorderLayer;

@property (nonatomic, strong) CALayer *myMaskLayer;

@property                       BOOL isFilledImage;
@property                       BOOL isActiveState;

@property (nonatomic, strong) UIButton *btnDelete;

- (void)deleteImage;
- (void)setImage:(UIImage*)image;
- (void)setMaskLayer:(CALayer*)mask;
- (void)setActiveMask:(BOOL)isActive;

@end


@protocol MaskViewDelegate <NSObject>

- (void)addPhotoButtonClicked:(MaskView*)maskView;
- (void)detectedOutsidePangesture:(MaskView*)maskView withPoint:(CGPoint)point;

@end

