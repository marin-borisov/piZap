//
//  PZFirstLoginVC.m
//  piZap
//
//  Created by Assure Developer on 6/11/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZFirstLoginVC.h"
#import "AppData.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "PZAPI.h"
#import <SVProgressHUD.h>

#import "PZSignupWithFacebook.h"

@interface PZFirstLoginVC (){
    NSString *strUserEmail;
}

@end

@implementation PZFirstLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Check if there is access_token already
    if ([AppData appData].userAccessToken && [AppData appData].userAccessToken.length > 0) { //Already have a token
        //Go to Main View
        [self goToMainVC];
        return;
    }
    
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    FBSDKLoginManager *loginmanager= [[FBSDKLoginManager alloc]init];
    [loginmanager logOut];
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
    
    if([segue.destinationViewController isMemberOfClass:[PZSignupWithFacebook class]]){
        PZSignupWithFacebook *fbSignupVC = (PZSignupWithFacebook*)segue.destinationViewController;
        fbSignupVC.strFBUserName = [FBSDKProfile currentProfile].name;
        fbSignupVC.strFBProfileImg = [[FBSDKProfile currentProfile] imagePathForPictureMode:FBSDKProfilePictureModeNormal size:CGSizeMake(100., 100.)];
        fbSignupVC.strFBUserEmail = strUserEmail;
    }
}



#pragma mark - User Interaction Methods
- (IBAction)clickFBButton:(id)sender{
    //Check Internet Connection
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [SVProgressHUD show];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Login Error" message:error.debugDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            [SVProgressHUD dismiss];
        } else if (result.isCancelled) {
            
            // Handle cancellations
            [SVProgressHUD dismiss];
        } else {
            if ([result.grantedPermissions containsObject:@"email"]) {
                if ([FBSDKAccessToken currentAccessToken]) {
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id FBResult, NSError *error) {
                        if (!error) {
                            
                            
                            [PZAPI ProcessFBWithClientID:@"mobile_ipad" response_type:@"token" id:[FBSDKProfile currentProfile].userID email:[FBResult objectForKey:@"email"] name:[FBSDKProfile currentProfile].name gender:[FBResult objectForKey:@"gender"] token:[FBSDKAccessToken currentAccessToken].tokenString andCompletionBlock:^(BOOL isSuccess, id responseObj) {

                                [SVProgressHUD dismiss];
                                if (isSuccess) {
                                    [SVProgressHUD show];
                                    [PZAPI getUserDetailsWithAccessToken:[AppData appData].userAccessToken ach:@"0" andCompletionBlock:^(BOOL isResult, id responseObj) {
                                        [SVProgressHUD dismiss];
                                        
                                        if (isResult && responseObj) {
                                            //Save my info
                                            PZUserInfo *myInfo = [[PZUserInfo alloc] initWithJson:responseObj];
                                            [[AppData appData] setMe:myInfo];
                                            [AppData appData].isLoggedIn = YES;
                                            
                                            [self goToMainVC];
                                        }
                                        else{
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My Profile Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                            [alertView show];
                                            return;
                                        }
                                    }];
                                }
                                else{
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Login Error" message:error.debugDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alertView show];
                                }

                            }];
                        }
                        else{
                            [SVProgressHUD dismiss];
                        }
                     }];
                }
            }
        }
    }];
}

- (void)goToMainVC{
    [[AppData appData] goToLoggedInVC];
//    [self performSegueWithIdentifier:@"GoToMainVC" sender:self];
}


@end
