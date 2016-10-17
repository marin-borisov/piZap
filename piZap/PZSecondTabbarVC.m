//
//  PZSecondTabbarVC.m
//  piZap
//
//  Created by Assure Developer on 8/4/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZSecondTabbarVC.h"
#import "PZFeedViewController.h"

@interface PZSecondTabbarVC ()

@end

@implementation PZSecondTabbarVC

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
    [super prepareForSegue:segue sender:sender];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *targetVC = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"viewController2"]) { //Following
        PZFeedViewController *feedVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        [feedVC setIsFollowFeedOrPopularFeed:YES];
    }
    else if ([segue.identifier isEqualToString:@"viewController3"]) { //Popular
        PZFeedViewController *feedVC = [[(UINavigationController*)targetVC viewControllers] firstObject];
        [feedVC setIsFollowFeedOrPopularFeed:NO];
    }
    
    [(UINavigationController*)self.destinationViewController popToRootViewControllerAnimated:YES];
}


@end
