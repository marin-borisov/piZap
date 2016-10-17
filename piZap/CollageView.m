//
//  CollageView.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import "CollageView.h"
#import "MaskView.h"
#import "CALayer+RecursiveClone.h"
#import <UIImageView+WebCache.h>
#import "PZEditMainVC.h"
#import "PZSelectPhotoVC.h"
#import "AppData.h"

@interface CollageView ()<MaskViewDelegate, PZSelectPhotoVCDelegate>{
    NSMutableArray *arrayMaskViews;
    NSMutableArray *arrayMaskTouchLayers;
    CALayer *mainLayer;
    CGSize sizeForSVGImage;
    
    MaskView *currentMaskView;
    
    MaskView *maskViewForPhoto;
    
    int nPanStartMaskIndex;
    int nPanEndMaskIndex;
    
    BOOL isFirstLoad;
}

@property (nonatomic, strong) SVGKImage *svgImage;

@end

@implementation CollageView

-(instancetype)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.spacingValue = 0.0;
        self.cornerValue = 0.0;
        isFirstLoad = YES;
        
        self.imageBG = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageBG];
        
        arrayMaskViews = [NSMutableArray array];
        arrayMaskTouchLayers = [NSMutableArray array];
        nPanStartMaskIndex = -1;
        nPanEndMaskIndex = -1;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedSelf:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panGesture];
        
    }
    return self;
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    sizeForSVGImage = _svgImage.size;
    
    //Redefine the frames of self and background imageview.
    float SVGWidth, SVGHeight;
    float rate;
    CGRect rectForSelf;
    if (sizeForSVGImage.width > sizeForSVGImage.height) {
        SVGWidth = self.bounds.size.width;
        rate = SVGWidth / sizeForSVGImage.width;
        SVGHeight = sizeForSVGImage.height * rate;
        
        rectForSelf = self.frame;
        rectForSelf.size.height = SVGHeight;
        
    }
    else{
        SVGHeight = self.bounds.size.height;
        rate = SVGHeight / sizeForSVGImage.height;
        SVGWidth = sizeForSVGImage.width * rate;
        
        rectForSelf = self.frame;
        rectForSelf.size.width = SVGWidth;
    }
    self.frame = rectForSelf;
    _imageBG.frame = self.bounds;
    
    //-------------------Get the oringal SVG size---------------
    _svgImage.size = CGSizeApplyAffineTransform(_svgImage.size, CGAffineTransformMakeScale(rate, rate));
    mainLayer = [_svgImage CALayerTree];
    while (mainLayer.sublayers.count == 1) {
        mainLayer = [[mainLayer sublayers] firstObject];
    }
    
    //Try to get the main parent layer
    NSMutableArray *arrayOrignalMaskLayers;
    if (mainLayer.sublayers.count == 0)
        arrayOrignalMaskLayers = [NSMutableArray arrayWithObject:mainLayer];
    else
        arrayOrignalMaskLayers = [NSMutableArray arrayWithArray:[mainLayer sublayers]];
    
    //---------------------Resize the SVG image and get the layer tree-----------------------
    _svgImage.size = CGSizeApplyAffineTransform(_svgImage.size, CGAffineTransformMakeScale(1.0 - self.spacingValue / 2.0f, 1.0 - self.spacingValue / 2.0f));
    sizeForSVGImage = _svgImage.size;
    mainLayer = [_svgImage CALayerTree];
    while (mainLayer.sublayers.count == 1) {
        mainLayer = [[mainLayer sublayers] firstObject];
    }
    
    //Try to get the main parent layer
    NSMutableArray *arrayMaskLayers;
    if (mainLayer.sublayers.count == 0)
        arrayMaskLayers = [NSMutableArray arrayWithObject:mainLayer];
    else
        arrayMaskLayers = [NSMutableArray arrayWithArray:[mainLayer sublayers]];
    
    //Rearrange the orders of sub layers according to the size
    [self rearrangeLayersForSize:arrayOrignalMaskLayers];
    [self rearrangeLayersForSize:arrayMaskLayers];
    
    //Remove the existing ones
