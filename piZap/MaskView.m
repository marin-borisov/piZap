//
//  MaskView.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import "MaskView.h"
#import "CALayer+RecursiveClone.h" 

@implementation MaskView

-(instancetype)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.exclusiveTouch = NO;
        self.clipsToBounds = YES;
        
        
        
        //Set background
        self.backgroundColor = [UIColor clearColor];
       
        //Set flag for filled image
        self.isFilledImage = NO;
        _isActiveState = NO;
        
        //Initialize the scrollview
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor = [UIColor grayColor];
        self.contentView.autoresizesSubviews = YES;
        self.contentView.clipsToBounds = YES;
        [self addSubview:self.contentView];
        
        //Initialize the addphoto button
        self.btnAddPhoto = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        self.btnAddPhoto.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.btnAddPhoto setTitle:@"+add photo" forState:UIControlStateNormal];
        [self.btnAddPhoto setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
        [self.btnAddPhoto.titleLabel setFont:[UIFont systemFontOfSize:9.f]];
        [self.btnAddPhoto addTarget:self action:@selector(clickAddPhotoButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnAddPhoto];
        
        //Initialize the image view
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.imageView.image = nil;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        
        //Set delete button
//        self.btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width / 8., self.bounds.size.height / 8., 20, 20)];
        self.btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(1, 1., 20, 20)];
        [self.btnDelete setImage:[UIImage imageNamed:@"close_image_btn"] forState:UIControlStateNormal];
        [self.btnDelete addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnDelete];
        
        //Add Gesture
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panRecognizer];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
        [self addGestureRecognizer:pinchRecognizer];
        
        UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationDetected:)];
        [self addGestureRecognizer:rotationRecognizer];
        
        //Initialize
        [self deleteImage];
        
    }
    return self;
    
}
-(void)awakeFromNib{
    
}

-(void)layoutSubviews{
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setSelected:(BOOL)isSelected{
    
}

#pragma mark - Functions

- (void)deleteImage{
    self.imageView.image = nil;
    self.imageView.userInteractionEnabled = NO;
    self.imageView.hidden = YES;
    self.btnAddPhoto.userInteractionEnabled = YES;
    self.btnAddPhoto.hidden = NO;
    self.btnDelete.hidden = YES;
    self.isFilledImage = NO;
}
- (void)setImage:(UIImage*)imageData{
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.image = imageData;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.hidden = NO;
    self.btnAddPhoto.userInteractionEnabled = NO;
    self.btnAddPhoto.hidden = YES;
//    self.btnDelete.hidden = NO;
    self.isFilledImage = YES;
        
    CGRect rect = self.contentView.bounds;
    float imageWidth, imageHeight;
    float imageX = 0;
    float imageY = 0;
    if (imageData.size.width > imageData.size.height) {
        imageHeight = rect.size.height;
        imageWidth = imageData.size.width * imageHeight / imageData.size.height;
        
        if (imageWidth >= rect.size.width) {
            imageX = - (imageWidth - self.contentView.frame.size.width) / 2.0;
        }
        else{
            imageWidth = rect.size.width;
            imageHeight = imageData.size.height * imageWidth / imageData.size.width;
            
            imageY = - (imageHeight - self.contentView.frame.size.height) / 2.0;
        }

    }
    else{
        imageWidth = rect.size.width;
        imageHeight = imageData.size.height * imageWidth / imageData.size.width;
        
        if (imageHeight >= rect.size.height) {
            imageY = - (imageHeight - self.contentView.frame.size.height) / 2.0;
        }
        else{
            imageHeight = rect.size.height;
            imageWidth = imageData.size.width * imageHeight / imageData.size.height;
            
            imageX = - (imageWidth - self.contentView.frame.size.width) / 2.0;
        }
    }
    
    [self.imageView setFrame:CGRectMake(imageX, imageY, imageWidth, imageHeight)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setMaskLayer:(CALayer*)mask{
    self.myMaskLayer = mask;
    
    CGSize maskSize = mask.frame.size;
    self.myMaskLayer.frame = CGRectMake((self.bounds.size.width - maskSize.width) / 2., (self.bounds.size.height - maskSize.height) / 2., maskSize.width, maskSize.height);
    self.contentView.layer.mask = self.myMaskLayer;
    self.contentView.layer.masksToBounds = YES;
    
    if([mask isKindOfClass:[CAShapeLayer class]]) {
        if (_isActiveState)
            [self removeBorder];

        self.myBorderLayer = (CAShapeLayer*)[mask cloneRecursively];
        
        if (_isActiveState)
            [self drawBorder];
    }
}

- (void)setActiveMask:(BOOL)isActive{
    _isActiveState = isActive;
    if (isActive) {
        self.userInteractionEnabled = YES;
        [self drawBorder];
        [self showDeleteBorder];
    }
    else{
        self.userInteractionEnabled = NO;
        [self removeBorder];
        [self hideDeleteBorder];
    }

}

#pragma mark - delete button
- (void)showDeleteBorder{
    if (_isFilledImage) {
        self.btnDelete.hidden = NO;
    }
    
}

- (void)hideDeleteBorder{
    if (_isFilledImage) {
        self.btnDelete.hidden = YES;
    }
}


#pragma mark - Border
- (void)drawBorder{
    if (self.myBorderLayer) {
        if (self.myBorderLayer.superlayer) {
            [self.myBorderLayer removeFromSuperlayer];
        }
        
        self.myBorderLayer.lineWidth = 3.0f;
        self.myBorderLayer.strokeColor = [UIColor redColor].CGColor;
        self.myBorderLayer.fillColor = [UIColor clearColor].CGColor;
        
        [self.contentView.layer addSublayer:self.myBorderLayer];
    }
}

- (void)removeBorder{
    if (self.myBorderLayer && self.myBorderLayer.superlayer) {
        [self.myBorderLayer removeFromSuperlayer];
    }
}

#pragma mark - User Interaction

- (void)clickAddPhotoButton:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addPhotoButtonClicked:)]) {
        [self.delegate addPhotoButtonClicked:self];
    }
}

