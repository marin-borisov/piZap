//
//  IQLabelView.m
//  Created by kcandr on 17/12/14.

#import "ResizableTextObject.h"
#import <QuartzCore/QuartzCore.h>

CG_INLINE CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2)
{
    //Saving Variables.
    CGFloat fx = (point2.x - point1.x);
    CGFloat fy = (point2.y - point1.y);
    
    return sqrt((fx*fx + fy*fy));
}

CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t)
{
    return atan2(t.b, t.a);
}


CG_INLINE CGSize CGAffineTransformGetScale(CGAffineTransform t)
{
    return CGSizeMake(sqrt(t.a * t.a + t.c * t.c), sqrt(t.b * t.b + t.d * t.d)) ;
}

static ResizableTextObject *lastTouchedTextView;

@interface ResizableTextObject () <UIGestureRecognizerDelegate, UITextFieldDelegate>{
    CGSize superViewSize;
}

@end

@implementation ResizableTextObject
{
    CGFloat globalInset;
    
    CGRect initialBounds;
    CGFloat initialDistance;
    
    CGPoint beginningPoint;
    CGPoint beginningCenter;
    
    CGPoint prevPoint;
    CGPoint touchLocation;
    
    CGFloat deltaAngle;
    
    CGAffineTransform startTransform;
    CGRect beginBounds;
    
    CAShapeLayer *border;
}

@synthesize borderColor = borderColor;
@synthesize enableClose = enableClose, enableRotate = enableRotate, enableMoveRestriction;
@synthesize delegate = delegate;
@synthesize showContentShadow = showContentShadow;
@synthesize closeImage = closeImage, rotateImage = rotateImage, okImage = okImage, menuImage = menuImage;

- (void)refresh
{
    if (self.superview) {
        CGSize scale = CGAffineTransformGetScale(self.superview.transform);
        CGAffineTransform t = CGAffineTransformMakeScale(scale.width, scale.height);
        [closeView setTransform:CGAffineTransformInvert(t)];
        [okView setTransform:CGAffineTransformInvert(t)];
        [menuView setTransform:CGAffineTransformInvert(t)];
        [rotateView setTransform:CGAffineTransformInvert(t)];
        
        if (isShowingEditingHandles) {
            [self.layer insertSublayer:border atIndex:0];
        } else {
            [border removeFromSuperlayer];
        }
    }
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self refresh];
}

- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    [self refresh];
}

- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.width < (1+12*2))     frame.size.width = 25;
    if (frame.size.height < (1+12*2))    frame.size.height = 25;
    
    self = [super initWithFrame:frame];
    if (self) {
        
        globalInset = 9.5;
        float globalInsetForResize = 12;
        //Background/Border color
        self.backgroundColor = [UIColor clearColor];
        borderColor = [UIColor whiteColor];
        self.growColor = [UIColor purpleColor];
        self.textColor = [UIColor whiteColor];
        self.isTextOrBubble = YES;
        
        //Set border layer
        border = [CAShapeLayer layer];
        border.strokeColor = borderColor.CGColor;
        border.fillColor = nil;
        
        //bubble setting
        self.insetsForBubble = @[@0, @0, @0, @0];
        self.imgBubble = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, globalInset*2, globalInset*2)];
        [self.imgBubble setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        self.imgBubble.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imgBubble];
        
        //Font
        self.labelFont = [UIFont fontWithName:@"Verdana" size:25.];
        
        //Text setting
        self.lblText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, globalInset*2, globalInset*2)];
        self.lblText.font = self.labelFont;
        [self.lblText setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        self.lblText.backgroundColor = [UIColor clearColor];
        self.lblText.numberOfLines = 0;
        self.lblText.textAlignment = NSTextAlignmentCenter;
        self.lblText.textColor = self.textColor;
        self.lblText.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.lblText];
        
        [self setTextGrowEffect:self.growColor];
