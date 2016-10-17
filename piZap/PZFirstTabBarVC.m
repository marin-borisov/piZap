//
//  PZFirstTabBarVC.m
//  piZap
//
//  Created by Assure Developer on 8/4/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZFirstTabBarVC.h"

@interface PZFirstTabBarVC ()

@end

@implementation PZFirstTabBarVC

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

#pragma mark - User interaction
- (IBAction)clickOnFollowTab:(id)sender{
    [self performSegueWithIdentifier:@"viewController1" sender:[self.buttons objectAtIndex:0]];
}

- (IBAction)clickOnAlertsTab:(id)sender{
    [self performSegueWithIdentifier:@"viewController1" sender:[self.buttons objectAtIndex:0]];
}



@end