//    [arrayMaskViews removeAllObjects];
//    for (UIView *subView in self.subviews) {
//        if ([subView isMemberOfClass:[MaskView class]]) {
//            [subView removeFromSuperview];
//        }
//    }
    
    for (CALayer *sublayer in arrayMaskTouchLayers) {
        if (sublayer.name.length > 0) {
            [sublayer removeFromSuperlayer];
        }
    }
    [arrayMaskTouchLayers removeAllObjects];
    
    //Add subviews and layers
    for(int i = 0; i < [arrayMaskLayers count]; i++){
        //Get sub layers
        CAShapeLayer *subLayer = [arrayMaskLayers objectAtIndex:i];
        
        if (self.cornerValue > 0.0f) {  // //Apply Corner
            CGRect rect= subLayer.frame;
            CGRect bound = subLayer.bounds;
            float maxCorner = MIN(rect.size.width, rect.size.height) / 2.0;
            
            float cornerRadius = maxCorner * self.cornerValue;
            subLayer = [CAShapeLayer layer];
            subLayer.frame = rect;
            subLayer.path = [self roundedPathFromRect:bound withRadius:cornerRadius].CGPath;//[UIBezierPath bezierPathWithRoundedRect:bound cornerRadius:40].CGPath;

        }
        
        //Copy layer for touch border
        CAShapeLayer *touchLayer = (CAShapeLayer*)[subLayer cloneRecursively];
        
        //Set the rect
        CGRect rect = subLayer.frame;
        CGRect originalRect = [(CALayer*)[arrayOrignalMaskLayers objectAtIndex:i] frame];
        
        //Create Or get the exiting subview
        MaskView *subView;
        if (arrayMaskViews.count > i) {
            subView = [arrayMaskViews objectAtIndex:i];
            [subView setFrame:originalRect];
            [subView setMaskLayer:subLayer];
            [subView removeFromSuperview];
        }
        else{
            subView = [[MaskView alloc] initWithFrame:originalRect];
            subView.layer.name = [NSString stringWithFormat:@"%d", i];
            subView.tag = i;
            subView.delegate = self;
            [subView setMaskLayer:subLayer];
            subView.userInteractionEnabled = NO;
            [arrayMaskViews addObject:subView];
        }
        
        //Add on content view
        [self addSubview:subView];
        [subView setNeedsDisplay];
        subView.clipsToBounds = YES;
//        float maxCorner = MIN(rect.size.width, rect.size.height) / 2.0;
//        subView.layer.cornerRadius = maxCorner * self.cornerValue;
        
        //Add touch layer
        rect = subView.frame;
        CGSize maskSize = touchLayer.frame.size;
        touchLayer.frame = CGRectMake(rect.origin.x + (rect.size.width - maskSize.width) / 2., rect.origin.y + (rect.size.height - maskSize.height) / 2., maskSize.width, maskSize.height);
        touchLayer.name = [NSString stringWithFormat:@"%d", i];
        touchLayer.fillColor = [UIColor clearColor].CGColor;
        touchLayer.lineWidth = 3.0f;
        touchLayer.strokeColor = [UIColor clearColor].CGColor;
        touchLayer.opacity = 0.1;
        [arrayMaskTouchLayers addObject:touchLayer];
        
        [self.layer addSublayer:touchLayer];
    }
    
    
    //Add presaved images if existing
    if (isFirstLoad) {
        [self loadSavedImages];
        isFirstLoad = NO;
    }


}


- (UIBezierPath *)roundedPathFromRect:(CGRect)f withRadius:(float)radius
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    // Draw the path
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(f.size.width - radius, 0)];
    [path addArcWithCenter:CGPointMake(f.size.width - radius, radius)
                    radius:radius
                startAngle:- (M_PI / 2)
                  endAngle:0
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(f.size.width, f.size.height - radius)];
    [path addArcWithCenter:CGPointMake(f.size.width - radius, f.size.height - radius)
                    radius:radius
                startAngle:0
                  endAngle:- ((M_PI * 3) / 2)
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(radius, f.size.height)];
    [path addArcWithCenter:CGPointMake(radius, f.size.height - radius)
                    radius:radius
                startAngle:- ((M_PI * 3) / 2)
                  endAngle:- M_PI
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(0, radius)];
    [path addArcWithCenter:CGPointMake(radius, radius)
                    radius:radius
                startAngle:- M_PI
                  endAngle:- (M_PI / 2)
                 clockwise:YES];
    
    return path;
}

