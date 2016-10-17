//
//  PZLoginWithEmail.m
//  piZap
//
//  Created by Assure Developer on 6/11/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZLoginWithEmail.h"
#import "AppData.h"
#import "PZAPI.h"
#import <SVProgressHUD.h>

@interface PZLoginWithEmail ()

@property (nonatomic, weak) IBOutlet UITextField *txtUsername;
@property (nonatomic, weak) IBOutlet UITextField *txtPassword;

@end

@implementation PZLoginWithEmail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickOnForgetPasswordBtn:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://piZap.com"]];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == self.txtUsername) {
        [self.txtPassword becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - User Interaction
- (IBAction)clickOnLogin:(id)sender{
    if ([AppData isFieldEmpty:self.txtUsername]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Username is empty!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if ([AppData isFieldEmpty:self.txtPassword]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Password is empty!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD show];
    
    [PZAPI loginWithClientID:@"mobile_ipad" response_type:@"token" isajax:@"1" username:self.txtUsername.text password:self.txtPassword.text ach:@"1" andCompletionBlock:^(BOOL result, id responseObj) {
        [SVProgressHUD dismiss];
        if (result) {
            NSLog(@"Successfully login");
            
            //Save my info
            PZUserInfo *myInfo = [[PZUserInfo alloc] initWithJson:responseObj];
            [[AppData appData] setMe:myInfo];
            
            //Save tokens
            [AppData appData].userAccessToken = myInfo.strToken;
            [AppData appData].userRefreshToken = [[responseObj objectForKey:@"fragment"] objectForKey:@"refresh_token"];
            [AppData appData].isLoggedIn = YES;
            
            [self goToMainVC];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (IBAction)clickOnBGButton:(id)sender{
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (void)goToMainVC{
    [[AppData appData] goToLoggedInVC];
//    [self performSegueWithIdentifier:@"GoToMainVC" sender:self];
}


@end
