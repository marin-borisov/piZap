//
//  PZSignupWithEmail.m
//  piZap
//
//  Created by Assure Developer on 6/11/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZSignupWithEmail.h"

#import "AppData.h"

#import "PZAPI.h"
#import <SVProgressHUD.h>


@interface PZSignupWithEmail ()

@property (nonatomic, weak) IBOutlet UITextField *txtUsername;
@property (nonatomic, weak) IBOutlet UITextField *txtPassword;
@property (nonatomic, weak) IBOutlet UITextField *txtEmail;

@end

@implementation PZSignupWithEmail

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

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == self.txtUsername) {
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField == self.txtPassword) {
        [self.txtEmail becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - User Interaction
- (IBAction)clickOnRegister:(id)sender{
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
    
    if ([AppData isFieldEmpty:self.txtEmail]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Error" message:@"Email is empty!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (![AppData isFieldEmail:self.txtEmail]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Error" message:@"Email is not correct email address!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD show];

    [PZAPI registerWithClientID:@"mobile_ipad" response_type:@"token" isajax:@"1" username:self.txtUsername.text password:self.txtPassword.text password_c:self.txtPassword.text email:self.txtEmail.text email_c:self.txtEmail.text mobile:YES andCompletionBlock:^(BOOL result, id responseObj) {
        [SVProgressHUD dismiss];
        if (result) {
            NSLog(@"Successfully registered");
            
            //Save my info
            PZUserInfo *myInfo = [[PZUserInfo alloc] initWithJson:responseObj];
            
            [[AppData appData] setMe:myInfo];
            [AppData appData].userAccessToken = myInfo.strToken;
            [AppData appData].isLoggedIn = YES;
            [self goToMainVC];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
    [self.txtEmail resignFirstResponder];
}

- (void)goToMainVC{
    [[AppData appData] goToLoggedInVC];
//    [self performSegueWithIdentifier:@"GoToMainVC" sender:self];
}

@end
