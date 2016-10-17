//
//  PZEditCollageVC.m
//  piZap
//
//  Created by RisingSun on 10/28/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import "PZEditCollageVC.h"
#import "AppData.h"
#import "PZEditMainVC.h"
#import "PZSelectPhotoVC.h"

#import <NKOColorPickerView.h>

@interface PZEditCollageVC ()<PZSelectPhotoVCDelegate>{
    PZEditMainVC *mainVC;
    
    NKOColorPickerView *colorPickerView;
    BOOL hasBackgroundImage;
}

@property (nonatomic, weak) IBOutlet UISlider *spacingSlider;

@property (nonatomic, weak) IBOutlet UISlider *cornerSlider;

@property (nonatomic, weak) IBOutlet UIButton *btnAddBGImage;

@property (nonatomic, weak) IBOutlet UIView *viewColorSelection;

@end

@implementation PZEditCollageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Get the main edit controller
    mainVC = (PZEditMainVC*)[self.navigationController parentViewController];

    //Get the current collage info
    hasBackgroundImage = [mainVC hasCollageBGImage];
    if (hasBackgroundImage) {
        [self.btnAddBGImage setBackgroundImage:[UIImage imageNamed:@"removebg_btn"] forState:UIControlStateNormal];
    }
    else{
        [self.btnAddBGImage setBackgroundImage:[UIImage imageNamed:@"addbgimage_btn"] forState:UIControlStateNormal];
    }
    
    self.spacingSlider.value = [mainVC getCollageSpacing];
    self.cornerSlider.value = [mainVC getCollageCorner];
    self.viewColorSelection.backgroundColor = [mainVC getCollageBGColor];
    
    
    
    //Setup Sliders
    [self setupSliders];
    
    //Check if layout change is possible
    if (![AppData appData].isEditableLayoutCollage) {
        self.spacingSlider.enabled = NO;
        self.spacingSlider.value = 0;
        
        self.cornerSlider.enabled = NO;
        self.cornerSlider.value = 0;
    }
    
    //Setup Color selection view
    [self.viewColorSelection.layer setCornerRadius:3.f];
    [self.viewColorSelection setClipsToBounds:YES];
    
    //Setup Color Picker
    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
        //Your code handling a color change in the picker view.
        [self.viewColorSelection setBackgroundColor:color];
        [mainVC setCollageBackgroundColor:color];
    };

    colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, 0, 200, 190) color:self.viewColorSelection.backgroundColor andDidChangeColorBlock:colorDidChangeBlock];
    [colorPickerView setColor:self.viewColorSelection.backgroundColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController *targetVC = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"GoToSingleImagePicker"]) {
        PZSelectPhotoVC *photoSelectVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        photoSelectVC.multiSelection = NO;
        photoSelectVC.multiSelectionCount = 0;
        photoSelectVC.delegate = self;
    }
}


#pragma mark - UI Setup
- (void)setupSliders{
    [self.spacingSlider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [self.spacingSlider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [self.spacingSlider setThumbImage:[UIImage imageNamed:@"thumb_size_slider"] forState:UIControlStateNormal];
    
    [self.cornerSlider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [self.cornerSlider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [self.cornerSlider setThumbImage:[UIImage imageNamed:@"thumb_size_slider"] forState:UIControlStateNormal];
}

- (void)removeColorPicker{
    if (colorPickerView.superview != nil) {
        [colorPickerView removeFromSuperview];
    }
}
#pragma mark - User Interaction
- (IBAction)backBtnClicked:(id)sender{
    [self removeColorPicker];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)okBtnclick:(id)sender{
    [self removeColorPicker];
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeLayoutBtnClicked:(id)sender{
    [self removeColorPicker];
    
    [mainVC saveCurrentImages];
    [mainVC.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addBGImageBtnClicked:(id)sender{
    [self removeColorPicker];
    
    
    if (hasBackgroundImage) {  //Remove it
        [mainVC removeCollageBackgroundImage];
        hasBackgroundImage = NO;
        [self.btnAddBGImage setBackgroundImage:[UIImage imageNamed:@"addbgimage_btn"] forState:UIControlStateNormal];
    }
    else{  //Select an image
        [self performSegueWithIdentifier:@"GoToSingleImagePicker" sender:self];
    }
    
}

- (IBAction)colorPickerClicked:(id)sender{
    //Add color picker to your view
    [self.view addSubview:colorPickerView];
}

- (IBAction)changeSpacing:(id)sender{
    float value = self.spacingSlider.value;
    [mainVC setCollageSpacing:value];
}

- (IBAction)changeCorner:(id)sender{
    float value = self.cornerSlider.value;
    [mainVC setCollageCorner:value];
}


#pragma mark - Photo Select VC Delegate
-(void)selectPhotoController:(PZSelectPhotoVC *)viewController didChooseImage:(UIImage *)image{
    hasBackgroundImage = YES;
    [self.btnAddBGImage setBackgroundImage:[UIImage imageNamed:@"removebg_btn"] forState:UIControlStateNormal];
    
    [mainVC setCollageBackgroundImage:image];
}

-(void)selectPhotoController:(PZSelectPhotoVC *)viewController didChooseMultiImages:(NSArray *)imageArray{
    
}


#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchView = [touch view];
    
    //If touch the outside of collage view, deselect the selected mask
    if (![touchView isKindOfClass:[NKOColorPickerView class]])
    {
        if (colorPickerView.superview){
            [colorPickerView removeFromSuperview];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}
@end
