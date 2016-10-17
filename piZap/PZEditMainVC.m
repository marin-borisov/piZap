//
//  PZEditMainVC.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZEditMainVC.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>

#import "ResizableObject.h"
#import "ResizableTextObject.h"
#import "MKInputBoxView.h"
#import "PZEditTextVC.h"

#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>

#import "AppData.h"
#import "PZAPI.h"

#import "CollageView.h"
#import "MaskView.h"
#import "PZSelectPhotoVC.h"

#define TAG_BG_IMAGE_VIEW 9999

@interface PZEditMainVC ()<ResizableObjectDelegate, ResizableTextObjectDelegate>
{
    ResizableObject *currentlyEditingObject;
    ResizableTextObject *currentlyTextEditingObject;
    
    float widthReal;
    float heightReal;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgView;

@property (nonatomic, weak) IBOutlet UIView *viewMainEdit;

@property (nonatomic, strong) NSMutableArray *arrayObjects;

@property (nonatomic, strong) UINavigationController *navBottomTool;

@property (nonatomic, strong) UILabel *lblTopMeme;
@property (nonatomic, strong) UILabel *lblBottomMeme;

@end

#define MEME_DIVIDE_VALUE 6.0

@implementation PZEditMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //Load the background image
    if (self.image) {
        self.imgView.image = self.image;
        CGPoint center = self.imgView.center;
        if (self.image.size.width > self.image.size.height) {
            float rate = self.imgView.frame.size.width / self.image.size.width;
            float newHeight = self.image.size.height * rate;
            
            [self.imgView setFrame:CGRectMake(0, 0, self.imgView.frame.size.width, newHeight)];
        }
        else{
            float rate = self.imgView.frame.size.height / self.image.size.height;
            float newWidth = self.image.size.width * rate;
            
            [self.imgView setFrame:CGRectMake(0, 0, newWidth, self.imgView.frame.size.height)];
        }
        self.imgView.center = center;
        
        widthReal = self.image.size.width;
        heightReal = self.image.size.height;
        
        
        //Add meme
        [self setupMemeViews];
    }
    else{
        [SVProgressHUD show];
        
        collageView = [[CollageView alloc] initWithFrame:CGRectMake(0, 0, self.imgView.frame.size.width, self.imgView.frame.size.height)];
        collageView.containerVC = self;
        
        //Check if Edit Collage is possible
        BOOL isEnableEditSVG = [[self.dicCollageInfo objectForKey:@"SVG_EDIT_ENABLE"] boolValue];
        [AppData appData].isEditableCollage = isEnableEditSVG;
        
        //Check if Layout Change is possible
        BOOL isEnableEditLayout = [[self.dicCollageInfo objectForKey:@"SVG_EDIT_LAYOUT"] boolValue];
        [AppData appData].isEditableLayoutCollage = isEnableEditLayout;
        
        //Get the remote SVG file
        NSString *strSVGPath = [self.dicCollageInfo objectForKey:@"SVG_PATH"];
        NSURL *urlSVG = [NSURL URLWithString:strSVGPath];
        [self downloadDataWithURL:urlSVG completionBlock:^(BOOL succeeded, NSData *image) {
            NSData* svgData = [NSData dataWithContentsOfURL:urlSVG];
            NSInputStream *inputStream = [NSInputStream inputStreamWithData:svgData];
            [inputStream open];
            SVGKSource *source = [[SVGKSource alloc] initWithInputSteam:inputStream];
            SVGKImage *loadedImage = [SVGKImage  imageWithSource:source];
            [SVProgressHUD dismiss];
            
            //Save real size of SVG
            widthReal = loadedImage.size.width;
            heightReal = loadedImage.size.height;
            
            //Apply the SVG to collage view;
            [collageView setSVGImageAsset:loadedImage];
            
            //Remove SVG Object
            [loadedImage removeObserver:loadedImage forKeyPath:@"DOMTree.viewport"];
            loadedImage = nil;
            
            //Adjust the content view;
            CGSize sizeImage = collageView.frame.size;
            CGPoint center = self.imgView.center;
            if (sizeImage.width > sizeImage.height) {
                float rate = self.imgView.frame.size.width / sizeImage.width;
                float newHeight = sizeImage.height * rate;
                
                [self.imgView setFrame:CGRectMake(0, 0, self.imgView.frame.size.width, newHeight)];
            }
            else{
                float rate = self.imgView.frame.size.height / sizeImage.height;
                float newWidth = sizeImage.width * rate;
                
                [self.imgView setFrame:CGRectMake(0, 0, newWidth, self.imgView.frame.size.height)];
            }
            self.imgView.center = center;
            [self.imgView insertSubview:collageView atIndex:0];
            self.imgView.userInteractionEnabled = YES;
            self.imgView.multipleTouchEnabled = YES;
            
            //Set autosizing
            collageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            
            //Apply Background image
            NSString *strBGImage = [self.dicCollageInfo objectForKey:@"SVG_BACKGROUND_PATH"];
            
            if (strBGImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.imgView.bounds];
                [imageView sd_setImageWithURL:[NSURL URLWithString:strBGImage]];
                imageView.tag = TAG_BG_IMAGE_VIEW;
                [self.imgView addSubview:imageView];
            }
            
            //Add meme
            [self setupMemeViews];
        }];
        
    }
    
    //Set outside touch
    [self.viewMainEdit addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOutside:)]];
    
    //Initialize
    self.arrayObjects = [NSMutableArray array];

}

