//
//  PZSignupWithFacebook.m
//  piZap
//
//  Created by Assure Developer on 6/14/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZSignupWithFacebook.h"

#import "AppData.h"

#import "PZAPI.h"
#import <SVProgressHUD.h>
#import "UIImageView+WebCache.h"


@interface PZSignupWithFacebook ()

@property (nonatomic, weak) IBOutlet UITextField *txtUsername;
@property (nonatomic, weak) IBOutlet UITextField *txtPassword;

@property (nonatomic, weak) IBOutlet UIImageView *userImagePhoto;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;

@end

@implementation PZSignupWithFacebook

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.lblUserName.text = self.strFBUserName;
    [self.userImagePhoto sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@", self.strFBProfileImg]]];
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
- (IBAction)clickOnRegisterFB:(id)sender{
    if ([AppData isFieldEmpty:self.txtUsername]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Error" message:@"Username is empty!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if ([AppData isFieldEmpty:self.txtPassword]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Error" message:@"Password is empty!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD show];
    
    [PZAPI changeUserNameWithNewUserName:self.txtUsername.text password:self.txtPassword.text email:self.strFBUserEmail access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL result, id errorMsg) {
        [SVProgressHUD dismiss];
        if (result) {
            NSLog(@"Successfully registered");
            [self goToMainVC];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Register Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}
- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickOnBGButton:(id)sender{
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (void)goToMainVC{
    [self performSegueWithIdentifier:@"GoToMainVC" sender:self];
}


@end
