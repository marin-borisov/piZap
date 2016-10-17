//
//  PZSideMenuViewController.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZSideMenuViewController.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>

#import "PZHomeViewController.h"
#import "PZProfileViewController.h"
#import "PZFeedViewController.h"
#import "PZMultiSelectorVC.h"
#import "PZEditMainVC.h"
#import "PZEditTextVC.h"
#import "PZEditProfile.h"
#import "PZFindPeopleVC.h"
#import "PZSecondTabbarVC.h"

#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>

@interface PZSideMenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UILabel *lblTagLine;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePhoto;

@end

@implementation PZSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imgProfilePhoto.layer.cornerRadius = CGRectGetWidth(self.imgProfilePhoto.frame) / 2.0f;
    self.imgProfilePhoto.clipsToBounds = YES;
    self.imgProfilePhoto.backgroundColor = [UIColor whiteColor];
    self.imgProfilePhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgProfilePhoto.layer.borderWidth = 3;
    
    [self reloadInformation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)reloadInformation{
    self.lblName.text = [AppData appData].me.strName;
    if (self.lblName.text.length == 0) {
        self.lblName.text = [AppData appData].me.strUserName;
    }
    
    self.lblTagLine.text = [AppData appData].me.strTagline;
    
    
    NSString *strProfileImgURL = [AppData appData].me.strProfileImageURL;
    strProfileImgURL = [AppData fixURLForPizap:strProfileImgURL];
    [self.imgProfilePhoto sd_setImageWithURL:[NSURL URLWithString:strProfileImgURL]];
}

#pragma mark - User Interaction
- (IBAction)clickOnLogOutButton:(id)sender{
    [[AppData appData] loggedOut];
}

- (IBAction)clickOnHome:(id)sender{
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    [(UINavigationController*)self.sidePanelController.centerPanel popToRootViewControllerAnimated:YES];
}

- (IBAction)clickOnEditProfile:(id)sender{
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    PZSecondTabbarVC *mainTabbar = [AppData appData].mainTabBarVC;
    
    //Check if it is already open
    if( [[(UINavigationController*)mainTabbar.destinationViewController topViewController] isMemberOfClass:[PZEditProfile class]]){
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *VC = [sb instantiateViewControllerWithIdentifier:@"PZEditProfile"];
    [(UINavigationController*)mainTabbar.destinationViewController pushViewController:VC animated:YES];
}

- (IBAction)clickOnFindPeople:(id)sender{
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    PZSecondTabbarVC *mainTabbar = [AppData appData].mainTabBarVC;
    
    //Check if it is already open
    if( [[(UINavigationController*)mainTabbar.destinationViewController topViewController] isMemberOfClass:[PZFindPeopleVC class]]){
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *VC = [sb instantiateViewControllerWithIdentifier:@"PZFindPeopleVC"];
    [(UINavigationController*)mainTabbar.destinationViewController pushViewController:VC animated:YES];
}


@end
