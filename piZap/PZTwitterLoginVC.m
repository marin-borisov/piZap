//
//  PZTwitterLoginVC.m
//  piZap
//
//  Created by Assure Developer on 8/1/15
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZTwitterLoginVC.h"

#import "AppData.h"

#import "PZAPI.h"
#import <SVProgressHUD.h>

@interface PZTwitterLoginVC () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation PZTwitterLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    NSURL *urlForTWLogin = [NSURL URLWithString:@"http://www.pizap.com/oauth/authorize?twitter=1&client_id=mobile_ipad&native=yes&response_type=token&redirect_uri=pizap://login"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:urlForTWLogin]];
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

#pragma mark - Web View Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"url : %@", request.URL.absoluteString);
    if ([request.URL.absoluteString hasPrefix:@"pizap://login"]){
        NSString *strURL = request.URL.absoluteString;
        NSArray *arrayParams = [strURL componentsSeparatedByString:@"access_token="];
        NSString *strAccessToken = [[[arrayParams objectAtIndex:1] componentsSeparatedByString:@"&"] objectAtIndex:0];
        [AppData appData].userAccessToken = strAccessToken;
        [AppData appData].isLoggedIn = YES;
        
        [SVProgressHUD dismiss];
        
        [[AppData appData] goToLoggedInVC];
//        [self performSegueWithIdentifier:@"GoToMainVC" sender:self];
        
        return NO;
    }
    
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [SVProgressHUD show];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
}

@end
