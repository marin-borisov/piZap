//
//  PZSearchUserVC.m
//  piZap
//
//  Created by Assure Developer on 8/1/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZSearchUserVC.h"
#import "PZFollowCell.h"
#import "PZProfileViewController.h"

#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>


@interface PZSearchUserVC ()<UITableViewDataSource, UITableViewDelegate>{
    NSInteger selectedRow;
}

@property (nonatomic, weak) IBOutlet UIView *viewBtnContainer;

@property (nonatomic, weak) IBOutlet UITableView *tblUsers;

@property (nonatomic, weak) IBOutlet UITextField *txtSearch;

@property (nonatomic, strong) NSMutableArray *arrayUsers;

@end


@implementation PZSearchUserVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.arrayUsers = [NSMutableArray array];
    self.tblUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.viewBtnContainer.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.viewBtnContainer.layer.shadowOffset = CGSizeMake(0., 1.5f);
    self.viewBtnContainer.layer.borderWidth = 0.5f;
    self.viewBtnContainer.layer.borderColor = [UIColor grayColor].CGColor;
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GoToUserProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        NSDictionary *dicUserInfo = [self.arrayUsers objectAtIndex:selectedRow];
        [profileVC setStrUsername:[dicUserInfo objectForKey:@"UserName"]];
    }
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self loadUsersWithSearch];
    
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickOnFollow:(id)sender{
    NSUInteger row = [(UIButton*)sender tag];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[self.arrayUsers objectAtIndex:row]];
    
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
- (void)loadUsersWithSearch{
    if (self.txtSearch.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Search Text is empty!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD show];
    [PZAPI SearchForMatchingUsersWithSearch:[self.txtSearch.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            self.arrayUsers = [NSMutableArray arrayWithArray:responseObj];
            [self.tblUsers reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Search Users Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
    static NSString *CellIdentifier = @"CellForSearchUser";
    PZFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[PZFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicUserInfo = [self.arrayUsers objectAtIndex:indexPath.row];
    
    
    [cell.imgProfilePhoto sd_setImageWithURL:[NSURL URLWithString:[AppData urlForUserPhoto:[dicUserInfo objectForKey:@"UserName"]]]];
    
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

