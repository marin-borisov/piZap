//
//  PZBaseViewController.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZBaseViewController.h"
#import "AppData.h"
#import "PZSecondTabbarVC.h"

@interface PZBaseViewController ()

@end

@implementation PZBaseViewController


-(void) awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"]];
    
    self.panningLimitedToTopViewController = NO;
    self.rightGapPercentage = 8.5f;
}

- (void)stylePanel:(UIView *)panel {
    [super stylePanel:panel];
    
    [panel.layer setCornerRadius:0.0f];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Save the second tabbar
    [AppData appData].mainTabBarVC = (PZSecondTabbarVC*)self.centerPanel;
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

@end