#pragma mark - Gesture Recognizers

- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    //Check if active or not
    if (!_isActiveState) {
        return;
    }
    
    //Send the event to parent view for the outside gesture
    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [panRecognizer locationInView:self];
        point = [self convertPoint:point toView:self.superview];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(detectedOutsidePangesture:withPoint:)]) {
            [self.delegate detectedOutsidePangesture:self withPoint:point];
        }
    }
    
    
    //Handle the gesture for internal usage
    CGRect rectView = self.imageView.frame;
    CGRect rectLimited = self.bounds;//.frame;
    float diffX = rectView.size.width - rectLimited.size.width;
    float diffY = rectView.size.height - rectLimited.size.height;
    if (diffX < 0)
        diffX = 0;
    if (diffY < 0)
        diffY = 0;
    rectLimited.origin.x -= diffX;
    rectLimited.origin.y -= diffY;
    rectLimited.size.width += diffX * 2.;
    rectLimited.size.height += diffY * 2.;
    
    CGPoint translation = [panRecognizer translationInView:self];
    CGPoint imageViewPosition = self.imageView.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    
    self.imageView.center = imageViewPosition;
    [panRecognizer setTranslation:CGPointZero inView:self];
    
    //Adjust again if it is over the limited rect
    CGRect imageRect = self.imageView.frame;
    if (self.imageView.frame.origin.x < rectLimited.origin.x) {
        imageRect.origin.x = rectLimited.origin.x;
    }
    
    if (self.imageView.frame.origin.y < rectLimited.origin.y) {
        imageRect.origin.y = rectLimited.origin.y;
    }
    if (self.imageView.frame.origin.x + self.imageView.frame.size.width > rectLimited.origin.x + rectLimited.size.width) {
        imageRect.origin.x = rectLimited.origin.x + rectLimited.size.width - self.imageView.frame.size.width;//_contentView.frame.origin.x;
    }
    
    if (self.imageView.frame.origin.y + self.imageView.frame.size.height > rectLimited.origin.y + rectLimited.size.height) {
        imageRect.origin.y = rectLimited.origin.y + rectLimited.size.height - self.imageView.frame.size.height;
    }
    
    
    diffX = imageRect.origin.x - self.imageView.frame.origin.x;
    diffY = imageRect.origin.y - self.imageView.frame.origin.y;
    imageViewPosition.x += diffX;
    imageViewPosition.y += diffY;
    
    self.imageView.center = imageViewPosition;
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    if (!_isActiveState) {
        return;
    }
    
    CGFloat scale = pinchRecognizer.scale;
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, scale, scale);
    pinchRecognizer.scale = 1.0;
}

- (void)rotationDetected:(UIRotationGestureRecognizer *)rotationRecognizer
{
    if (!_isActiveState) {
        return;
    }
    
    CGFloat angle = rotationRecognizer.rotation;
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, angle);
    rotationRecognizer.rotation = 0.0;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



@end