#pragma mark - Gesture Handle
- (void)pannedSelf:(UIPanGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"PAN GESTURE STARTED");
        CGPoint point = [gesture locationInView:self];
        point = [self convertPoint:point toView:nil];
        CALayer *layer = [(CALayer *)self.layer.presentationLayer hitTest:point];
        
        if (layer.name && layer.name.length > 0) {
            NSLog(@"PAN GESTURE START INDEX : %@", layer.name);
            nPanStartMaskIndex = [layer.name intValue];
        }

    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"PAN GESTURE ENDED");
        CGPoint point = [gesture locationInView:self];
        point = [self convertPoint:point toView:nil];
        CALayer *layer = [(CALayer *)self.layer.presentationLayer hitTest:point];
        
        if (layer.name && layer.name.length > 0) {
            NSLog(@"PAN GESTURE END INDEX : %@", layer.name);
            nPanEndMaskIndex = [layer.name intValue];
            
            if (nPanStartMaskIndex < 0 || nPanEndMaskIndex < 0 || nPanStartMaskIndex == nPanEndMaskIndex) {
                nPanStartMaskIndex = nPanEndMaskIndex = -1;
                return;
            }
            
            //Check if Start layer has a photo
            MaskView *startView = [arrayMaskViews objectAtIndex:nPanStartMaskIndex];
            if (startView.imageView.image){
                MaskView *endView = [arrayMaskViews objectAtIndex:nPanEndMaskIndex];
                
                if (endView.imageView.image) {
                    //Exchange
                    UIImage *startViewImage = startView.imageView.image;
                    [startView setImage:endView.imageView.image];
                    [endView setImage:startViewImage];
                }
                else{
                    //Replace
                    UIImage *startViewImage = startView.imageView.image;
                    [endView setImage:startViewImage];
                    [startView deleteImage];
                }
            }
            nPanStartMaskIndex = nPanEndMaskIndex = -1;
        }
    }
}

#pragma mark - Private methods

-(void)setSVGImageAsset:(SVGKImage*)image{
    self.svgImage = image;
    
    sizeForSVGImage = _svgImage.size;
    
    //Redefine the frames of self and background imageview.
    float SVGWidth, SVGHeight;
    float rate;
    CGRect rectForSelf;
    if (sizeForSVGImage.width > sizeForSVGImage.height) {
        SVGWidth = self.bounds.size.width;
        rate = SVGWidth / sizeForSVGImage.width;
        SVGHeight = sizeForSVGImage.height * rate;
        
        rectForSelf = self.frame;
        rectForSelf.size.height = SVGHeight;
        
    }
    else{
        SVGHeight = self.bounds.size.height;
        rate = SVGHeight / sizeForSVGImage.height;
        SVGWidth = sizeForSVGImage.width * rate;
        
        rectForSelf = self.frame;
        rectForSelf.size.width = SVGWidth;
    }
    self.frame = rectForSelf;
    _imageBG.frame = self.bounds;
}

-(void)setAdjustScale:(float)scale{
    self.spacingValue = scale;
    [self setNeedsLayout];
}

- (void)setRoundCorner:(float)corner{
    self.cornerValue = corner;
    [self setNeedsLayout];
}

- (void)rearrangeLayersForSize:(NSMutableArray*)array{
    //Rearrange according to the size
    for(int i = 0; i < [array count] - 1; i++){
        CALayer *prevLayer = [array objectAtIndex:i];
        CGSize firstSize = prevLayer.frame.size;
        for(int j = i + 1; j < [array count]; j++){
            CALayer *nextLayer = [array objectAtIndex:j];
            CGSize secondSize = nextLayer.frame.size;
            
            if((firstSize.width <= secondSize.width && firstSize.height <= secondSize.height) ||
               firstSize.width*firstSize.height < secondSize.width*secondSize.height)
            {
                [array exchangeObjectAtIndex:i withObjectAtIndex:j];
                prevLayer = [array objectAtIndex:i];
                firstSize = prevLayer.frame.size;
            }
            
        }
    }
}