- (void)downloadDataWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   completionBlock(YES,data);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewWillDisappear:animated];
}


#pragma mark - Status Style
- (BOOL) prefersStatusBarHidden {
    return YES;
}

#pragma mark - UI Setup
- (void)setupMemeViews{
    //Draw meme label
    self.lblTopMeme = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.imgView.frame.size.width, self.imgView.frame.size.height / MEME_DIVIDE_VALUE)];
    self.lblTopMeme.font = [UIFont fontWithName:@"IMPACT" size:100];
    self.lblTopMeme.textColor = [UIColor whiteColor];
    self.lblTopMeme.textAlignment = NSTextAlignmentCenter;
    [self.lblTopMeme setAdjustsFontSizeToFitWidth:YES];
    self.lblTopMeme.numberOfLines = 0;
    [self.imgView addSubview:self.lblTopMeme];
    
//    self.lblTopMeme.layer.borderColor = [UIColor blackColor].CGColor;
//    self.lblTopMeme.layer.borderWidth = 5.f;
    
    //Draw meme label
    self.lblBottomMeme = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imgView.frame.size.height * (MEME_DIVIDE_VALUE - 1.) / MEME_DIVIDE_VALUE, self.imgView.frame.size.width, self.imgView.frame.size.height / MEME_DIVIDE_VALUE)];
    self.lblBottomMeme.font = [UIFont fontWithName:@"IMPACT" size:100];
    self.lblBottomMeme.textColor = [UIColor whiteColor];
    self.lblBottomMeme.textAlignment = NSTextAlignmentCenter;
    [self.lblBottomMeme setAdjustsFontSizeToFitWidth:YES];
    self.lblBottomMeme.numberOfLines = 0;
    [self.imgView addSubview:self.lblBottomMeme];
}


#pragma mark - Collage Change
- (void)removeCollageBackgroundImage{
    if (collageView) {
        [collageView removeBackgroundImage];
    }
}

- (void)setCollageBackgroundImage:(UIImage*)image{
    if (collageView) {
        [collageView setBackgroundImage:image];
    }
}

- (void)setCollageBackgroundColor:(UIColor*)color{
    if (collageView) {
        [collageView setBackgroundColorTheme:color];
    }
}

- (void)setCollageSpacing:(float)spacingValue{
    if (collageView) {
        [collageView setAdjustScale:spacingValue];
    }
}

- (void)setCollageCorner:(float)cornerValue{
    if (collageView) {
        [collageView setRoundCorner:cornerValue];
    }
}

- (float)getCollageSpacing{
    return collageView.spacingValue;
}

- (float)getCollageCorner{
    return collageView.cornerValue;
}

- (UIColor*)getCollageBGColor{
    return collageView.backgroundColor;
}
- (BOOL)hasCollageBGImage{
    return [collageView hasBackgroundImage];
}

- (void)saveCurrentImages{
    [collageView saveCurrentImages];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController *targetVC = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"GoToPhotoSelect"]) {
        PZSelectPhotoVC *photoSelectVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        photoSelectVC.multiSelection = YES;
        photoSelectVC.multiSelectionCount = [(CollageView*)sender numberOfNonImageFilledSlot];
        photoSelectVC.delegate = sender;
    }
    else if ([segue.identifier isEqualToString:@"bottomToolEmbeded"]) {
        self.navBottomTool = [segue destinationViewController];
    }
}


#pragma mark - Photo Picker
- (void)pickPhotosForCollageWithDelegate:(CollageView*)colView{
    [self performSegueWithIdentifier:@"GoToPhotoSelect" sender:colView];
}

#pragma mark - User Interaction

- (IBAction)clickOnMenuButton:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickSave:(id)sender{
    
    if (self.image == nil && ![collageView isReadForPrint]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please fill all of the photo slots." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (currentlyEditingObject){
        [currentlyEditingObject hideEditingHandles];
    }
    
    if (currentlyTextEditingObject){
        [currentlyTextEditingObject hideEditingHandles];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (currentlyEditingObject){
            [currentlyEditingObject hideEditingHandles];
        }
        
        if (currentlyTextEditingObject){
            [currentlyTextEditingObject hideEditingHandles];
        }
    });
    
    //---------------     Save to Camera Roll    ------------------------
    float cameraImageWidth = 3000.f;//widthReal;
    UIImage *imgForCamera = [self imageScreenshotWithWidth:cameraImageWidth];
    [self saveImageToCamera:imgForCamera];
    
    //---------------     Save for Pizap posting  ------------------------
    float pizapImageWidth = 1024.f;
    float pizapImageHeight = imgForCamera.size.height * (pizapImageWidth / cameraImageWidth);
    UIImage *imgForPizap = [AppData imageWithImage:imgForCamera withSize:CGSizeMake(pizapImageWidth, pizapImageHeight)];
