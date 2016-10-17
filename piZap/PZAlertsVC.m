//
//  PZAlertsVC.m
//  piZap
//
//  Created by Assure Developer on 8/1/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZAlertsVC.h"
#import "PZProfileViewController.h"

#import "PZAlertCell.h"

#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PZPhotoDetailVC.h"


@interface PZAlertsVC (){
    NSInteger selectedRow;
    
}

@property (nonatomic, weak) IBOutlet UITableView *tblAlerts;

@property (nonatomic, strong) NSMutableArray *arrayAlerts;

@end

@implementation PZAlertsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrayAlerts = [NSMutableArray array];
    [self loadAlertsFromAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"GoToImageDetail"]) {
        PZPhotoDetailVC *photoDetailVC = [segue destinationViewController];
        NSDictionary *dicAlertInfo = [self.arrayAlerts objectAtIndex:selectedRow];
        [photoDetailVC setStrImageName:dicAlertInfo[@"ImageName"]];
    }
    else if ([segue.identifier isEqualToString:@"GoToProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        NSDictionary *dicAlertInfo = [self.arrayAlerts objectAtIndex:selectedRow];
        [profileVC setStrUsername:[dicAlertInfo objectForKey:@"RelatedUserName"]];
    }
    
}

#pragma mark - User Interaction

- (IBAction)clickOnSearchButton:(id)sender{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *VC = [sb instantiateViewControllerWithIdentifier:@"PZFindPeopleVC"];
    [self.navigationController pushViewController:VC animated:YES];
}


- (IBAction)clickOnMenuBtn:(id)sender{
    if (self.navigationController.viewControllers.count == 1) {
        [self.sidePanelController toggleLeftPanel:nil];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickOnFollow:(id)sender{
    NSUInteger row = [(UIButton*)sender tag];
    NSMutableDictionary *alertInfo = [NSMutableDictionary dictionaryWithDictionary:[self.arrayAlerts objectAtIndex:row]];
    
    [SVProgressHUD show];
    [PZAPI FollowWithUserName:[alertInfo objectForKey:@"RelatedUserName"] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
//            if ([[responseObj objectForKey:@"following"] boolValue]) { //UnFollowed
//                [alertInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isFollowing"];
//            }
//            else{ //Followed
//                [alertInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isFollowing"];
//            }
//            
//            [self.arrayAlerts replaceObjectAtIndex:row withObject:alertInfo];
//            
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//            [self.tblAlerts beginUpdates];
//            [self.tblAlerts reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.tblAlerts endUpdates];
            [self loadAlertsFromAPI];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Follow a User Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
}

- (void)clickOnPizapImage:(id)sender{
    selectedRow = [(UIButton*)sender tag];
    [self performSegueWithIdentifier:@"GoToImageDetail" sender:self];
}

-(IBAction)clickOnProfileName:(id)sender{
    selectedRow = [(UIButton*)sender tag];
    [self performSegueWithIdentifier:@"GoToProfile" sender:self];
}


#pragma mark - API CAll
- (void) loadAlertsFromAPI{
    [SVProgressHUD show];
    [PZAPI GetNotificationsWithAccessToken:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            self.arrayAlerts = [NSMutableArray arrayWithArray:responseObj];
            [self.tblAlerts reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Alerts Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayAlerts count];
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
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else{
        cell.backgroundColor = [UIColor colorWithRed:246./255. green:246./255. blue:246./255. alpha:1.0];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlertCell";
    PZAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[PZAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicAlertInfo = [self.arrayAlerts objectAtIndex:indexPath.row];
    NSString *strType = [dicAlertInfo objectForKey:@"Type"];
    
    [cell.imgProfilePhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicAlertInfo objectForKey:@"RelatedProfileImageUrl"]]]];
    
    cell.lblName.text = [dicAlertInfo objectForKey:@"RelatedName"];
    if (cell.lblName.text.length == 0) {
        cell.lblName.text = [dicAlertInfo objectForKey:@"RelatedUserName"];
    }
    [cell.lblName setStrUsername:[dicAlertInfo objectForKey:@"RelatedUserName"]];
    
    cell.btnProfileImage.tag = indexPath.row;
    [cell.btnProfileImage addTarget:self action:@selector(clickOnProfileName:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnNameLabel.tag = indexPath.row;
    [cell.btnNameLabel addTarget:self action:@selector(clickOnProfileName:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.lblTimeStamp.text = [dicAlertInfo objectForKey:@"CreatedDescription"];
    
    
    if ([strType isEqualToString:@"FollowUser"]) {
        [cell setCellType:FOLLOWING_USER];
        
        cell.btnFollowOrUnfollow.tag = indexPath.row;
        if ([[dicAlertInfo objectForKey:@"isFollowing"] boolValue]) {
            [cell.btnFollowOrUnfollow setBackgroundImage:[UIImage imageNamed:@"following_btn"] forState:UIControlStateNormal];
        }
        else{
            [cell.btnFollowOrUnfollow setBackgroundImage:[UIImage imageNamed:@"blue_follow_btn"] forState:UIControlStateNormal];
        }
        [cell.btnFollowOrUnfollow addTarget:self action:@selector(clickOnFollow:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([strType isEqualToString:@"LikeUser"]) {
        [cell setCellType:LIKING_USER];
        
        cell.btnFollowOrUnfollow.tag = indexPath.row;
        if ([[dicAlertInfo objectForKey:@"isFollowing"] boolValue]) {
            [cell.btnFollowOrUnfollow setBackgroundImage:[UIImage imageNamed:@"following_btn"] forState:UIControlStateNormal];
        }
        else{
            [cell.btnFollowOrUnfollow setBackgroundImage:[UIImage imageNamed:@"blue_follow_btn"] forState:UIControlStateNormal];
        }
        [cell.btnFollowOrUnfollow addTarget:self action:@selector(clickOnFollow:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([strType isEqualToString:@"RepostPhoto"]) {
        [cell setCellType:REPOSTING_PHOTO];
        [cell.imgPhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicAlertInfo objectForKey:@"ImageSmallUrl"]]]];
        
        cell.btnImage.tag = indexPath.row;
        [cell.btnImage addTarget:self action:@selector(clickOnPizapImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([strType isEqualToString:@"LikePhoto"]) {
        [cell setCellType:LIKING_PHOTO];
        
        [cell.imgPhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicAlertInfo objectForKey:@"ImageSmallUrl"]]]];
        cell.btnImage.tag = indexPath.row;
        [cell.btnImage addTarget:self action:@selector(clickOnPizapImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([strType isEqualToString:@"CommentPhoto"]) {
        [cell setCellType:COMMENTING_PHOTO];
        
        [cell.imgPhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicAlertInfo objectForKey:@"ImageSmallUrl"]]]];
        cell.btnImage.tag = indexPath.row;
        [cell.btnImage addTarget:self action:@selector(clickOnPizapImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([strType isEqualToString:@"FriendJoined"]) {
        [cell setCellType:FRIEND_JOIN];
        
        cell.btnFollowOrUnfollow.tag = indexPath.row;
        if ([[dicAlertInfo objectForKey:@"isFollowing"] boolValue]) {
            [cell.btnFollowOrUnfollow setBackgroundImage:[UIImage imageNamed:@"following_btn"] forState:UIControlStateNormal];
        }
        else{
            [cell.btnFollowOrUnfollow setBackgroundImage:[UIImage imageNamed:@"blue_follow_btn"] forState:UIControlStateNormal];
        }
        [cell.btnFollowOrUnfollow addTarget:self action:@selector(clickOnFollow:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}


@end
