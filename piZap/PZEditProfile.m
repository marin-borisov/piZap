//
//  PZEditProfile.m
//  piZap
//
//  Created by Assure Developer on 6/14/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZEditProfile.h"
#import "PZImagePicker.h"
#import "PZBGImagePicker.h"

#import "AppData.h"
#import "PZAPI.h"

#import <SVProgressHUD.h>
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <NKOColorPickerView.h>


@interface PZEditProfile ()<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, PZImagePickerDelegate, PZBGImagePickerDelegate>{
    UIImage * _imageProfile;
    NKOColorPickerView *colorPickerView;
}

@property (nonatomic, weak) IBOutlet UIImageView *userImagePhoto;
@property (nonatomic, weak) IBOutlet UITextField *txtUsername;
@property (nonatomic, weak) IBOutlet UITextView *txtViewDescription;

@property (nonatomic, weak) IBOutlet UIImageView *imgBackground;
@property (nonatomic, weak) IBOutlet UIView *viewBackgrounds;

@end

@implementation PZEditProfile


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    [self loadSelfInformation];
    
    //Dismiss Keyboard outside of it
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Dismiss Keyboard outside of it
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapGesture];
    
    //Setup Color Picker
    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
        //Your code handling a color change in the picker view.
        [self.viewBackgrounds setBackgroundColor:color];
    };
    
    colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(60, 250, 200, 300) color:self.viewBackgrounds.backgroundColor andDidChangeColorBlock:colorDidChangeBlock];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *targetVC = [segue destinationViewController];
    
    if ([targetVC isMemberOfClass:[PZImagePicker class]]) {
        PZUserInfo *myInfo = [AppData appData].me;
        [(PZImagePicker*)targetVC setStrUsername:myInfo.strUserName];
        [(PZImagePicker*)targetVC setIsPublic:YES];
        [(PZImagePicker*)targetVC setDelegate:self];
    }
    else if ([targetVC isMemberOfClass:[PZBGImagePicker class]]){
        PZUserInfo *myInfo = [AppData appData].me;
        [(PZBGImagePicker*)targetVC setStrUsername:myInfo.strUserName];
        [(PZBGImagePicker*)targetVC setIsPublic:YES];
        [(PZBGImagePicker*)targetVC setDelegate:self];

    }
}

#pragma mark - Web Service call
- (void)loadSelfInformation{
    [SVProgressHUD show];
    [PZAPI getUserDetailsWithAccessToken:[AppData appData].userAccessToken ach:@"0" andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult && responseObj) {
            //Save my info
            PZUserInfo *myInfo = [[PZUserInfo alloc] initWithJson:responseObj];
            [[AppData appData] setMe:myInfo];
            
            [self reloadInformation];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My Profile Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
}

#pragma mark - UI Designs
-(void)dismissKeyboard {
    [self.txtViewDescription resignFirstResponder];
    [self.txtUsername resignFirstResponder];
    
    if (colorPickerView.superview != nil) {
        [colorPickerView removeFromSuperview];
        [(JASidePanelController*)self.sidePanelController setAllowLeftSwipe:YES];
    }
}
- (void)reloadInformation{
    self.txtUsername.text = [AppData appData].me.strName;
    if (self.txtUsername.text.length == 0) {
        self.txtUsername.text = [AppData appData].me.strUserName;
    }
    self.txtViewDescription.text = [AppData appData].me.strTagline;
    
    
    NSString *strProfileImgURL = [AppData appData].me.strProfileImageURL;
    strProfileImgURL = [AppData fixURLForPizap:strProfileImgURL];
    [self.userImagePhoto sd_setImageWithURL:[NSURL URLWithString:strProfileImgURL]];
//    if ([[AppData appData].me.strProfileImageURL containsString:@"pizap"]) {
//        [self.userImagePhoto sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http:%@", [AppData appData].me.strProfileImageURL]]];
//    }
//    else{
//        [self.userImagePhoto sd_setImageWithURL:[NSURL URLWithString:[AppData appData].me.strProfileImageURL]];
//    }
    
    self.userImagePhoto.layer.cornerRadius = self.userImagePhoto.frame.size.width / 2.;
    self.userImagePhoto.clipsToBounds = YES;
    
    //Background image and color
    NSString *strGalleryStyle = [AppData appData].me.strGalleryStyle;
    if (strGalleryStyle.length > 0) {
        NSArray *components = [strGalleryStyle componentsSeparatedByString:@","];
        int rValue = [[components objectAtIndex:0] intValue];
        int gValue = [[components objectAtIndex:1] intValue];
        int bValue = [[components objectAtIndex:2] intValue];
        NSString *strBGImageURL = [components lastObject];
        
        UIColor *bgColor = [UIColor colorWithRed:rValue / 255. green:gValue / 255. blue:bValue / 255. alpha:1.0f];
        [self.viewBackgrounds setBackgroundColor:bgColor];
        [colorPickerView setColor:bgColor];
        
        if (strBGImageURL && strBGImageURL.length > 0 ) {
            [self.imgBackground sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:strBGImageURL]]];
        }
        else{
            [self.imgBackground setImage:[UIImage new]];
        }
    }
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - User Interaction

- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickOnBGButton:(id)sender{
    [self.txtViewDescription resignFirstResponder];
    [self.txtUsername resignFirstResponder];
    
    if (colorPickerView.superview != nil) {
        [colorPickerView removeFromSuperview];
        [(JASidePanelController*)self.sidePanelController setAllowLeftSwipe:YES];
    }
}

