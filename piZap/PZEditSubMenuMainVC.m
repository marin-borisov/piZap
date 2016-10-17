//
//  PZEditSubMenuMainVC.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZEditSubMenuMainVC.h"
#import "PZEditMainVC.h"
#import "AppData.h"

@interface PZEditSubMenuMainVC ()

@property (nonatomic, weak) IBOutlet UIButton *btnEditCollage;

@end

@implementation PZEditSubMenuMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([AppData appData].isEditableCollage) {
        self.btnEditCollage.enabled = YES;
    }
    else{
        self.btnEditCollage.enabled = NO;
    }
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

#pragma mark - Meme

- (IBAction)clickMeme:(id)sender{
    PZEditMainVC *mainVC = (PZEditMainVC*)[self.navigationController parentViewController];
    [mainVC memeClicked];

}

@end
