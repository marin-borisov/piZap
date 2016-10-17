//
//  PZFollowVC.ms
//  piZap
//
//  Created by Assure Developer on 6/14/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZFollowVC.h"
#import "PZFollowCell.h"
#import "PZProfileViewController.h"

#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>

@interface PZFollowVC ()<UITableViewDataSource, UITableViewDelegate>{
    
    
    NSInteger selectedRow;
}

@property (nonatomic, weak) IBOutlet UITableView *tblUsers;

@property (nonatomic, weak) IBOutlet UILabel *lblViewTitle;

@property (nonatomic, strong) NSMutableArray *arrayUsers;

@end


@implementation PZFollowVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.arrayUsers = [NSMutableArray array];
    if (self.isFollowOrFollower) {
        [self loadFollowingUsers];
        self.lblViewTitle.text = @"Followings";
    }
    else{
        [self loadFollowerUsers];
        self.lblViewTitle.text = @"Followers";
    }
    
    self.tblUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GoToUserProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        NSDictionary *dicUserInfo = [self.arrayUsers objectAtIndex:selectedRow];
        [profileVC setStrUsername:[dicUserInfo objectForKey:@"u"]];
    }
}

#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{ 
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickOnFollow:(id)sender{
    NSUInteger row = [(UIButton*)sender tag];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[self.arrayUsers objectAtIndex:row]];
    
    [SVProgressHUD show];
    [PZAPI FollowWithUserName:[userInfo objectForKey:@"u"] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            if ([[responseObj objectForKey:@"following"] boolValue]) { //UnFollowed
                [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"following"];
            }
            else{ //Followed
                [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"following"];
            }
            
            [self.arrayUsers replaceObjectAtIndex:row withObject:userInfo];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tblUsers beginUpdates];
            [self.tblUsers reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tblUsers endUpdates];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Follow a User Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
}

#pragma mark - API Integration
- (void)loadFollowingUsers{
    [SVProgressHUD show];
    [PZAPI GetFollowingsWithUserName:self.strUsername access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            self.arrayUsers = [NSMutableArray arrayWithArray:responseObj];
            [self.tblUsers reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Following Users Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)loadFollowerUsers{
    
    [SVProgressHUD show];
    [PZAPI GetFollowsWithUserName:self.strUsername access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            self.arrayUsers = [NSMutableArray arrayWithArray:responseObj];
            [self.tblUsers reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Following Users Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}


#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayUsers count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellForFollowUsers";
    PZFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[PZFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicUserInfo = [self.arrayUsers objectAtIndex:indexPath.row];
    
    
    [cell.imgProfilePhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicUserInfo objectForKey:@"profileImage"]]]];
    
    NSString *strName = [dicUserInfo objectForKey:@"n"];
    if (!strName || strName.length == 0) {
        strName = [dicUserInfo objectForKey:@"u"];
    }
    cell.lblName.text = strName;
    
    cell.btnFollow.tag = indexPath.row;
    if ([[dicUserInfo objectForKey:@"following"] boolValue]) {
        [cell.btnFollow setBackgroundImage:[UIImage imageNamed:@"following_btn"] forState:UIControlStateNormal];
    }
    else{
        [cell.btnFollow setBackgroundImage:[UIImage imageNamed:@"blue_follow_btn"] forState:UIControlStateNormal];
    }
    [cell.btnFollow addTarget:self action:@selector(clickOnFollow:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[dicUserInfo objectForKey:@"u"] isEqualToString:[AppData appData].me.strUserName]) {
        cell.btnFollow.enabled = NO;
    }
    else{
        cell.btnFollow.enabled = YES;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"GoToUserProfile" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
