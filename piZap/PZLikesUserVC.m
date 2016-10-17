//
//  PZLikesUserVC.m
//  piZap
//
//  Created by Assure Developer on 7/29/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZLikesUserVC.h"
#import "PZFollowCell.h"
#import "PZProfileViewController.h"

#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>

@interface PZLikesUserVC (){
    NSInteger selectedRow;
}

@property (nonatomic, weak) IBOutlet UITableView *tblUsers;

@end

@implementation PZLikesUserVC

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tblUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GoToUserProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        NSDictionary *dicUserInfo = [self.arrayLikeUsers objectAtIndex:selectedRow];
        [profileVC setStrUsername:[dicUserInfo objectForKey:@"UserName"]];
    }
}

#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickOnFollow:(id)sender{
    NSUInteger row = [(UIButton*)sender tag];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[self.arrayLikeUsers objectAtIndex:row]];
    
    [SVProgressHUD show];
    [PZAPI FollowWithUserName:[userInfo objectForKey:@"UserName"] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            if ([[responseObj objectForKey:@"following"] boolValue]) { //UnFollowed
                [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isFollowing"];
            }
            else{ //Followed
                [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isFollowing"];
            }
            
            [self.arrayLikeUsers replaceObjectAtIndex:row withObject:userInfo];
            
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

#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayLikeUsers count];
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
    
    NSDictionary *dicUserInfo = [self.arrayLikeUsers objectAtIndex:indexPath.row];
    
    
    [cell.imgProfilePhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicUserInfo objectForKey:@"ProfileImage"]]]];
    
    NSString *strName = [dicUserInfo objectForKey:@"Name"];
    if (!strName || strName.length == 0) {
        strName = [dicUserInfo objectForKey:@"UserName"];
    }
    cell.lblName.text = strName;
    
    cell.btnFollow.tag = indexPath.row;
    if ([[dicUserInfo objectForKey:@"isFollowing"] boolValue]) {
        [cell.btnFollow setBackgroundImage:[UIImage imageNamed:@"following_btn"] forState:UIControlStateNormal];
    }
    else{
        [cell.btnFollow setBackgroundImage:[UIImage imageNamed:@"blue_follow_btn"] forState:UIControlStateNormal];
    }
    [cell.btnFollow addTarget:self action:@selector(clickOnFollow:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[dicUserInfo objectForKey:@"UserName"] isEqualToString:[AppData appData].me.strUserName]) {
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