- (IBAction)clickOnProfilePhotoCamera:(id)sender{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PiZap" message:@"Camera is not available right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    UIImagePickerController *imagerPicker = [[UIImagePickerController alloc] init];
    imagerPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagerPicker.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
    imagerPicker.delegate = self;
    [self.navigationController presentViewController:imagerPicker animated:YES completion:nil];
}

- (IBAction)clickOnProfilePhotoLibrary:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose from Library", @"Select piZap Image", @"Import from Facebook", @"Delete Current Photo", nil];
    [actionSheet showInView:self.navigationController.view];
}

- (IBAction)clickOnBGColor:(id)sender{
    //Add color picker to your view
    [self.view addSubview:colorPickerView];
    
    //Disable Swipe Gesture for Side Menu
    [(JASidePanelController*)self.sidePanelController setAllowLeftSwipe:NO];
}

- (IBAction)clickOnBGImagePicker:(id)sender{
    [self performSegueWithIdentifier:@"GoToBGSelection" sender:self];
}

- (IBAction)clickOnBGImageDelete:(id)sender{
    [self.imgBackground setImage:[UIImage new]];
}

- (IBAction)clickOnSave{
    if ([AppData isFieldEmpty:self.txtUsername]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save User Setting Error" message:@"Username is empty!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (self.txtViewDescription.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save User Setting Error" message:@"Tagline is empty!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //Save User Setting on the Server
    [SVProgressHUD show];
    NSString *strProfileURL = [self.userImagePhoto sd_imageURL].absoluteString;
    
    NSString *strBGImageURL = [self.imgBackground sd_imageURL].absoluteString;
    UIColor *color = self.viewBackgrounds.backgroundColor;
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSString *strStyle = [NSString stringWithFormat:@"%d,%d,%d,%@", (int)(red * 255.f), (int)(green * 255.f), (int)(blue * 255.f), [AppData fixURLForPizap:strBGImageURL]];
    
    [PZAPI saveUserSettingWithName:self.txtUsername.text tagline:self.txtViewDescription.text style:strStyle profileImage:strProfileURL email:nil access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL resultBool) {
       [SVProgressHUD dismiss];

        if (resultBool) {
            NSLog(@"Successfully Saved");
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving My Profile Photo Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
}

- (void)clickOnDeleteProfilePhoto{
    NSString *strDefaultUserImgURL = @"http://pizapssl.global.ssl.fastly.net/pizapfiles/images/default_user_photo.gif";
    [self.userImagePhoto sd_setImageWithURL:[NSURL URLWithString:strDefaultUserImgURL]];
}

#pragma mark - API Interaction

- (void)goToMyPizapAlbum{
    [self performSegueWithIdentifier:@"GoToPiZapAlbum" sender:self];
}

- (void)saveProfileImage{
    UIImage *convertedProfileImg = [AppData imageWithImage:_imageProfile scaledToSize:CGSizeMake(150., 150.)];
    NSData *profileImgData = UIImageJPEGRepresentation(convertedProfileImg, 1.0);
    
    //Post Image
    [SVProgressHUD show];
    
    [PZAPI postImageWithTitle:@"" posttofacebook:@"no" publicvalue:@"no" posttotwitter:@"no" posttotumblr:@"no" data:profileImgData access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id response) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            NSLog(@"Successfully Uploaded");
            NSString *strImageName = [response objectForKey:@"imagename"];
            NSString *strImageURL = [NSString stringWithFormat:@"http://thumbnailsw.pizap.com/%@", strImageName];
            
            [self.userImagePhoto sd_setImageWithURL:[NSURL URLWithString:strImageURL]];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving My Profile Photo Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){ //Album
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PiZap" message:@"Camera roll is not available right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
        UIImagePickerController *imagerPicker = [[UIImagePickerController alloc] init];
        imagerPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagerPicker.delegate = self;
        [self.navigationController presentViewController:imagerPicker animated:YES completion:nil];
        
    }
    else if (buttonIndex == 1){ //piZap Album
        [self goToMyPizapAlbum];
    }
    else if (buttonIndex == 2){ //Facebook
        
    }
    else if (buttonIndex == 3){ //Delete
        [self clickOnDeleteProfilePhoto];
    }
    
}

#pragma mark - Image Picker Controller Delegate Methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *imageData = [info objectForKey:UIImagePickerControllerOriginalImage];
    _imageProfile = imageData;
    
    [self saveProfileImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PZImagePicker Delegate
- (void)imagePicker:(PZImagePicker *)viewController didChooseImage:(NSString *)strImageURL{
    [self.userImagePhoto sd_setImageWithURL:[NSURL URLWithString:strImageURL]];
}

#pragma mark - PZBGImagePicker Delegate
- (void)imagePicker:(PZImagePicker *)viewController didChooseThemeImage:(NSString *)strImageURL withBGColor:(UIColor *)bgColor{
    [self.imgBackground sd_setImageWithURL:[NSURL URLWithString:strImageURL]];
    [self.viewBackgrounds setBackgroundColor:bgColor];
    colorPickerView.color = bgColor;
}

-(void)imagePicker:(PZBGImagePicker *)viewController didChoosePiZapImage:(NSString *)strImageURL{
    [self.imgBackground sd_setImageWithURL:[NSURL URLWithString:strImageURL]];
}

@end