//    UIImage *imgForPizap =  [self imageScreenshotWithWidth:pizapImageWidth];

    //-----------------POST ----------------------------------------
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 500 *1024; //500 KB for maximum
    
    NSData *compressimageData = UIImageJPEGRepresentation(imgForPizap, compression);
    
    while ([compressimageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        compressimageData = UIImageJPEGRepresentation(imgForPizap, compression);
    }
    NSLog(@"POST IMAGE TO PIZAP!!!-------------->");
    NSLog(@"Image Size : %@", NSStringFromCGSize(imgForPizap.size));
    NSLog(@"Compression : %f", compression);
    NSLog(@"Post Image Size : %@",[NSByteCountFormatter stringFromByteCount:compressimageData.length countStyle:NSByteCountFormatterCountStyleFile]);
    
    [SVProgressHUD show];
    [PZAPI postImageWithTitle:@"" posttofacebook:@"no" publicvalue:@"yes" posttotwitter:@"no" posttotumblr:@"no" data:compressimageData access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isSuccess, id response) {
        [SVProgressHUD dismiss];
        
        if (isSuccess) {
            NSLog(@"Successfully Uploaded");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Successfully Uploaded" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;

        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uploading Failed" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
    
}

#pragma mark - Font 
#pragma mark - Image Manipulation for posting
/*

- (UIImage *)pb_takeSnapshotCollage:(float)width{
    float rate = width / widthReal;
    float newHeight = heightReal * rate;
    CGSize newImageSize = CGSizeMake(width, newHeight);
    
    //Show loading pin
    [SVProgressHUD show];
    UIView *viewCover = [[UIView alloc] initWithFrame:collageView.frame];
    viewCover.backgroundColor = [UIColor colorWithRed:80./255. green:77./255. blue:110./255. alpha:1.];
    [self.imgView addSubview:viewCover];
    
    //Make CollageView Scale
    CGRect originalRect = collageView.frame;
    CGRect collageRect = originalRect;
    collageRect.size.width = width;
    collageRect.size.height = newHeight;
    [collageView setFrame:collageRect];
    
    // Now loop waiting until the collage view is updated
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    //Get the screenshtho of it.
    NSLog(@"screen scale : %f", [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContextWithOptions(newImageSize, YES, 0.0);//[UIScreen mainScreen].scale);
    CGContextSetInterpolationQuality( UIGraphicsGetCurrentContext() , kCGInterpolationHigh );
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    
    [collageView.layer.presentationLayer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Recover the collage scale
    [collageView setFrame:originalRect];
    [viewCover removeFromSuperview];
    
    //Hide loading pin
    [SVProgressHUD dismiss];
    
    return image;
}
*/
- (UIImage *)pb_takeSnapshot:(float)width{
    //Load progress
    [SVProgressHUD show];
    
    //Set the new size
    float rate = width / widthReal;
    float newHeight = heightReal * rate;
    CGSize newImageSize = CGSizeMake(width, newHeight);
    
    float scaleRate = width / self.imgView.frame.size.width;
    
    //------------------------------  Show cover view --------------------------------------
    UIView *viewCover = [[UIView alloc] initWithFrame:self.viewMainEdit.frame];
    viewCover.backgroundColor = [UIColor colorWithRed:80./255. green:77./255. blue:110./255. alpha:1.];
    [self.view addSubview:viewCover];
    
    //-------------------------Resize the collage scale-------------------------------
    //Resize parent view
    CGRect originalRect = self.imgView.frame;
    CGRect collageRect = originalRect;
    collageRect.size.width = width;
    collageRect.size.height = newHeight;
    [self.imgView setFrame:collageRect];
    
    //Resize collage
    [collageView setFrame:self.imgView.bounds];
    
    //Resize collage background image if it is existing
    UIImageView *bgImageView;
    if ((bgImageView = (UIImageView*)[self.imgView viewWithTag:TAG_BG_IMAGE_VIEW])){
        [bgImageView setFrame:self.imgView.bounds];
    }
    
    //Resize meme
    CGRect rectNewTopMeme = CGRectMake(0, 0, width, newHeight / MEME_DIVIDE_VALUE);
    CGRect rectTopMeme = self.lblTopMeme.frame;
    self.lblTopMeme.frame = rectNewTopMeme;
    
    CGRect rectNewBottomMeme = CGRectMake(0, newHeight * (MEME_DIVIDE_VALUE - 1.) / MEME_DIVIDE_VALUE, width, newHeight / MEME_DIVIDE_VALUE);
    CGRect rectBottomMeme = self.lblBottomMeme.frame;
    self.lblBottomMeme.frame = rectNewBottomMeme;
    
    self.lblTopMeme.font = [UIFont fontWithName:@"IMPACT" size:1000];
    self.lblBottomMeme.font = [UIFont fontWithName:@"IMPACT" size:1000];
    
    //Resize objects
    float globalInset = 9.5f;
    NSMutableArray *arrayRectsForObjs = [NSMutableArray array];
    for (int i = 0; i < self.arrayObjects.count; i ++) {
        UIView *subView = [self.arrayObjects objectAtIndex:i];
        CGPoint center = subView.center;
        [arrayRectsForObjs addObject:[NSValue valueWithCGPoint:center]];
        
        float diffWidth = 0; 
        float diffHeight = 0;
        if ([subView isMemberOfClass:[ResizableTextObject class]]) {
            ResizableTextObject *txtObj = (ResizableTextObject*)subView;
            
            UIFont *font = txtObj.labelFont;
            txtObj.lblText.font = [font fontWithSize:1000];
            
            diffWidth = globalInset * 2.0 * (scaleRate - 1);
            diffHeight = globalInset * 2.0 * (scaleRate - 1);
        }
        
        
        CGAffineTransform transform = subView.transform;
        subView.transform = CGAffineTransformIdentity;
        CGRect rect = subView.frame;
        subView.frame = CGRectMake(rect.origin.x * scaleRate, rect.origin.y * scaleRate, rect.size.width * scaleRate - diffWidth, rect.size.height * scaleRate - diffHeight);
        subView.transform = transform;
        

        center.x *= scaleRate;
        center.y *= scaleRate;
        subView.center = center;
    }
    
    
    //------------------------------------Draw the scaled entire view -------------------------
    // Now loop waiting until the collage view is updated
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.]];
    
    
    //Get the screenshtho of it.
    UIGraphicsBeginImageContextWithOptions(newImageSize, YES, 0.0);//[UIScreen mainScreen].scale);
    CGContextSetInterpolationQuality( UIGraphicsGetCurrentContext() , kCGInterpolationHigh );
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    
    [self.imgView.layer.presentationLayer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //-------------------------Recover the collage scale-------------------------------
    //Recover parent view
    [self.imgView setFrame:originalRect];
    
    //Recover collage
    [collageView setFrame:self.imgView.bounds];
    
    //Recover collage background image if it is existing
    if ((bgImageView = (UIImageView*)[self.imgView viewWithTag:TAG_BG_IMAGE_VIEW])){
        [bgImageView setFrame:self.imgView.bounds];
    }
    
    //Recover meme
    self.lblTopMeme.frame = rectTopMeme;
    self.lblBottomMeme.frame = rectBottomMeme;
    self.lblTopMeme.font = [UIFont fontWithName:@"IMPACT" size:100];
    self.lblBottomMeme.font = [UIFont fontWithName:@"IMPACT" size:100];
    
    //Resize the objects
    for (int i = 0; i < self.arrayObjects.count; i ++) {
        UIView *subView = [self.arrayObjects objectAtIndex:i];
        CGPoint originalCenter = [[arrayRectsForObjs objectAtIndex:i] CGPointValue];
        
        float diffWidth = 0; 
        float diffHeight = 0;
        if ([subView isMemberOfClass:[ResizableTextObject class]]) {
            UIFont *font = [(ResizableTextObject*)subView lblText].font;
            [(ResizableTextObject*)subView lblText].font = [font fontWithSize:100];
            
            diffWidth = globalInset * 2.0 * (scaleRate - 1.0);
            diffHeight = globalInset * 2.0 * (scaleRate - 1.0);
        }
        
        CGAffineTransform transform = subView.transform;
        subView.transform = CGAffineTransformIdentity;
        CGRect rect = subView.frame;
        subView.frame = CGRectMake(rect.origin.x / scaleRate, rect.origin.y / scaleRate, (rect.size.width +  diffWidth) / scaleRate , (rect.size.height+ diffHeight) / scaleRate );
        subView.transform = transform;

        
        

        subView.center = originalCenter;
    }
    
    
    //------------------------------  remove cover view --------------------------------------
    [viewCover removeFromSuperview];
    
    //-------------------------------------------------------------------------------------
    
    //remove progress
    [SVProgressHUD dismiss];
    
    return image;
}

- (UIImage*)imageScreenshotWithWidth:(float)width{
    //---------------------- Rearrange the object array by layer order ------------
    
    int objCount = self.arrayObjects.count;
    for (int i = 0; i < objCount - 1; i ++) {
        for (int j = i + 1; j < objCount; j ++) {
            UIView *subViewPre = [self.arrayObjects objectAtIndex:i];
            UIView *subViewNext = [self.arrayObjects objectAtIndex:j];            
            int viewIndexPre = [[self.imgView subviews] indexOfObject:subViewPre];
            int viewIndexNext = [[self.imgView subviews] indexOfObject:subViewNext];
            
            if (viewIndexPre > viewIndexNext) {
                [self.arrayObjects exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
            
        }
    }
    
    
    UIImage *imageScreen = [self pb_takeSnapshot:width];
    return imageScreen;
    
    //---------------------- Get new size ------------------------------
//    float rate = width / widthReal;
//    float newHeight = heightReal * rate;
    
    //0=-------------------  Set the size of output image ----------------------
//    UIImage *imageScren = nil;
//    CGSize newImageSize = CGSizeMake(width, newHeight);
    
    //---------------------  Begin drawing the context -------------------------
//    UIGraphicsBeginImageContext(newImageSize);
    
    /*
    //----------  If Edit Picture Mode
    if (self.image) {
        [self.image drawInRect:CGRectMake(0, 0, width, newHeight)];
    }
    //----------  If Collage mode with a SVG image
    else{
        
        //Prepare the collageView by removing the selection border and delete icon
        [collageView prepareForPrint];
        
        //Make scale and take a screenshot
        UIImage *imageBG = [self pb_takeSnapshotCollage:width];
        [imageBG drawInRect:CGRectMake(0, 0, width, newHeight)];
    
        
        //Draw background image if it is existing
        UIImageView *bgImageView;
        if ((bgImageView = (UIImageView*)[self.imgView viewWithTag:TAG_BG_IMAGE_VIEW])){
            [bgImageView.image drawInRect:CGRectMake(0, 0, width, newHeight)];
        }
    }
    */
    
//    [imageBG drawInRect:CGRectMake(0, 0, width, newHeight)];
    
    
    /*
    //--------------------- MEME ------------------------------
    if (self.lblTopMeme.text.length > 0) {
        CGRect rect = CGRectMake(0, 0, width, newHeight / MEME_DIVIDE_VALUE);
        CGRect rectTop = self.lblTopMeme.frame;
        
        self.lblTopMeme.frame = rect;
        self.lblTopMeme.font = [self.lblTopMeme.font fontWithSize:1000];
        [self.lblTopMeme drawTextInRect:rect];
        
        //Recover
        self.lblTopMeme.frame = rectTop;
        self.lblTopMeme.font = [self.lblTopMeme.font fontWithSize:200];
        
    }
    
    if (self.lblBottomMeme.text.length > 0) {
        CGRect rect = CGRectMake(0, newHeight * (MEME_DIVIDE_VALUE - 1.) / MEME_DIVIDE_VALUE, width, newHeight / MEME_DIVIDE_VALUE);
        CGRect rectBottom = self.lblBottomMeme.frame;
        self.lblBottomMeme.frame = rect;
        self.lblBottomMeme.font = [self.lblTopMeme.font fontWithSize:1000];
        [self.lblBottomMeme drawTextInRect:rect];
        
        //Recover
        self.lblBottomMeme.frame = rectBottom;
        self.lblBottomMeme.font = [self.lblTopMeme.font fontWithSize:200];
    }
    
    


    //---------------------  Display the stickers --------------------------
    for (int i = 0; i < self.arrayObjects.count; i ++) {
        UIView *subView = [self.arrayObjects objectAtIndex:i];
        
        if ([subView isMemberOfClass:[ResizableObject class]]) {
            ResizableObject *obj = (ResizableObject*)subView;
            float scaleRate = width / self.imgView.frame.size.width;
            float globalInset = 9.5f;
            CGRect rectOriginal = obj.frame;
            rectOriginal = CGRectInset(rectOriginal, globalInset, globalInset);
            
            UIImage *imgObj = obj.imageData;
            
            
            CGFloat angle = atan2f(obj.transform.b, obj.transform.a);
            CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(- angle);
            CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformIdentity, rotateTransform);
            
            CIImage* coreImage = imgObj.CIImage;
            if (!coreImage) {
                coreImage = [CIImage imageWithCGImage:imgObj.CGImage];
            }
            coreImage = [coreImage imageByApplyingTransform:transform];
            UIImage *newImage = [UIImage imageWithCIImage:coreImage];
            
            
            //Display the scaled items
            CGRect rectForItem = CGRectMake(rectOriginal.origin.x * scaleRate, rectOriginal.origin.y * scaleRate, rectOriginal.size.width * scaleRate, rectOriginal.size.height * scaleRate);
            [newImage drawInRect:rectForItem];
        }
        else if ([subView isMemberOfClass:[ResizableTextObject class]]) {
            ResizableTextObject *obj = (ResizableTextObject*)subView;
            CGRect rectOriginal = obj.frame;
            float scaleRate = width / self.imgView.frame.size.width;
            CGRect rectForItem = CGRectMake(rectOriginal.origin.x * scaleRate, rectOriginal.origin.y * scaleRate, rectOriginal.size.width * scaleRate, rectOriginal.size.height * scaleRate);
            
            //Enlarge the rect
            obj.frame = rectForItem;
            
            UIGraphicsBeginImageContextWithOptions(rectForItem.size, NO, 0.0);//[UIScreen mainScreen].scale);
            CGContextSetInterpolationQuality( UIGraphicsGetCurrentContext() , kCGInterpolationHigh );
            CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
            
            [obj.layer renderInContext:UIGraphicsGetCurrentContext()];
            
            UIImage *textObjImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [textObjImage drawInRect:rectForItem];
            
            //Recover the original rect
            obj.frame = rectOriginal;
        }
    }
    */
    
    //----------------------  Get the entire image from current context  -------------------
//    imageScren = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
//    return imageBG;
}

- (void)saveImageToCamera:(UIImage*)imgScreen
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        NSData* imdata =  UIImagePNGRepresentation ( imgScreen ); // get PNG representation
        NSData* imdata =  UIImageJPEGRepresentation(imgScreen, 1.0); // get JPG representation
        UIImage* im2 = [UIImage imageWithData:imdata];
        
        UIImageWriteToSavedPhotosAlbum(im2, nil, nil, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Saved to Photo Roll");
        });
    });
}

