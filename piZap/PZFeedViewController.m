//
//  PZFeedViewController.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZFeedViewController.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PZFeedTableCell.h"
#import "PZProfileViewController.h"
#import "PZCommentVC.h"
#import "PZPhotoDetailVC.h"

#import "AppData.h"
#import "PZAPI.h"
#import <SVProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "PZClickableLabelForUsername.h"

#import <MessageUI/MessageUI.h> 


#define TOP_USER_INFO_HEIGHT 42.f
#define IMAGE_SECTION_HEIGHT 214.f
#define PHOTO_TITLE_HEIGHT 30.f
#define LIKE_BUTTON_SECTION_HEIGHT 30.f
#define CELL_GAP_HEIGHT 18.f

@interface PZFeedViewController ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>{
    int nPagesForFeed;
    NSInteger selectedRow;
    
    BOOL isFromViewComment;
}

@property (nonatomic, strong) NSMutableArray *arrayFeeds;

@property (nonatomic, strong) NSMutableDictionary *dicCellHeight;

@property (nonatomic, weak) IBOutlet UITableView *feedTableView;

@end

@implementation PZFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Initialize the variables
    nPagesForFeed = 1;
    self.arrayFeeds = [NSMutableArray array];
    self.dicCellHeight = [NSMutableDictionary dictionary];
    selectedRow = 0;
    
    //Call API for feeds
    [self loadFeed];
    
    //Add Bottom
    __weak PZFeedViewController *weakSelf = self;
    [self.feedTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreFeed];
    }];
    
    [self.feedTableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    self.feedTableView.showsInfiniteScrolling = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API Call

- (void)loadFeed{
    if (self.isFollowFeedOrPopularFeed) { //Following Feed
        nPagesForFeed = 1;
        [SVProgressHUD show];
        [PZAPI GetGalleryListForFollowingFeedWithPage:[NSString stringWithFormat:@"%d", nPagesForFeed] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
            [SVProgressHUD dismiss];
            if (isResult) {
                self.arrayFeeds = [NSMutableArray arrayWithArray:responseObj];
                [self.feedTableView reloadData];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Following Feed Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
        }];
    }
    else{  //Popular Feed
        nPagesForFeed = 1;
        [SVProgressHUD show];
        [PZAPI GetGalleryListForPopularFeedWithPage:[NSString stringWithFormat:@"%d", nPagesForFeed] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
            [SVProgressHUD dismiss];
            if (isResult) {
                self.arrayFeeds = [NSMutableArray arrayWithArray:responseObj];
                [self.feedTableView reloadData];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Popular Feed Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
        }];

    }
}

- (void)loadMoreFeed{
    nPagesForFeed ++;
    
    if (self.isFollowFeedOrPopularFeed) { //Following Feed
        [PZAPI GetGalleryListForFollowingFeedWithPage:[NSString stringWithFormat:@"%d", nPagesForFeed] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
            
            if (isResult) {
                if ([responseObj count] > 0) {
                    [self.arrayFeeds addObjectsFromArray:responseObj];
                    [self.feedTableView reloadData];
                    self.feedTableView.showsInfiniteScrolling = YES;
                }
                else{
                    self.feedTableView.showsInfiniteScrolling = NO;
                }
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting More Following Feed Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            [self.feedTableView.infiniteScrollingView stopAnimating];
        }];

    }
    else{  //Popular Feed
        [PZAPI GetGalleryListForPopularFeedWithPage:[NSString stringWithFormat:@"%d", nPagesForFeed] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
            
            if (isResult) {
                if ([responseObj count] > 0) {
                    [self.arrayFeeds addObjectsFromArray:responseObj];
                    [self.feedTableView reloadData];
                    self.feedTableView.showsInfiniteScrolling = YES;
                }
                else{
                    self.feedTableView.showsInfiniteScrolling = NO;
                }
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting More Popular Feed Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            [self.feedTableView.infiniteScrollingView stopAnimating];
        }];

        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"GoToUserProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        NSDictionary *dicFeedInfo = [self.arrayFeeds objectAtIndex:selectedRow];
        [profileVC setStrUsername:[dicFeedInfo objectForKey:@"u"]];
    }
    else if ([segue.identifier isEqualToString:@"GoToComment"]) {
        PZCommentVC *commentVC = [segue destinationViewController];
        
        NSDictionary *dicFeedInfo = [self.arrayFeeds objectAtIndex:selectedRow];
        [commentVC setStrImageName:[dicFeedInfo objectForKey:@"image_name"]];
        [commentVC setIsOpenKeyboard:!isFromViewComment];
    }
    else if ([segue.identifier isEqualToString:@"GoToPhotoDetail"]) {
        PZCommentVC *commentVC = [segue destinationViewController];
        
        NSDictionary *dicFeedInfo = [self.arrayFeeds objectAtIndex:selectedRow];
        [commentVC setStrImageName:[dicFeedInfo objectForKey:@"image_name"]];
    }
    else if ([segue.identifier isEqualToString:@"GoToUserProfileFromComment"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        NSString *strUsername = [(PZClickableLabelForUsername*)sender strUsername];
        [profileVC setStrUsername:strUsername];
    }
    
}

#pragma mark - User Interaction

- (IBAction)clickOnSearchButton:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *VC = [sb instantiateViewControllerWithIdentifier:@"PZFindPeopleVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)clickOnMenuButton:(id)sender{
    if (self.navigationController.viewControllers.count == 1) {
        [self.sidePanelController toggleLeftPanel:nil];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)clickOnUserPhoto:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    selectedRow = [(UIButton*)sender tag];
    [self performSegueWithIdentifier:@"GoToUserProfile" sender:self];
}

- (void)clickOnLikeButton:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    selectedRow = [(UIButton*)sender tag];
    
    NSMutableDictionary *dicFeedInfo = [NSMutableDictionary dictionaryWithDictionary:[self.arrayFeeds objectAtIndex:selectedRow]];
    BOOL isLike = [[dicFeedInfo objectForKey:@"like"] boolValue];
    [SVProgressHUD show];
    [PZAPI PostImageLikeWithImageName:[dicFeedInfo objectForKey:@"image_name"] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult) {
        [SVProgressHUD dismiss];
        if (isResult) {
            [dicFeedInfo setObject:[NSNumber numberWithBool:!isLike] forKey:@"like"];
            
            int nLikes = [[dicFeedInfo objectForKey:@"likes"] intValue];
            if (!isLike) {
                nLikes ++;
            }else{
                nLikes --;
                if (nLikes < 0) {
                    nLikes = 0;
                }
            }
            
            
            [dicFeedInfo setObject:[NSNumber numberWithInt:nLikes] forKey:@"likes"];
            [self.arrayFeeds replaceObjectAtIndex:selectedRow withObject:dicFeedInfo];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
            
            [self.feedTableView beginUpdates];
            [self.feedTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [self.feedTableView endUpdates];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Like a Image Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
}

- (void)clickOnMoreOptionButton:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    selectedRow = [(UIButton*)sender tag];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", @"Email", @"Save to Photos", nil];
    [actionSheet showInView:self.navigationController.view];
}

- (void)clickOnCommentButton:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    selectedRow = [(UIButton*)sender tag];
    isFromViewComment = NO;
    [self performSegueWithIdentifier:@"GoToComment" sender:self];
}

- (void)clickOnMoreCommentButton:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    selectedRow = [(UIButton*)sender tag];
    isFromViewComment = YES;
    [self performSegueWithIdentifier:@"GoToComment" sender:self];
}

- (void)clickOnPhotoDetail:(id)sender{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    selectedRow = [(UIButton*)sender tag];
    
    [self performSegueWithIdentifier:@"GoToPhotoDetail" sender:self];
}

- (void)clickOnUsernameOnComment:(UITapGestureRecognizer*)tapGesture{
    if (![AppData appData].isLoggedIn) {
        return;
    }
    
    UIView *lblUser = [tapGesture view];
    
    [self performSegueWithIdentifier:@"GoToUserProfileFromComment" sender:lblUser];
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){ //Report
        NSMutableDictionary *dicFeedInfo = [NSMutableDictionary dictionaryWithDictionary:[self.arrayFeeds objectAtIndex:selectedRow]];
        
        [SVProgressHUD show];
        [PZAPI ReportImageWithImageName:[dicFeedInfo objectForKey:@"image_name"] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult) {
            [SVProgressHUD dismiss];
            if (isResult) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Image reported!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image is not reported correctly!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
        }];

    }
    else if (buttonIndex == 1){ //Email
        
        PZFeedTableCell *selectedCell = (PZFeedTableCell*)[self.feedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
        UIImage *imageToBeSaved = [selectedCell.photoImageView image];
        
        // Email Subject
        NSString *emailTitle = @"A piZap picture for you";
        // Email Content
        NSString *messageBody = @"Created with piZap Photo Editor<BR>http://www.pizap.com";
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        NSData *imageData = UIImagePNGRepresentation(imageToBeSaved);
        [mc addAttachmentData:imageData mimeType:@"image/png" fileName:@"image"];
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else if (buttonIndex == 2){ //Save to Photos
        PZFeedTableCell *selectedCell = (PZFeedTableCell*)[self.feedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
        UIImage *imageToBeSaved = [selectedCell.photoImageView image];
        if(imageToBeSaved){
            [SVProgressHUD show];
            UIImageWriteToSavedPhotosAlbum(imageToBeSaved, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}
#pragma mark - Image Saving to Camera Roll Delegate
- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    [SVProgressHUD dismiss];
    if (!error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"Image has been saved to photos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image has not been saved to photos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Mail Compose Delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Calculation of Cell Height
- (float)calculateCellHeight:(NSIndexPath*)indexPath{
    NSDictionary *dicFeedInfo = [self.arrayFeeds objectAtIndex:indexPath.row];
    NSArray *arrayComments = [dicFeedInfo objectForKey:@"commentList"];
    int nComment = (int)MIN(3, arrayComments.count);
    
    float newHeight = 0;
    newHeight += TOP_USER_INFO_HEIGHT;
    if ([self.dicCellHeight objectForKey:@(indexPath.row).stringValue]) {
        float newPhotoHeight = [[self.dicCellHeight objectForKey:@(indexPath.row).stringValue] floatValue];
        newHeight += newPhotoHeight + 2;
    }
    else{
        newHeight += IMAGE_SECTION_HEIGHT;
    }
    newHeight += PHOTO_TITLE_HEIGHT;
    newHeight += LIKE_BUTTON_SECTION_HEIGHT;
    
    if (nComment > 0) {
        newHeight += 26.f + 33.f * (float)nComment + 20.f;
    }
    
    newHeight += CELL_GAP_HEIGHT;
    return newHeight;
}

#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayFeeds count];
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
    
    //------Reoganize the cell layout------
    
    PZFeedTableCell *myCell = (PZFeedTableCell*)cell;
    float newPhotoHeight = 0;
    if ([self.dicCellHeight objectForKey:@(indexPath.row).stringValue]) {
        newPhotoHeight = [[self.dicCellHeight objectForKey:@(indexPath.row).stringValue] floatValue];
        
        newPhotoHeight += 2;
        //Set changed size to parent content view
        CGRect rectForParentView = myCell.viewPhotoImage.frame;
        rectForParentView.size.height = newPhotoHeight;
        myCell.viewPhotoImage.frame = rectForParentView;
    }
    else{
        newPhotoHeight = IMAGE_SECTION_HEIGHT;
    }
    
    //Set changed size to comment section
    CGRect rect = myCell.viewBottomSection.frame;
    float newHeight = 0;
    newHeight += TOP_USER_INFO_HEIGHT;
    newHeight += newPhotoHeight;
    rect.origin.y = newHeight;
    newHeight += CELL_GAP_HEIGHT;
    rect.size.height = [self calculateCellHeight:indexPath] - newHeight;
    
    myCell.viewBottomSection.frame = rect;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellForFeed";
    PZFeedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[PZFeedTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicFeedInfo = [self.arrayFeeds objectAtIndex:indexPath.row];
    cell.lblName.text = [dicFeedInfo objectForKey:@"n"];
    if (cell.lblName.text.length == 0) {
        cell.lblName.text = [dicFeedInfo objectForKey:@"u"];
    }
    
    cell.lblCommentCount.text = [NSString stringWithFormat:@"%d Comments", [[dicFeedInfo objectForKey:@"comments"] intValue]];
    cell.lblTimeStamp.text = [dicFeedInfo objectForKey:@"created"];
    cell.lblFavoriteCount.text = [[dicFeedInfo objectForKey:@"likes"] stringValue];
    cell.lblPhotoTitle.text = [dicFeedInfo objectForKey:@"t"];
    if (cell.lblPhotoTitle.text.length == 0) {
        cell.lblPhotoTitle.text = [NSString stringWithFormat:@"%d Viewed", [[dicFeedInfo objectForKey:@"v"] intValue]];
    }
    
    if ([[dicFeedInfo objectForKey:@"tags"] count] > 0) {
        cell.lblTag.text = [NSString stringWithFormat:@"#%@", [[dicFeedInfo objectForKey:@"tags"] componentsJoinedByString:@", #"]];
    }
    else{
        cell.lblTag.text = @"";
    }
    
    
//    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicFeedInfo objectForKey:@"s"]]]];
    __block PZFeedTableCell *myCell = cell;
    __block UITableView *myTable = self.feedTableView;
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicFeedInfo objectForKey:@"s"]]]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      [myCell.activityView removeFromSuperview];
                                      if (![self.dicCellHeight objectForKey:@(indexPath.row).stringValue]){
                                          //Calculate the height
                                          float photoHeight = 0;
                                          CGRect rect = myCell.photoImageView.frame;
                                          photoHeight = rect.size.width / image.size.width * image.size.height;
                                          
                                          //Save height info
                                          [self.dicCellHeight setObject:[NSNumber numberWithFloat:photoHeight] forKey:@(indexPath.row).stringValue];
                                          
                                          //Update this cell
                                          [myTable beginUpdates];
                                          [myTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                          [myTable endUpdates];

                                      }
                                  }];
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[AppData urlForUserPhoto:[dicFeedInfo objectForKey:@"u"]]]];
    
    cell.btnProfile.tag = indexPath.row;
    [cell.btnProfile addTarget:self action:@selector(clickOnUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnLikeButtonUp.tag = indexPath.row;
    [cell.btnLikeButtonUp addTarget:self action:@selector(clickOnLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnLikeButtonDown.tag = indexPath.row;
    [cell.btnLikeButtonDown addTarget:self action:@selector(clickOnLikeButton:) forControlEvents:UIControlEventTouchUpInside];

    cell.btnMoreOptions.tag = indexPath.row;
    [cell.btnMoreOptions addTarget:self action:@selector(clickOnMoreOptionButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnComment.tag = indexPath.row;
    [cell.btnComment addTarget:self action:@selector(clickOnCommentButton:) forControlEvents:UIControlEventTouchUpInside];

    cell.btnMoreComment.tag = indexPath.row;
    [cell.btnMoreComment addTarget:self action:@selector(clickOnMoreCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //Comment Box
    if ([[dicFeedInfo objectForKey:@"like"] boolValue]) {
        [cell.imgLikeIcon setImage:[UIImage imageNamed:@"like_active_btn"]];
    }
    else{
        [cell.imgLikeIcon setImage:[UIImage imageNamed:@"like_btn"]];
    }
    
    //Click On Photo
    cell.btnPhoto.tag = indexPath.row;
    [cell.btnPhoto addTarget:self action:@selector(clickOnPhotoDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    
    ////Clear the comment box
    for (UIView *subView in cell.viewComment.subviews) {
        [subView removeFromSuperview];
    }
    
    float yGap = 33.;
    NSArray *arrayComments = [dicFeedInfo objectForKey:@"commentList"];
    for (int i = 0; i < 3 && i < arrayComments.count; i ++) {
        NSDictionary *dicComment = [arrayComments objectAtIndex:i];
        
        //Dot
        UIImageView *imgDotView = [[UIImageView alloc] initWithFrame:CGRectMake(16.5, 26. + (float)i * yGap, 6, 6)];
        [imgDotView setImage:[UIImage imageNamed:@"blue_dot"]];
        
        
        //Username
        PZClickableLabelForUsername *lblUsername = [[PZClickableLabelForUsername alloc] initWithFont:[UIFont fontWithName:@"Futura-Medium" size:12.f]
                                                                                         andUsername:[dicComment objectForKey:@"UserName"]];
        [lblUsername setFrame:CGRectMake(30., 20.f + (float)i * yGap, 285.f, 16.f)];
        lblUsername.text = [dicComment objectForKey:@"Name"];
        if (lblUsername.text.length == 0) {
            lblUsername.text = [dicComment objectForKey:@"UserName"];
        }
        [lblUsername setTextColor:[UIColor colorWithRed:108./255. green:104./255. blue:140./255. alpha:1.0]];
        lblUsername.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(clickOnUsernameOnComment:)];
        
        [lblUsername addGestureRecognizer:tap];
        
        
        
        //comment
        UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(32., 34.f + (float)i * yGap, 285.f, 16.f)];
        lblComment.text = [dicComment objectForKey:@"Comment"];
        [lblComment setFont:[UIFont fontWithName:@"GeezaPro" size:10.f]];
        [lblComment setTextColor:[UIColor blackColor]];
        
        //timestamp
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(210., 20.f + (float)i * yGap, 100.f, 16.f)];
        lblTime.text = [dicComment objectForKey:@"CreatedString"];
        lblTime.textAlignment = NSTextAlignmentRight;
        [lblTime setFont:[UIFont fontWithName:@"GeezaPro" size:9.f]];
        [lblTime setTextColor:[UIColor darkGrayColor]];
        
        [cell.viewComment addSubview:imgDotView];
        [cell.viewComment addSubview:lblUsername];
        [cell.viewComment addSubview:lblComment];
        [cell.viewComment addSubview:lblTime];
    }
    
    //Reorder the comment line and view more comments button
    int nComment = (int)MIN(3, arrayComments.count);
    float lineHeight = (float)(3 - nComment) * yGap;
    
    CGRect rect = cell.imgLineView.frame;
    rect.size.height = 110.f - lineHeight;
    [cell.imgLineView setFrame:rect];
    
    CGRect rectForMoreButton = cell.viewMoreComment.frame;
    rectForMoreButton.origin.y = 120. - lineHeight;
    [cell.viewMoreComment setFrame:rectForMoreButton];
    cell.btnMoreComment.center = cell.viewMoreComment.center;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self calculateCellHeight:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CollectionView DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FeedCollectionCell";
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                  forIndexPath:indexPath];
    
    

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
