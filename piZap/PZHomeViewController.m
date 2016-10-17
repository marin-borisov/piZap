//
//  PZHomeViewController.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZHomeViewController.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>

#import "PZProfileViewController.h"
#import "PZFeedViewController.h"
#import "PZSelectPhotoVC.h"
#import "PZEditMainVC.h"
#import "AppData.h"
#import "PZAPI.h"

#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>
#import <TOCropViewController.h>

@interface PZHomeViewController () <PZSelectPhotoVCDelegate, TOCropViewControllerDelegate>

@property (nonatomic, strong) UIImage *imgToEdit;

@end

@implementation PZHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([AppData appData].isLoggedIn){
        //Load image and user information
        [self loadSelfInformation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My Profile Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController *targetVC = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"GoToMyPiZap"]) {
        PZUserInfo *me = [AppData appData].me;
        PZProfileViewController *profileVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        [profileVC setStrUsername:me.strUserName];
    }
    else if ([segue.identifier isEqualToString:@"GoToPopularFeed"]) {
        PZFeedViewController *feedVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        [feedVC setIsFollowFeedOrPopularFeed:NO];
    }
    else if ([segue.identifier isEqualToString:@"GoToFollowingFeed"]) {
        PZFeedViewController *feedVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        [feedVC setIsFollowFeedOrPopularFeed:YES];
    }
    else if ([segue.identifier isEqualToString:@"GoToPhotoSelect"]) {
        PZSelectPhotoVC *photoSelectVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        photoSelectVC.multiSelection = NO;
        photoSelectVC.multiSelectionCount = 0;
        photoSelectVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"GoToEditMainVC"]) {
        PZEditMainVC *editMainVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        [editMainVC setImage:self.imgToEdit];
    }
}


#pragma mark - User Interaction

- (IBAction)clickOnMenuButton:(id)sender{
    [self.sidePanelController toggleLeftPanel:nil];
}


- (IBAction)clickOnSearchButton:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *VC = [sb instantiateViewControllerWithIdentifier:@"PZFindPeopleVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.imgToEdit = image;
    [cropViewController dismissAnimatedFromParentViewController:self withCroppedImage:image toFrame:CGRectZero completion:^{
        //Go to the main edit vc
        [self performSegueWithIdentifier:@"GoToEditMainVC" sender:self];
    }];
}

#pragma mark - Photo Select VC Delegate
-(void)selectPhotoController:(PZSelectPhotoVC *)viewController didChooseImage:(UIImage *)image{
    //GoToCrop Screen
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:image];
    cropController.delegate = self;
    [self presentViewController:cropController animated:YES completion:nil];
}

-(void)selectPhotoController:(PZSelectPhotoVC *)viewController didChooseMultiImages:(NSArray *)imageArray{
    
}

@end