#pragma mark - Save current load images
- (void)saveCurrentImages{
    [AppData appData].arrayTmpImages = [NSMutableArray array];
    
    for (MaskView *maskView in arrayMaskViews) {
        if (maskView.isFilledImage) {
            [[AppData appData].arrayTmpImages addObject:maskView.imageView.image];
        }
    }
}

- (void)loadSavedImages{
    NSMutableArray *array = [AppData appData].arrayTmpImages;
    
    if (array.count) {
        [self applyImages:array];
        [[AppData appData].arrayTmpImages removeAllObjects];
    }
}

#pragma mark - Background Image and Color Control
-(void)removeBackgroundImage{
    _imageBG.image = nil;
}

- (BOOL)hasBackgroundImage{
    if (self.imageBG.image == nil) {
        return NO;
    }

    return YES;
}

-(void)setBackgroundImage:(UIImage*)image{
    _imageBG.image = image;
    _imageBG.contentMode = UIViewContentModeScaleAspectFill;
}

-(void)setBackgroundImageWithURL:(NSURL*)url withFrontBring:(BOOL)isFront{
    [_imageBG sd_setImageWithURL:url];
    _imageBG.contentMode = UIViewContentModeScaleAspectFit;
    
    if (isFront) {
        [self bringSubviewToFront:_imageBG];
    }
    
    _imageBG.userInteractionEnabled = NO;
}

-(void)setBackgroundColorTheme:(UIColor*)color{
    self.backgroundColor = color;
}

- (int)numberOfNonImageFilledSlot{
    int nCount = 0;
    for (MaskView *maskView in arrayMaskViews) {
        if (!maskView.isFilledImage) {
            nCount ++;
        }
    }
    
    return nCount;
}

#pragma mark - Mask View Delegate
-(void)addPhotoButtonClicked:(MaskView *)maskView{
    [self.containerVC pickPhotosForCollageWithDelegate:self];
    maskViewForPhoto = maskView;
}

-(void)detectedOutsidePangesture:(MaskView *)maskView withPoint:(CGPoint)point{

    nPanStartMaskIndex = (int)maskView.tag;
    NSLog(@"PAN GESTURE START INDEX : %d", nPanStartMaskIndex);
    
    NSLog(@"PAN GESTURE OUTSIDE DETECTED : %@", NSStringFromCGPoint(point));
    CALayer *layer = [(CALayer *)self.layer.presentationLayer hitTest:point];
    
    if (layer.name && layer.name.length > 0) {
        NSLog(@"PAN GESTURE END INDEX : %@", layer.name);
        nPanEndMaskIndex = [layer.name intValue];
        
        if (nPanStartMaskIndex < 0 || nPanEndMaskIndex < 0 || nPanStartMaskIndex == nPanEndMaskIndex) {
            nPanStartMaskIndex = nPanEndMaskIndex = -1;
            return;
        }
        
        //Check if Start layer has a photo
        MaskView *startView = [arrayMaskViews objectAtIndex:nPanStartMaskIndex];
        if (startView.imageView.image){
            MaskView *endView = [arrayMaskViews objectAtIndex:nPanEndMaskIndex];
            
            if (endView.imageView.image) {
                //Exchange
                UIImage *startViewImage = startView.imageView.image;
                [startView setImage:endView.imageView.image];
                [endView setImage:startViewImage];
                
                //Set target view as an active view
                [startView setActiveMask:NO];
                currentMaskView = endView;
                [endView setActiveMask:YES];
            }
            else{
                //Replace
                UIImage *startViewImage = startView.imageView.image;
                [endView setImage:startViewImage];
                [startView deleteImage];
                
                //Set target view as an active view
                [startView setActiveMask:NO];
                currentMaskView = endView;
                [endView setActiveMask:YES];
            }
        }
        nPanStartMaskIndex = nPanEndMaskIndex = -1;
    }
}