#pragma mark - Gesture

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchView = [touch view];
    
    //If touch the outside of collage view, deselect the selected mask
    if (collageView
        && ![touchView isKindOfClass:[CollageView class]]
        && ![touchView isDescendantOfView:collageView]
        && ![touchView isEqual:self.imgView]) {
            [collageView deselectCurrentSelectedMask];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchOutside:(UITapGestureRecognizer *)touchGesture
{
    if (currentlyEditingObject) {
        [currentlyEditingObject hideEditingHandles];
    }
    
    if (currentlyTextEditingObject){
        [currentlyTextEditingObject hideEditingHandles];
    }
}



#pragma mark - Resizable Object Delegate

- (void)resizableObjectViewDidClose:(ResizableObject *)obj
{
    [_arrayObjects removeObject:obj];
}

- (void)resizableObjectViewDidShowEditingHandles:(ResizableObject *)obj
{
    // showing border and control buttons
    currentlyEditingObject = obj;
    
    if (currentlyTextEditingObject) {
        [currentlyTextEditingObject hideEditingHandles];
    }
    
    
    //Bring it to the front
    [self.imgView bringSubviewToFront:obj];

}

- (void)resizableObjectViewDidHideEditingHandles:(ResizableObject *)obj
{
    // hiding border and control buttons
    currentlyEditingObject = nil;
}

- (void)resizableObjectViewDidStartEditing:(ResizableObject *)obj
{
    // tap in text field and keyboard showing
    currentlyEditingObject = obj;
}

#pragma mark - Sticker Selected
- (void)stickerSelected:(NSString *)strStickerImgURL{
    //Add sticker to the main board
    if (currentlyEditingObject)
        [currentlyEditingObject hideEditingHandles];
    
    if (currentlyTextEditingObject)
        [currentlyTextEditingObject hideEditingHandles];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [imgView sd_setImageWithURL:[NSURL URLWithString:strStickerImgURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        float globalInset = 9.5f;
        
        CGRect imgFrame = CGRectMake(self.imgView.frame.size.width / 2.0 - (image.size.width / 2.0 + globalInset * 2.0) / 2.0,
                                     self.imgView.frame.size.height / 2.0 - (image.size.height / 2.0 + globalInset * 2.0) / 2.0,
                                     image.size.width / 2.0 + globalInset * 2.0, image.size.height / 2.0 + globalInset * 2.0);

        ResizableObject *objView = [[ResizableObject alloc] initWithFrame:imgFrame];
        [objView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        objView.delegate = self;
        [objView setShowContentShadow:NO];
        [objView setEnableMoveRestriction:NO];
        [objView setImageView:imgView];
        objView.originalImageSize = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0);
        objView.imageData = image;
        
        [self.imgView addSubview:objView];
        [self.imgView setClipsToBounds:YES];
        [self.imgView setUserInteractionEnabled:YES];
        
        currentlyEditingObject = objView;
        [_arrayObjects addObject:objView];
    }];

}

#pragma mark - Meme
- (void)memeClicked{
    MKInputBoxView *inputBoxView = [MKInputBoxView boxOfType:LoginAndPasswordInput];
    [inputBoxView setTitle:@"Enter the Meme texts"];
    [inputBoxView setBlurEffectStyle:UIBlurEffectStyleExtraLight];
    [inputBoxView setCancelButtonText:@"Cancel"];
    
    inputBoxView.customise = ^(UITextField *textField) {
        textField.placeholder = @"text";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textColor = [UIColor blackColor];
        textField.layer.cornerRadius = 4.0f;
        
        if (textField.tag == 100) { // Top label
            textField.text = self.lblTopMeme.text;
        }
        else if (textField.tag == 200) { // Bottom label
            textField.text = self.lblBottomMeme.text;
        }
        
        return textField;
    };
    
    inputBoxView.onSubmit = ^(NSString *value1, NSString *value2) {
        
        self.lblTopMeme.attributedText=[[NSAttributedString alloc] 
                                   initWithString:value1 
                                   attributes:@{
                                                NSStrokeWidthAttributeName: @-3.0,
                                                NSStrokeColorAttributeName:[UIColor blackColor],
                                                NSForegroundColorAttributeName:[UIColor whiteColor]
                                                }
                                   ];
        
        self.lblBottomMeme.attributedText=[[NSAttributedString alloc] 
                                        initWithString:value2 
                                        attributes:@{
                                                     NSStrokeWidthAttributeName: @-3.0,
                                                     NSStrokeColorAttributeName:[UIColor blackColor],
                                                     NSForegroundColorAttributeName:[UIColor whiteColor]
                                                     }
                                        ];
        
        return YES;
    };
    
    inputBoxView.onCancel = ^{
        NSLog(@"Cancel!");
    };
    
    [inputBoxView show];
}

#pragma mark - Text Selected
- (void)textSelected:(NSString *)stringText withBubbleIndex:(int)bubbleIndex{
    //Add sticker to the main board
    if (currentlyEditingObject)
        [currentlyEditingObject hideEditingHandles];
    
    if (currentlyTextEditingObject)
        [currentlyTextEditingObject hideEditingHandles];
    
    
    
    float globalInset = 9.5f;
    CGRect rect = CGRectMake(self.imgView.frame.size.width / 2.0 - (self.imgView.frame.size.width / 2.0 + globalInset * 2.0) / 2.0,
                             self.imgView.frame.size.height / 2.0 - (self.imgView.frame.size.height / 2.0 + globalInset * 2.0) / 2.0,
                             self.imgView.frame.size.width, 
                             self.imgView.frame.size.height);
    
    CGRect rectForBubble = CGRectMake(self.imgView.frame.size.width / 2.0 - (self.imgView.frame.size.width / 2.0 + globalInset * 2.0) / 2.0,
                             self.imgView.frame.size.height / 2.0 - (self.imgView.frame.size.height / 2.0 + globalInset * 2.0) / 2.0,
                             self.imgView.frame.size.width / 3., 
                             self.imgView.frame.size.height / 3.);
    
    if (bubbleIndex == 0) {  //Just text
        ResizableTextObject *objView = [[ResizableTextObject alloc] initWithFrame:rect];
        [objView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        objView.delegate = self;
        [objView setSuperViewSize:self.imgView.frame.size];//self.view.bounds.size];
        [objView setShowContentShadow:NO];
        [objView setEnableMoveRestriction:NO];
        [objView setTextLabel:stringText];
        [objView setIsTextOrBubble:YES];
        
        [self.imgView addSubview:objView];
        [self.imgView setClipsToBounds:YES];
        [self.imgView setUserInteractionEnabled:YES];
        
        currentlyTextEditingObject = objView;
        [self.arrayObjects addObject:objView];
        
        [self showTextEditingTooIfNeeded];
        
        objView.center = CGPointMake(self.imgView.bounds.size.width / 2.0, self.imgView.bounds.size.height / 2.0);
    }
    else if (bubbleIndex == 1) //Circle Bubble
    {
        ResizableTextObject *objView = [[ResizableTextObject alloc] initWithFrame:rectForBubble];
        [objView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        objView.delegate = self;
        [objView setSuperViewSize:self.imgView.frame.size];//self.view.bounds.size];
        [objView setShowContentShadow:NO];
        [objView setEnableMoveRestriction:NO];
        
         [objView setBubbleImage:[UIImage imageNamed:@"bubble_talk.png"] withInsetTop:0.2 withInsetLeft:0.125 withInsetBottom:0.125 withInsetRight:0.2];
        [objView setTextLabel:stringText];
        [objView setIsTextOrBubble:NO];
        
        [self.imgView addSubview:objView];
        [self.imgView setClipsToBounds:YES];
        [self.imgView setUserInteractionEnabled:YES];
        
        currentlyTextEditingObject = objView;
        [self.arrayObjects addObject:objView];
        
        objView.center = CGPointMake(self.imgView.bounds.size.width / 2.0, self.imgView.bounds.size.height / 2.0);
    }
    else if (bubbleIndex == 2) //Round Bubble
    {
        ResizableTextObject *objView = [[ResizableTextObject alloc] initWithFrame:rectForBubble];
        [objView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        objView.delegate = self;
        [objView setSuperViewSize:self.imgView.frame.size];//self.view.bounds.size];
        [objView setShowContentShadow:NO];
        [objView setEnableMoveRestriction:NO];
        
         [objView setBubbleImage:[UIImage imageNamed:@"bubble_thought.png"] withInsetTop:0.2 withInsetLeft:0.2 withInsetBottom:0.2 withInsetRight:0.15];
        [objView setTextLabel:stringText];
        [objView setIsTextOrBubble:NO];
        
        [self.imgView addSubview:objView];
        [self.imgView setClipsToBounds:YES];
        [self.imgView setUserInteractionEnabled:YES];
        
        currentlyTextEditingObject = objView;
        [self.arrayObjects addObject:objView];
        
        objView.center = CGPointMake(self.imgView.bounds.size.width / 2.0, self.imgView.bounds.size.height / 2.0);
    }
    else if (bubbleIndex == 3) //Sharp Bubble
    {
        ResizableTextObject *objView = [[ResizableTextObject alloc] initWithFrame:rectForBubble];
        [objView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        objView.delegate = self;
        [objView setSuperViewSize:self.imgView.frame.size];//self.view.bounds.size];
        [objView setShowContentShadow:NO];
        [objView setEnableMoveRestriction:NO];
        
        [objView setBubbleImage:[UIImage imageNamed:@"bubble_comic.png"] withInsetTop:0.28 withInsetLeft:0.2 withInsetBottom:0.28 withInsetRight:0.2];
        [objView setTextLabel:stringText];
        [objView setIsTextOrBubble:NO];
        
        
        [self.imgView addSubview:objView];
        [self.imgView setClipsToBounds:YES];
        [self.imgView setUserInteractionEnabled:YES];
        
        currentlyTextEditingObject = objView;
        [self.arrayObjects addObject:objView];
        
        objView.center = CGPointMake(self.imgView.bounds.size.width / 2.0, self.imgView.bounds.size.height / 2.0);
    }
}

- (void)deselectCurrentTextObject{
    if (currentlyTextEditingObject) {
        [currentlyTextEditingObject hideEditingHandles];
    }
}

#pragma mark - Text Editing Tool

- (void)hideTextEditingToolIfNeeded{
    if (currentlyTextEditingObject.isTextOrBubble) {  //If raw text edit, hide the text editing tool
        if (self.navBottomTool) {
            [self.navBottomTool popViewControllerAnimated:NO];
        }
    }
}

- (void)showTextEditingTooIfNeeded{
    if (currentlyTextEditingObject.isTextOrBubble) {  //If raw text edit, show the text editing tool
        if (self.navBottomTool) {
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PZEditTextVC *editTextVC = [mystoryboard instantiateViewControllerWithIdentifier:@"PZEditTextVC"];
            [editTextVC setTextObj:currentlyTextEditingObject];
            
            if ([self.navBottomTool.topViewController isMemberOfClass:[PZEditTextVC class]]) {
                [self.navBottomTool popViewControllerAnimated:NO];
            }
            
            [self.navBottomTool pushViewController:editTextVC animated:YES];
        }
    }
}

#pragma mark - Resizable Text Object Delegate
- (void)resizableTextObjectViewDidMenu:(ResizableTextObject *)obj{
    
    //Show Text Input Box
    MKInputBoxView *inputBoxView = [MKInputBoxView boxOfType:PlainTextInput];//LoginAndPasswordInput
    [inputBoxView setTitle:@"Enter text"];
    [inputBoxView setBlurEffectStyle:UIBlurEffectStyleExtraLight];
    
    [inputBoxView setCancelButtonText:@"Cancel"];
    
    inputBoxView.customise = ^(UITextField *textField) {
        textField.placeholder = @"text";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textColor = [UIColor blackColor];
        textField.layer.cornerRadius = 4.0f;
        
        textField.text = obj.lblText.text;
        return textField;
    };
    
    inputBoxView.onSubmit = ^(NSString *value1, NSString *value2) {
        [obj setTextLabel:value1];
        return YES;
    };
    
    inputBoxView.onCancel = ^{
        NSLog(@"Cancel!");
    };
    
    [inputBoxView show];
}

- (void)resizableTextObjectViewDidClose:(ResizableTextObject *)obj
{
    [self hideTextEditingToolIfNeeded];
    [self.arrayObjects removeObject:obj];
}

- (void)resizableTextObjectViewDidShowEditingHandles:(ResizableTextObject *)obj
{
    currentlyTextEditingObject = obj;
    if (currentlyEditingObject) {
        [currentlyEditingObject hideEditingHandles];
    }
    
    //Show editing text tool
    [self showTextEditingTooIfNeeded];
    
    
    //Bring it to the front
    [self.imgView bringSubviewToFront:obj];
    
}

- (void)resizableTextObjectViewDidHideEditingHandles:(ResizableTextObject *)obj
{
    [self hideTextEditingToolIfNeeded];
    currentlyTextEditingObject = nil;
}

- (void)resizableTextObjectViewDidStartEditing:(ResizableTextObject *)obj
{
    // tap in text field and keyboard showing
    currentlyTextEditingObject = obj;
}




@end