//        self.lblText.layer.borderColor = [UIColor greenColor].CGColor;
//        self.lblText.layer.borderWidth = 5.0;
//        
//        self.layer.borderColor = [UIColor redColor].CGColor;
//        self.layer.borderWidth = 5.0;
        
        
        //Close button view which is in top left corner
        closeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, globalInset*2, globalInset*2)];
        [closeView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin)];
        closeView.userInteractionEnabled = YES;
        [self addSubview:closeView];
        
        //Ok button
        okView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-globalInset*2, 0, globalInset*2, globalInset*2)];
        [okView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin)];
        okView.userInteractionEnabled = YES;
        [self addSubview:okView];
        
        //Menu button
        menuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-globalInset*2, globalInset*2, globalInset*2)];
        [menuView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin)];
        menuView.userInteractionEnabled = YES;
        [self addSubview:menuView];
        
        
        //Rotating view which is in bottom right corner
        rotateView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-globalInset*2, self.bounds.size.height-globalInsetForResize*2, globalInsetForResize*2, globalInsetForResize*2)];
        [rotateView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin)];
        rotateView.contentMode = UIViewContentModeCenter;
        rotateView.userInteractionEnabled = YES;
        [self addSubview:rotateView];
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        
        UITapGestureRecognizer *singleTapShowHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped:)];
        [self addGestureRecognizer:singleTapShowHide];
        
        UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap:)];
        [closeView addGestureRecognizer:closeTap];
        
        UITapGestureRecognizer *okTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(okTap:)];
        [okView addGestureRecognizer:okTap];
        
        UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTap:)];
        [menuView addGestureRecognizer:menuTap];
        
        UIPanGestureRecognizer *panRotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateViewPanGesture:)];
        [rotateView addGestureRecognizer:panRotateGesture];
        
        [moveGesture requireGestureRecognizerToFail:closeTap];
        
        [self setEnableMoveRestriction:NO];
        [self setEnableClose:YES];
        [self setEnableRotate:YES];
        [self setShowContentShadow:YES];
        [self setCloseImage:[UIImage imageNamed:@"close_image_btn"]];
        [self setOKImage:[UIImage imageNamed:@"ok_image_btn"]];
        [self setMenuImage:[UIImage imageNamed:@"edit_image_btn"]];
        [self setRotateImage:[UIImage imageNamed:@"scalable_image_btn"]];
        
        [self showEditingHandles];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect borderRect = CGRectInset(self.bounds, globalInset, globalInset);
    border.path = [UIBezierPath bezierPathWithRect:borderRect].CGPath;
    
//    float size = self.lblText.font.pointSize;
//    self.labelFont = [self.labelFont fontWithSize:size];
    
    if (self.imgBubble.image) {
        //Set the frame for bubble
        self.imgBubble.frame = CGRectInset(self.bounds, globalInset, globalInset);
        [self.imgBubble setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        
        //Set frame for text label
        [self updateLabelInsets];
    }
    else{
        [self setTextGrowEffect:self.growColor];
        [self updateLabelInsets];
    }
}

#pragma mark - Bubble
- (void)setBubbleImage:(UIImage*)image withInsetTop:(float)top  withInsetLeft:(float)left  withInsetBottom:(float)bottom  withInsetRight:(float)right
{
    [self setLabelTextColor:[UIColor blackColor]];
    [self setTextGrowEffect:[UIColor clearColor]];
    
    self.imgBubble.image = image;
    
    CGRect rectSelf = self.frame;
    rectSelf.size.height = image.size.height * rectSelf.size.width / image.size.width + globalInset * 2.f;
    rectSelf.size.width = rectSelf.size.width + globalInset * 2.f;
    [self setFrame:rectSelf];
    
    self.insetsForBubble = @[[NSNumber numberWithFloat:top],
                             [NSNumber numberWithFloat:left],
                             [NSNumber numberWithFloat:bottom],
                             [NSNumber numberWithFloat:right]];
    
    
    self.lblText.font = [self.lblText.font fontWithSize:100.];
    
    [self updateLabelInsets];
}

#pragma mark - Resize

- (CGSize)calculateSizeWithFont:(UIFont*)font{
    NSLog(@"font size : %f", font.pointSize);
    
    CGSize constraintSize=CGSizeMake(superViewSize.width, CGFLOAT_MAX);
    CGRect labelSize=[self.lblText.text boundingRectWithSize:constraintSize 
                                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                  attributes:@{NSFontAttributeName: font} 
                                                     context:nil];
    
    return labelSize.size;
}

- (void)setSuperViewSize:(CGSize)size{
    size.width -= globalInset * 2.0;
    size.height -= globalInset * 2.0;    
    superViewSize = size;
}

-(void)resizeLabel{
    
    //Set self frame
    CGSize newSize = [self calculateSizeWithFont:self.labelFont];
    
    CGPoint center = self.center;
    CGRect myRect = self.frame;
    myRect.size.width = newSize.width + globalInset * 2.0;
    myRect.size.height = newSize.height  + globalInset * 2.0;
    
    CGAffineTransform myTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    [self setFrame:myRect];
    self.center = center;
    
    self.transform = myTransform;
    
    
    //Reset the size
    UIFont *font = self.labelFont;
    font = [font fontWithSize:100.];
    self.lblText.font = font;
}


#pragma mark - Set Text Field