#pragma mark - Touch Detection
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint myPoint = point;//[self convertPoint:point toView:nil];
    CALayer *layer = [(CALayer *)self.layer.presentationLayer hitTest:myPoint];
    if (layer.name && layer.name.length > 0) {
        MaskView *view = [arrayMaskViews objectAtIndex:[layer.name integerValue]];
        

        if (![currentMaskView isEqual:view]) {
            [self selectMask:view];
            return self;
        }
    }
    else{
        [self deselectCurrentSelectedMask];
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - Print
- (BOOL)isReadForPrint{
    for (MaskView *subView in arrayMaskViews) {
        if (!subView.isFilledImage) {
            return NO;
        }
    }
    
    return YES;
}

-(void)prepareForPrint{
    [self deselectCurrentSelectedMask];
}


#pragma mark - Mask Selection/Deselection
- (void)selectMask:(MaskView*)maskView{
    //Deselect current selected mask
    [self deselectCurrentSelectedMask];
    
    //make a select on the new maskview if it is valid
    if (maskView) {
        [maskView setActiveMask:YES];
        currentMaskView = maskView;
    }
}

- (void)deselectCurrentSelectedMask{
    if (currentMaskView) {
        [currentMaskView setActiveMask:NO];
        currentMaskView = nil;
    }
    
    
}

#pragma mark - Photo Select VC Delegate

-(void)selectPhotoController:(PZSelectPhotoVC *)viewController didChooseImage:(UIImage *)image{
    
    MaskView *biggestView = [arrayMaskViews firstObject];
    float resizeValue;
    UIImage *resizedImage;
    if (biggestView.frame.size.width > biggestView.frame.size.height){
        resizeValue = biggestView.frame.size.width * 3.0;
        resizedImage = [AppData imageWithImage:image width:resizeValue];
    }
    else{
        resizeValue = biggestView.frame.size.height * 3.0;
        resizedImage = [AppData imageWithImage:image height:resizeValue];
    }
    
    //GoToCrop Screen
    [maskViewForPhoto setImage:resizedImage];
    
    //Reselect the current mask view
    [self selectMask:maskViewForPhoto];
}


-(void)selectPhotoController:(PZSelectPhotoVC *)viewController didChooseMultiImages:(NSArray *)imageArray {
    
    [self applyImages:imageArray];
}

#pragma mark - Image Apply
- (void)applyImages:(NSArray*)imageArray{
    if (maskViewForPhoto == nil) {
        maskViewForPhoto = [arrayMaskViews firstObject];
    }
    
    
    //Get the maximum size of the image for a resize
    MaskView *biggestView = [arrayMaskViews firstObject];
    
    float resizeValue;
    UIImage *resizedImage;
    if (biggestView.frame.size.width > biggestView.frame.size.height){
        resizeValue = biggestView.frame.size.width * 3.0;
        resizedImage = [AppData imageWithImage:[imageArray firstObject] width:resizeValue];
    }
    else{
        resizeValue = biggestView.frame.size.height * 3.0;
        resizedImage = [AppData imageWithImage:[imageArray firstObject] height:resizeValue];
    }
    [maskViewForPhoto setImage:resizedImage];
    
    int nCount = imageArray.count;
    int index = 0;
    for (int i = 1; i < nCount && index < arrayMaskViews.count; i ++) {
        UIImage *image = [imageArray objectAtIndex:i];
        MaskView *maskView = [arrayMaskViews objectAtIndex:index];
        
        //Determine the size of the image for resize
        if (biggestView.frame.size.width > biggestView.frame.size.height){
            resizedImage = [AppData imageWithImage:image width:resizeValue];
        }
        else{
            resizedImage = [AppData imageWithImage:image height:resizeValue];
        }
        
        //Fill the image on the empty slots
        while (maskView.isFilledImage) {
            index ++;
            
            if (index + 1 > arrayMaskViews.count) {
                i = nCount;
                maskView = nil;
                break;
            }
            else
                maskView = [arrayMaskViews objectAtIndex:index];
        }
        if (maskView) {
            [maskView setImage:resizedImage];
        }

        index ++;
    }
    
    //Reselect the current mask view
    [self selectMask:maskViewForPhoto];
}


@end
