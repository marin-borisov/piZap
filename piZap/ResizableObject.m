//
//  IQLabelView.m
//  Created by kcandr on 17/12/14.

#import "ResizableObject.h"
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

static ResizableObject *lastTouchedView;

@interface ResizableObject () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@end

@implementation ResizableObject
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

@synthesize textColor = textColor, borderColor = borderColor;
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
            [imgView.layer addSublayer:border];
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
        
        self.backgroundColor = [UIColor clearColor];
        borderColor = [UIColor whiteColor];
        
        //Close button view which is in top left corner
        closeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, globalInset*2, globalInset*2)];
        [closeView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin)];
//        closeView.backgroundColor = [UIColor whiteColor];
//        closeView.layer.cornerRadius = globalInset - 5;
        closeView.userInteractionEnabled = YES;
        [self addSubview:closeView];
        
        //Ok button
        okView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-globalInset*2, 0, globalInset*2, globalInset*2)];
        [okView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin)];
//        okView.backgroundColor = [UIColor whiteColor];
//        okView.layer.cornerRadius = globalInset - 5;
        okView.userInteractionEnabled = YES;
        [self addSubview:okView];
        
        //Menu button
        menuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-globalInset*2, globalInset*2, globalInset*2)];
        [menuView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin)];
//        menuView.backgroundColor = [UIColor whiteColor];
//        menuView.layer.cornerRadius = globalInset - 5;
        menuView.userInteractionEnabled = YES;
        [self addSubview:menuView];

        
         //Rotating view which is in bottom right corner
        rotateView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-globalInset*2, self.bounds.size.height-globalInsetForResize*2, globalInsetForResize*2, globalInsetForResize*2)];
        [rotateView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin)];
//        rotateView.backgroundColor = [UIColor whiteColor];
//        rotateView.layer.cornerRadius = globalInset - 5;
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
    if (imgView) {
        border.path = [UIBezierPath bezierPathWithRect:imgView.bounds].CGPath;
        border.frame = imgView.bounds;
    }
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

#pragma mark - Set Text Field

- (void)setImageView:(UIImageView *)imageView
{
    [imgView removeFromSuperview];
    
    imgView = imageView;
    
    imgView.frame = CGRectInset(self.bounds, globalInset, globalInset);
    
    [imgView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin)];
    
    border = [CAShapeLayer layer];
    border.strokeColor = borderColor.CGColor;
    border.fillColor = nil;
//    border.lineDashPattern = @[@4, @3];

    [self insertSubview:imgView atIndex:0];
}

- (void)setBorderColor:(UIColor *)color
{
    borderColor = color;
    border.strokeColor = borderColor.CGColor;
}

#pragma mark - Bounds

- (void)hideEditingHandles
{
    lastTouchedView = nil;
    
    isShowingEditingHandles = NO;
    
    if (enableClose)       closeView.hidden = YES;
    if (enableRotate)      rotateView.hidden = YES;
    okView.hidden = YES;
    menuView.hidden = YES;
    
    [imgView resignFirstResponder];
    
    [self refresh];
    
    if([delegate respondsToSelector:@selector(resizableObjectViewDidHideEditingHandles:)]) {
        [delegate resizableObjectViewDidHideEditingHandles:self];
    }
}

- (void)showEditingHandles
{
    [lastTouchedView hideEditingHandles];
    
    isShowingEditingHandles = YES;
    
    lastTouchedView = self;
    
    if (enableClose)       closeView.hidden = NO;
    if (enableRotate)      rotateView.hidden = NO;
    okView.hidden = NO;
    menuView.hidden = NO;
    
    [self refresh];
    
    if([delegate respondsToSelector:@selector(resizableObjectViewDidShowEditingHandles:)]) {
        [delegate resizableObjectViewDidShowEditingHandles:self];
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
    
    if([delegate respondsToSelector:@selector(resizableObjectViewDidClose:)]) {
        [delegate resizableObjectViewDidClose:self];
    }
}

- (void)okTap:(UITapGestureRecognizer *)recognizer
{
    [self hideEditingHandles];
    
    if([delegate respondsToSelector:@selector(resizableObjectViewDidOk:)]) {
        [delegate resizableObjectViewDidOk:self];
    }
}

- (void)menuTap:(UITapGestureRecognizer *)recognizer
{
    if([delegate respondsToSelector:@selector(resizableObjectViewDidMenu:)]) {
        [delegate resizableObjectViewDidMenu:self];
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
        
        if([delegate respondsToSelector:@selector(resizableObjectViewDidEndEditing:)]) {
            [delegate resizableObjectViewDidEndEditing:self];
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
       
        if([delegate respondsToSelector:@selector(resizableObjectViewDidBeginEditing:)]) {
            [delegate resizableObjectViewDidBeginEditing:self];
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
        
        if([delegate respondsToSelector:@selector(resizableObjectViewDidChangeEditing:)]) {
            [delegate resizableObjectViewDidChangeEditing:self];
        }
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        if([delegate respondsToSelector:@selector(resizableObjectViewDidEndEditing:)]) {
            [delegate resizableObjectViewDidEndEditing:self];
        }
    }
}

@end