- (void)updateLabelInsets{
    CGRect rectLabel = CGRectInset(self.bounds, globalInset, globalInset);
    CGPoint centerLabel  = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    
    float topInset = [[self.insetsForBubble objectAtIndex:0] floatValue];
    float bottomInset = [[self.insetsForBubble objectAtIndex:2] floatValue];
    float leftInset = [[self.insetsForBubble objectAtIndex:1] floatValue];
    float rightInset = [[self.insetsForBubble objectAtIndex:3] floatValue];
    rectLabel.size.width = rectLabel.size.width * (1.0 - leftInset -rightInset);
    rectLabel.size.height = rectLabel.size.height * (1.0 -  topInset - bottomInset);
    
    self.lblText.frame = rectLabel;
    self.lblText.center = centerLabel;
    
//    [self.lblText setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    
}

- (void)setTextFont:(UIFont*)font{
    self.labelFont = font;
    self.lblText.font = font;
    [self resizeLabel];
    
    [self updateLabelInsets];
}

- (void)setTextLabel:(NSString*)strText{
    //Set text to label
    self.lblText.text = strText;
    
    if (!self.imgBubble.image) {
        [self resizeLabel];
    }
    
    [self updateLabelInsets];
}

- (void)setTextGrowEffect:(UIColor*)color{
    self.growColor = color;
    
    NSString *strText = self.lblText.text;
    if (!strText) strText = @"";
    
    self.lblText.attributedText=[[NSAttributedString alloc] 
                                    initWithString:strText 
                                    attributes:@{
                                                 NSStrokeWidthAttributeName: @-3.0,
                                                 NSStrokeColorAttributeName:color,
                                                 NSForegroundColorAttributeName:self.lblText.textColor
                                                 }
                                    ];

    
    /*
    float fontSize = self.labelFont.pointSize;
    
    self.lblText.layer.shadowColor = [color CGColor];
    self.lblText.layer.shadowRadius = self.frame.size.height / 10.f + 1.f;
    self.lblText.layer.shadowOpacity = .9;
    self.lblText.layer.shadowOffset = CGSizeZero;
    self.lblText.layer.masksToBounds = NO;
     */
}

- (void)setLabelTextColor:(UIColor *)color{
    self.textColor = color;
    
    self.lblText.textColor = color;
}

- (void)setEditText{
    [self menuTap:nil];
}

#pragma mark - Border

- (void)setBorderColor:(UIColor *)color
{
    borderColor = color;
    border.strokeColor = borderColor.CGColor;
}




#pragma mark - Set Control Buttons

- (void)setEnableClose:(BOOL)value
{
    enableClose = value;
    [closeView setHidden:!enableClose];
    [closeView setUserInteractionEnabled:enableClose];
}

- (void)setEnableRotate:(BOOL)value
{
    enableRotate = value;
    [rotateView setHidden:!enableRotate];
    [rotateView setUserInteractionEnabled:enableRotate];
}

- (void)setShowContentShadow:(BOOL)showShadow
{
    showContentShadow = showShadow;
    
    if (showContentShadow) {
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOffset:CGSizeMake(0, 5)];
        [self.layer setShadowOpacity:1.0];
        [self.layer setShadowRadius:4.0];
    } else {
        [self.layer setShadowColor:[UIColor clearColor].CGColor];
        [self.layer setShadowOffset:CGSizeZero];
        [self.layer setShadowOpacity:0.0];
        [self.layer setShadowRadius:0.0];
    }
}

- (void)setOKImage:(UIImage *)image
{
    okImage = image;
    [okView setImage:okImage];
}

- (void)setMenuImage:(UIImage *)image
{
    menuImage = image;
    [menuView setImage:menuImage];
}

- (void)setCloseImage:(UIImage *)image
{
    closeImage = image;
    [closeView setImage:closeImage];
}

- (void)setRotateImage:(UIImage *)image
{
    rotateImage = image;
    [rotateView setImage:rotateImage];
}

#pragma mark - Bounds

- (void)hideEditingHandles
{
    lastTouchedTextView = nil;
    
    isShowingEditingHandles = NO;
    
    if (enableClose)       closeView.hidden = YES;
    if (enableRotate)      rotateView.hidden = YES;
    okView.hidden = YES;
    menuView.hidden = YES;
    
    //    [imgView resignFirstResponder];
    
    [self refresh];
    
    if([delegate respondsToSelector:@selector(resizableTextObjectViewDidHideEditingHandles:)]) {
        [delegate resizableTextObjectViewDidHideEditingHandles:self];
    }
}

- (void)showEditingHandles
{
    [lastTouchedTextView hideEditingHandles];
    
    isShowingEditingHandles = YES;
    
    lastTouchedTextView = self;
    
    if (enableClose)       closeView.hidden = NO;
    if (enableRotate)      rotateView.hidden = NO;
    okView.hidden = NO;
    menuView.hidden = NO;
    
    [self refresh];
    
    if([delegate respondsToSelector:@selector(resizableTextObjectViewDidShowEditingHandles:)]) {
        [delegate resizableTextObjectViewDidShowEditingHandles:self];
    }
}

