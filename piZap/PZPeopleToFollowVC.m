//
//  PZPeopleToFollowVC.m
//  piZap
//
//  Created by Assure Developer on 8/1/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZPeopleToFollowVC.h"
#import "PZUserShortInfo.h"
#import "PZFollowCell.h"
#import "PZProfileViewController.h"

#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>


@interface PZPeopleToFollowVC (){
    NSInteger selectedRow;
}

@property (nonatomic, weak) IBOutlet UIView *viewBtnContainer;

@property (nonatomic, weak) IBOutlet UIButton *btnFollowAll;

@property (nonatomic, weak) IBOutlet UITableView *tblUsers;


@end

@implementation PZPeopleToFollowVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.tblUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Customize some views
    self.btnFollowAll.layer.cornerRadius = 5.f;
    self.btnFollowAll.clipsToBounds = YES;
    self.btnFollowAll.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.btnFollowAll.layer.borderWidth = 1.0f;
    
    self.viewBtnContainer.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.viewBtnContainer.layer.shadowOffset = CGSizeMake(0., 1.5f);
    self.viewBtnContainer.layer.borderWidth = 0.5f;
    self.viewBtnContainer.layer.borderColor = [UIColor grayColor].CGColor;
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GoToUserProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        PZUserShortInfo *userInfo = [self.arrayUsers objectAtIndex:selectedRow];
        [profileVC setStrUsername:userInfo.strUsername];
    }
}

#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickOnFollowAllBtn:(id)sender{
    
    NSInteger nUsers = [self.arrayUsers count];
    NSInteger nUsersToFollow = 0;
    __block NSInteger nIndexs = 0;
    
    [SVProgressHUD show];
    for (int i = 0; i < nUsers; i ++) {
        PZUserShortInfo *userInfo = [self.arrayUsers objectAtIndex:i];
        if (userInfo.isFollowing) {
            continue;
        }
        
        nUsersToFollow ++;
        nIndexs ++;
    
        [PZAPI FollowWithUserName:userInfo.strUsername access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
            
            nIndexs --;
            if (nIndexs == 0) {
                [SVProgressHUD dismiss];
            }
            
            if (isResult) {
                if ([[responseObj objectForKey:@"following"] boolValue]) { //UnFollowed
                    userInfo.isFollowing = NO;
                }
                else{ //Followed
                    userInfo.isFollowing = YES;
                }
                
                [self.arrayUsers replaceObjectAtIndex:i withObject:userInfo];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
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
    
    if (nUsersToFollow == 0) {
        [SVProgressHUD dismiss];
    }
}

- (void)clickOnFollow:(id)sender{
    NSUInteger row = [(UIButton*)sender tag];
    PZUserShortInfo *userInfo = [self.arrayUsers objectAtIndex:row];
    
    [SVProgressHUD show];
    [PZAPI FollowWithUserName:userInfo.strUsername access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            if ([[responseObj objectForKey:@"following"] boolValue]) { //UnFollowed
                userInfo.isFollowing = NO;
            }
            else{ //Followed
                userInfo.isFollowing = YES;
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
    static NSString *CellIdentifier = @"CellForFindPeople";
    PZFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[PZFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    PZUserShortInfo *userInfo = [self.arrayUsers objectAtIndex:indexPath.row];
    [cell.imgProfilePhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:userInfo.strProfileImageURL]]];
    
    NSString *strName = userInfo.strName;
    if (!strName || strName.length == 0) {
        strName = userInfo.strUsername;
    }
    cell.lblName.text = strName;
    
    cell.btnFollow.tag = indexPath.row;
    if (userInfo.isFollowing) {
        [cell.btnFollow setBackgroundImage:[UIImage imageNamed:@"following_btn"] forState:UIControlStateNormal];
    }
    else{
        [cell.btnFollow setBackgroundImage:[UIImage imageNamed:@"blue_follow_btn"] forState:UIControlStateNormal];
    }
    [cell.btnFollow addTarget:self action:@selector(clickOnFollow:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([userInfo.strUsername isEqualToString:[AppData appData].me.strUserName]) {
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
