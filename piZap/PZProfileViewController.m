//
//  PZProfileViewController.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZProfileViewController.h"
#import "PZFollowVC.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PZPhotoDetailVC.h"

#import "AppData.h"
#import "PZAPI.h"
#import <SVProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"

@interface PZProfileViewController (){
    BOOL isMyProfile;
    BOOL isFollow;
    int nPages;
    
    BOOL isFirstLoad;
    UIRefreshControl *refreshControl;
    NSUInteger selectedRow;
}

@property (nonatomic, strong) NSArray *arrayPizapImgInfos;

@property (nonatomic, weak) IBOutlet UIImageView *imgPhotoView;

@property (nonatomic, weak) IBOutlet UICollectionView *myImageCollectionView;

@property (nonatomic, weak) IBOutlet UILabel *lblName;

@property (nonatomic, weak) IBOutlet UILabel *lblDescription;

@property (nonatomic, weak) IBOutlet UILabel *lblNPizapImages;

@property (nonatomic, weak) IBOutlet UILabel *lblFollowers;

@property (nonatomic, weak) IBOutlet UILabel *lblFollowings;

@property (nonatomic, weak) IBOutlet UIButton *btnFollowOrEditProfile;

@property (nonatomic, weak) IBOutlet UIView *viewBackground;

@property (nonatomic, weak) IBOutlet UIImageView *imgBackground;

@property (nonatomic, weak) IBOutlet UIImageView *imgBackBtn;

@property (nonatomic, weak) IBOutlet UIImageView *imgMenuBtn;

@property (nonatomic, strong) PZUserInfo *userInfo;

@end

@implementation PZProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imgPhotoView.layer.cornerRadius = self.imgPhotoView.frame.size.width / 2.;
    self.imgPhotoView.clipsToBounds = YES;
    
    //Update the back button
    if ([self.navigationController.viewControllers count] > 1) { //if not a Root View Controller
        self.imgBackBtn.hidden = NO;
        self.imgMenuBtn.hidden = YES;
    }
    else{
        self.imgBackBtn.hidden = YES;
        self.imgMenuBtn.hidden = NO;
    }
    
    //Show the edit profile
    PZUserInfo *me = [AppData appData].me;
    
    if (!self.strUsername || self.strUsername.length == 0) {
        self.strUsername = me.strUserName;
    }
    
    if ([self.strUsername isEqualToString:me.strUserName]) {  //Edit profile
        [self.btnFollowOrEditProfile setBackgroundImage:[UIImage imageNamed:@"editprofile_btn"] forState:UIControlStateNormal];
        isMyProfile = YES;
    }
    else{  //Follow Or UnFollow Button
        
        [self.btnFollowOrEditProfile setBackgroundImage:[UIImage imageNamed:@"profile_follow_btn"] forState:UIControlStateNormal];
        [self firstCheckFollowing];
        isMyProfile = NO;
    }
    
    //Initialize array
    self.arrayPizapImgInfos = [NSArray array];
    //Initialize the page number
    nPages = 1;
    
    //Initialize the flag for first load
    isFirstLoad = YES;
    
    //Add Top Refresh
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.myImageCollectionView addSubview:refreshControl];
    self.myImageCollectionView.alwaysBounceVertical = YES;
    
    //Add bottom refresh
    __weak PZProfileViewController *weakSelf = self;
    [self.myImageCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMorePizapImages];
    }];
    
    [self.myImageCollectionView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    self.myImageCollectionView.showsInfiniteScrolling = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Load user info
    [self loadUserInfo];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"GoToFollowingUsers"]) {
        PZFollowVC *followingVC = [segue destinationViewController];
        [followingVC setStrUsername:self.strUsername];
        [followingVC setIsFollowOrFollower:YES];
    }
    else if ([segue.identifier isEqualToString:@"GoToFollowerUsers"]) {
        PZFollowVC *followerVC = [segue destinationViewController];
        [followerVC setStrUsername:self.strUsername];
        [followerVC setIsFollowOrFollower:NO];
    }
    else if ([segue.identifier isEqualToString:@"GoToImageDetail"]) {
        PZPhotoDetailVC *photoDetailVC = [segue destinationViewController];
        NSDictionary *dicImageInfo = [self.arrayPizapImgInfos objectAtIndex:selectedRow];
        [photoDetailVC setStrImageName:dicImageInfo[@"image_name"]];
    }
}