#pragma mark - Gestures

- (void)contentTapped:(UITapGestureRecognizer*)tapGesture
{
    if (isShowingEditingHandles) {
        [self hideEditingHandles];
        [self.superview bringSubviewToFront:self];
    } else {
        [self showEditingHandles];
    }
}

- (void)closeTap:(UITapGestureRecognizer *)recognizer
{
    [self removeFromSuperview];
    
    if([delegate respondsToSelector:@selector(resizableTextObjectViewDidClose:)]) {
        [delegate resizableTextObjectViewDidClose:self];
    }
}

- (void)okTap:(UITapGestureRecognizer *)recognizer
{
    [self hideEditingHandles];
    
    if([delegate respondsToSelector:@selector(resizableTextObjectViewDidOk:)]) {
        [delegate resizableTextObjectViewDidOk:self];
    }
}

- (void)menuTap:(UITapGestureRecognizer *)recognizer
{
    if([delegate respondsToSelector:@selector(resizableTextObjectViewDidMenu:)]) {
        [delegate resizableTextObjectViewDidMenu:self];
    }
}


-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    if (!isShowingEditingHandles) {
        [self showEditingHandles];
    }
    touchLocation = [recognizer locationInView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        beginningPoint = touchLocation;
        beginningCenter = self.center;
        
        [self setCenter:[self estimatedCenter]];
        beginBounds = self.bounds;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self setCenter:[self estimatedCenter]];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self setCenter:[self estimatedCenter]];
        
        if([delegate respondsToSelector:@selector(resizableTextObjectViewDidEndEditing:)]) {
            [delegate resizableTextObjectViewDidEndEditing:self];
        }
    }
    
    prevPoint = touchLocation;
}

- (CGPoint)estimatedCenter
{
    CGPoint newCenter;
    CGFloat newCenterX = beginningCenter.x + (touchLocation.x - beginningPoint.x);
    CGFloat newCenterY = beginningCenter.y + (touchLocation.y - beginningPoint.y);
    if (enableMoveRestriction) {
        if (!(newCenterX - 0.5 * CGRectGetWidth(self.frame) > 0 &&
              newCenterX + 0.5 * CGRectGetWidth(self.frame) < CGRectGetWidth(self.superview.bounds))) {
            newCenterX = self.center.x;
        }
        if (!(newCenterY - 0.5 * CGRectGetHeight(self.frame) > 0 &&
              newCenterY + 0.5 * CGRectGetHeight(self.frame) < CGRectGetHeight(self.superview.bounds))) {
            newCenterY = self.center.y;
        }
        newCenter = CGPointMake(newCenterX, newCenterY);
    } else {
        newCenter = CGPointMake(newCenterX, newCenterY);
    }
    return newCenter;
}

- (void)rotateViewPanGesture:(UIPanGestureRecognizer *)recognizer
{
    touchLocation = [recognizer locationInView:self.superview];
    
    CGPoint center = CGRectGetCenter(self.frame);
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        deltaAngle = atan2(touchLocation.y-center.y, touchLocation.x-center.x)-CGAffineTransformGetAngle(self.transform);
        
        initialBounds = self.bounds;
        initialDistance = CGPointGetDistance(center, touchLocation);
        
        if([delegate respondsToSelector:@selector(resizableTextObjectViewDidBeginEditing:)]) {
            [delegate resizableTextObjectViewDidBeginEditing:self];
        }
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        float ang = atan2(touchLocation.y-center.y, touchLocation.x-center.x);
        
        float angleDiff = deltaAngle - ang;
        [self setTransform:CGAffineTransformMakeRotation(-angleDiff)];
        [self setNeedsDisplay];
        
        //Finding scale between current touchPoint and previous touchPoint
        double scale = sqrtf(CGPointGetDistance(center, touchLocation)/initialDistance);
        
        CGRect scaleRect = CGRectScale(initialBounds, scale, scale);
        
        if (scaleRect.size.width >= (1+globalInset*2) && scaleRect.size.height >= (1+globalInset*2)) {
            //            if (CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds)) {
            //                [textView adjustsFontSizeToFillRect:scaleRect];
            [self setBounds:scaleRect];
            //            }
        }
        
        if([delegate respondsToSelector:@selector(resizableTextObjectViewDidChangeEditing:)]) {
            [delegate resizableTextObjectViewDidChangeEditing:self];
        }
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        if([delegate respondsToSelector:@selector(resizableTextObjectViewDidEndEditing:)]) {
            [delegate resizableTextObjectViewDidEndEditing:self];
        }
    }
}

@end
