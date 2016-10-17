//
//  PZEditTextMainMenuVC.m
//  piZap
//
//  Created by RisingSun on 11/13/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import "PZEditTextMainMenuVC.h"
#import "MKInputBoxView.h"
#import "PZEditMainVC.h"

@interface PZEditTextMainMenuVC (){
    NSInteger indexText;
}

@end

@implementation PZEditTextMainMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    if ([segue.identifier isEqualToString:@"GoToText"]) {
        
    }
}

#pragma mark - Input Box
- (void)showInputBoxWithStype:(int)style{
    MKInputBoxView *inputBoxView = [MKInputBoxView boxOfType:PlainTextInput];
    [inputBoxView setTitle:@"Enter text"];
    //    [inputBoxView setMessage:@"Please input!"];
    [inputBoxView setBlurEffectStyle:UIBlurEffectStyleExtraLight];
    
    [inputBoxView setCancelButtonText:@"Cancel"];
    
    inputBoxView.customise = ^(UITextField *textField) {
        textField.placeholder = @"text";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textColor = [UIColor blackColor];
        textField.layer.cornerRadius = 4.0f;
        [textField becomeFirstResponder];
        textField.text = @"";
        return textField;
    };
    
    inputBoxView.onSubmit = ^(NSString *value1, NSString *value2) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        PZEditMainVC *mainVC = (PZEditMainVC*)[self.navigationController parentViewController];
        [mainVC textSelected:value1 withBubbleIndex:style];

        
        return YES;
    };
    
    inputBoxView.onCancel = ^{
        NSLog(@"Cancel!");
    };
    
    [inputBoxView show];
}


#pragma mark - User Interaction
- (IBAction)clickOnBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickOnTextBtn:(id)sender{
    [self showInputBoxWithStype:0];
}

- (IBAction)clickOnCircleBubbleBtn:(id)sender{
    [self showInputBoxWithStype:1];
}

- (IBAction)clickOnRoundBubbleBtn:(id)sender{
    [self showInputBoxWithStype:2];
}

- (IBAction)clickOnSharpBubbleTextBtn:(id)sender{
    [self showInputBoxWithStype:3];
}
@end