#pragma mark - UI Design
- (void)updateFollowButton{
    if (isFollow) {
        [self.btnFollowOrEditProfile setBackgroundImage:[UIImage imageNamed:@"profile_following_btn"] forState:UIControlStateNormal];
    }
    else{
        [self.btnFollowOrEditProfile setBackgroundImage:[UIImage imageNamed:@"profile_follow_btn"] forState:UIControlStateNormal];
    }
}
- (void)refreshUI{
    if (self.userInfo.strName.length > 0) {
        self.lblName.text = self.userInfo.strName;
    }
    else{
        self.lblName.text = self.userInfo.strUserName;
    }

    self.lblDescription.text = [self.userInfo.strTagline stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    self.lblNPizapImages.text = [NSString stringWithFormat:@"%d piZaps", self.userInfo.numberPhotos];
    self.lblFollowers.text = [NSString stringWithFormat:@"%d followers", self.userInfo.followerCount];
    self.lblFollowings.text = [NSString stringWithFormat:@"%d followings", self.userInfo.followingCount];
    [self.imgPhotoView sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:self.userInfo.strProfileImageURL]]];
    
    NSString *strGalleryStyle = self.userInfo.strGalleryStyle;
    if (strGalleryStyle.length > 0) {
        NSArray *components = [strGalleryStyle componentsSeparatedByString:@","];
        int rValue = [[components objectAtIndex:0] intValue];
        int gValue = [[components objectAtIndex:1] intValue];
        int bValue = [[components objectAtIndex:2] intValue];
        NSString *strBGImageURL = [components lastObject];
        UIColor *bgColor = [UIColor colorWithRed:rValue / 255. green:gValue / 255. blue:bValue / 255. alpha:1.0f];
        [self.viewBackground setBackgroundColor:bgColor];
        if (strBGImageURL && strBGImageURL.length > 0 ) {
            [self.imgBackground sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:strBGImageURL]]];
        }

    }

    if (isFirstLoad) {
        isFirstLoad = NO;
        [self loadPizapImages];
    }

}

- (void)refershControlAction{
    [self loadPizapImages];
}

#pragma mark - API integration

- (void)loadUserInfo{
    [SVProgressHUD show];
    [PZAPI GetUserInfoWithUsername:self.strUsername access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        if (isResult) {
            [SVProgressHUD dismiss];
            self.userInfo = [[PZUserInfo alloc] initWithJson:responseObj];
            [self refreshUI];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My Profile Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
}

- (void)loadMorePizapImages{
    nPages ++;
    
    __weak PZProfileViewController *weakSelf = self;
    [PZAPI GetListOfPhotosForUserWithUserName:self.userInfo.strUserName isPublic:[NSNumber numberWithBool:YES] access_token:[AppData appData].userAccessToken page:nPages andCompletionBlock:^(BOOL isResult, id resultObj) {
        
        if (isResult) {
            if ([resultObj count] > 0) {
                
                self.arrayPizapImgInfos = [self.arrayPizapImgInfos arrayByAddingObjectsFromArray:resultObj];//[NSMutableArray arrayWithArray:resultObj];
                [weakSelf.myImageCollectionView reloadData];
                weakSelf.myImageCollectionView.showsInfiniteScrolling = YES;
            }
            else{
                weakSelf.myImageCollectionView.showsInfiniteScrolling = NO;
            }

        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting PiZap Image Error" message:resultObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
        [self.myImageCollectionView.infiniteScrollingView stopAnimating];
    }];
}

- (void)loadPizapImages{
    nPages = 1;
    
    [SVProgressHUD show];
    [PZAPI GetListOfPhotosForUserWithUserName:self.userInfo.strUserName isPublic:[NSNumber numberWithBool:YES] access_token:[AppData appData].userAccessToken page:nPages andCompletionBlock:^(BOOL isResult, id resultObj) {
        [SVProgressHUD dismiss];
        
        [refreshControl endRefreshing];
        
        if (isResult) {
            self.arrayPizapImgInfos = [NSMutableArray arrayWithArray:resultObj];
            [self.myImageCollectionView reloadData];
            [self.myImageCollectionView scrollRectToVisible:CGRectMake(0, 0, 0, 0) animated:YES];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My PiZap Image Error" message:resultObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
}

- (void)followUser{
    [SVProgressHUD show];
    [PZAPI FollowWithUserName:self.userInfo.strUserName access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            if ([[responseObj objectForKey:@"following"] boolValue]) { //UnFollowed
                isFollow = NO;
            }
            else{ //Followed
                isFollow = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self updateFollowButton];
            });
            
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Follow a User Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
}

- (void)firstCheckFollowing{
    
    [SVProgressHUD show];
    PZUserInfo *me = [AppData appData].me;
    [PZAPI GetFollowingsWithUserName:me.strUserName access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            NSArray *arrayUsers = [NSMutableArray arrayWithArray:responseObj];
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"u == %@", self.strUsername];
            NSArray *result = [arrayUsers filteredArrayUsingPredicate:pred];
            isFollow = result.count > 0;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self updateFollowButton];
            });
            
            
            
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Following Users Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

#pragma mark - User Interaction

- (IBAction)clickOnMenuButton:(id)sender{
    if (self.navigationController.viewControllers.count == 1) {
        [self.sidePanelController toggleLeftPanel:nil];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)clickOnFollowOrEditProfile:(id)sender{
    if (isMyProfile) {  //Go To Edit profile view
        [self performSegueWithIdentifier:@"GoToEditProfile" sender:self];
    }
    else{  //Do a follow
        [self followUser];
    }
}

- (IBAction)clickOnSettingButton:(id)sender{
    [self performSegueWithIdentifier:@"GoToEditProfile" sender:self];
}

#pragma mark - CollectionView DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [self.arrayPizapImgInfos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ProfileImageCollectionCell";
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                  forIndexPath:indexPath];
    
    NSDictionary *dicInfo = [self.arrayPizapImgInfos objectAtIndex:indexPath.row];
    NSString *strImageUrl = [dicInfo objectForKey:@"s"];
    UIImageView *imgPhoto = (UIImageView*)[cell.contentView viewWithTag:100];
    [imgPhoto sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:strImageUrl]]];
    
    imgPhoto.layer.cornerRadius = 3;
    imgPhoto.clipsToBounds = YES;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"GoToImageDetail" sender:self];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}




@end
