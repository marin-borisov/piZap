//
//  PZPhotoDetailVC.m
//  piZap
//
//  Created by Assure Developer on 7/29/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZPhotoDetailVC.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PZFeedTableCell.h"
#import "PZProfileViewController.h"
#import "PZCommentVC.h"
#import "PZLikesUserVC.h"

#import "AppData.h"
#import "PZAPI.h"
#import <SVProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "DateTools.h"
#import "PZClickableLabelForUsername.h"
#import <MessageUI/MessageUI.h>

#define TOP_USER_INFO_HEIGHT 42.f
#define IMAGE_SECTION_HEIGHT 214.f
#define PHOTO_TITLE_HEIGHT 30.f
#define LIKE_BUTTON_SECTION_HEIGHT 30.f
#define COMMENT_SECTION_HEIGHT 176.f
#define CELL_GAP_HEIGHT 18.f

@interface PZPhotoDetailVC ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>{
    NSInteger selectedRow;
    NSMutableDictionary *photoDetail;
    NSArray *arrayLikes;
    
    BOOL isFromViewComment;
}

@property (nonatomic, strong) NSMutableDictionary *dicCellHeight;

@property (nonatomic, weak) IBOutlet UITableView *tblPhotoDetail;

@end

@implementation PZPhotoDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    photoDetail = nil;
    arrayLikes = [NSArray array];
    
    self.dicCellHeight = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadPhotoDetailsFromAPI];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"GoToUserProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        [profileVC setStrUsername:[photoDetail objectForKey:@"UserName"]];
    }
    else if ([segue.identifier isEqualToString:@"GoToComment"]) {
        PZCommentVC *commentVC = [segue destinationViewController];
        [commentVC setIsOpenKeyboard:!isFromViewComment];
        [commentVC setStrImageName:[photoDetail objectForKey:@"ImageName"]];
    }
    else if ([segue.identifier isEqualToString:@"GoToUserProfileInLikes"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        NSDictionary *userInfo = [arrayLikes objectAtIndex:selectedRow];
        [profileVC setStrUsername:[userInfo objectForKey:@"UserName"]];
    }
    else if ([segue.identifier isEqualToString:@"GoToLikeUsers"]) {
        PZLikesUserVC *likeUserVC = [segue destinationViewController];
        [likeUserVC setArrayLikeUsers:[NSMutableArray arrayWithArray:arrayLikes]];
    }else if ([segue.identifier isEqualToString:@"GoToUserProfileFromComment"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        NSString *strUsername = [(PZClickableLabelForUsername*)sender strUsername];
        [profileVC setStrUsername:strUsername];
    }
    
}

#pragma mark - User Interaction

- (IBAction)clickOnMenuButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)clickOnUserPhoto:(id)sender{
    [self performSegueWithIdentifier:@"GoToUserProfile" sender:self];
}

- (void)clickOnLikeButton:(id)sender{
    
    BOOL isLike;
    NSArray *likeUsers = [arrayLikes valueForKey:@"UserName"];
    if ([likeUsers containsObject:[AppData appData].me.strUserName]) {
        isLike = YES;
    }
    else{
        isLike = NO;
    }
    
    [SVProgressHUD show];
    [PZAPI PostImageLikeWithImageName:[photoDetail objectForKey:@"ImageName"] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult) {
        [SVProgressHUD dismiss];
        if (isResult) {
            [self loadPhotoDetailsFromAPI];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Like a Image Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
}

- (void)clickOnMoreOptionButton:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", @"Email", @"Save to Photos", nil];
    [actionSheet showInView:self.navigationController.view];
}

- (void)clickOnCommentButton:(id)sender{
    isFromViewComment = NO;
    [self performSegueWithIdentifier:@"GoToComment" sender:self];
}

- (void)clickOnMoreCommentButton:(id)sender{
    isFromViewComment = YES;
    [self performSegueWithIdentifier:@"GoToComment" sender:self];
}


- (void)clickOnUserLikeList:(id)sender{
    selectedRow = [(UIButton*)sender tag];
    [self performSegueWithIdentifier:@"GoToUserProfileInLikes" sender:self];
}

- (void)clickMoreLikeUsers{
    [self performSegueWithIdentifier:@"GoToLikeUsers" sender:self];
}

- (void)clickOnUsernameOnComment:(UITapGestureRecognizer*)tapGesture{
    UIView *lblUser = [tapGesture view];
    
    [self performSegueWithIdentifier:@"GoToUserProfileFromComment" sender:lblUser];
}

#pragma mark - API integration
- (void)loadPhotoDetailsFromAPI{
    [SVProgressHUD show];
    [PZAPI GetDetailsForImageWithImageName:self.strImageName access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        if (isResult) {
            photoDetail = [NSMutableDictionary dictionaryWithDictionary:responseObj];
            arrayLikes = [NSArray arrayWithArray:[photoDetail objectForKey:@"LikeUsers"]];
            [self.tblPhotoDetail reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Photo Details Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];

}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){ //Report
        [SVProgressHUD show];
        [PZAPI ReportImageWithImageName:[photoDetail objectForKey:@"ImageName"] access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult) {
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
        
        PZFeedTableCell *selectedCell = (PZFeedTableCell*)[self.tblPhotoDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
        PZFeedTableCell *selectedCell = (PZFeedTableCell*)[self.tblPhotoDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
    NSDictionary *dicFeedInfo = photoDetail;
    NSArray *arrayComments = [dicFeedInfo objectForKey:@"CommentList"];
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
    if (photoDetail) {
        if (arrayLikes.count > 0) {
            return 2;
        }
        else{
            return 1;
        }
    }
    else{
        return 0;
    }

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
    if (indexPath.row == 0) {
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
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FeedCellIdentifier = @"CellForFeed";
    static NSString *LikeUserCellIdentifier = @"CellForLikeUsers";
    
    if (indexPath.row == 0) {
        
        PZFeedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[PZFeedTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *dicFeedInfo = photoDetail;
        cell.lblName.text = [dicFeedInfo objectForKey:@"Name"];
        if (cell.lblName.text.length == 0) {
            cell.lblName.text = [dicFeedInfo objectForKey:@"UserName"];
        }
        
        cell.lblCommentCount.text = [NSString stringWithFormat:@"%d Comments", [[dicFeedInfo objectForKey:@"Comments"] intValue]];
        
        
        NSDate *dateToCreate = [NSDate dateWithTimeIntervalSince1970:[[dicFeedInfo objectForKey:@"Created"] floatValue]];
        cell.lblTimeStamp.text = [dateToCreate timeAgoSinceNow];
        cell.lblFavoriteCount.text = [[dicFeedInfo objectForKey:@"Likes"] stringValue];
        cell.lblPhotoTitle.text = [dicFeedInfo objectForKey:@"Title"];
        if (cell.lblPhotoTitle.text.length == 0) {
            cell.lblPhotoTitle.text = [NSString stringWithFormat:@"%d Viewed", [[dicFeedInfo objectForKey:@"Views"] intValue]];
        }

        if ([[dicFeedInfo objectForKey:@"Tags"] count] > 0) {
            cell.lblTag.text = [NSString stringWithFormat:@"#%@", [[dicFeedInfo objectForKey:@"Tags"] componentsJoinedByString:@", #"]];
        }
        else{
            cell.lblTag.text = @"";
        }
        
        
//        [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicFeedInfo objectForKey:@"mediumUrl"]]]];
        [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:[dicFeedInfo objectForKey:@"mediumUrl"]]]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          [cell.activityView removeFromSuperview];
                                          if (![self.dicCellHeight objectForKey:@(indexPath.row).stringValue]){
                                              //Calculate the height
                                              float photoHeight = 0;
                                              CGRect rect = cell.photoImageView.frame;
                                              photoHeight = rect.size.width / image.size.width * image.size.height;
                                              
                                              //Save height info
                                              [self.dicCellHeight setObject:[NSNumber numberWithFloat:photoHeight] forKey:@(indexPath.row).stringValue];
                                              
                                              //Update this cell
                                              [self.tblPhotoDetail beginUpdates];
                                              [self.tblPhotoDetail reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                              [self.tblPhotoDetail endUpdates];
                                              
                                          }
                                      }];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[AppData urlForUserPhoto:[dicFeedInfo objectForKey:@"UserName"]]]];
        
        [cell.btnProfile addTarget:self action:@selector(clickOnUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnLikeButtonUp addTarget:self action:@selector(clickOnLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnLikeButtonDown addTarget:self action:@selector(clickOnLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMoreOptions addTarget:self action:@selector(clickOnMoreOptionButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnComment addTarget:self action:@selector(clickOnCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMoreComment addTarget:self action:@selector(clickOnMoreCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *likeUsers = [arrayLikes valueForKey:@"UserName"];
        if ([likeUsers containsObject:[AppData appData].me.strUserName]) {
            [cell.imgLikeIcon setImage:[UIImage imageNamed:@"like_active_btn"]];
        }
        else{
            [cell.imgLikeIcon setImage:[UIImage imageNamed:@"like_btn"]];            
        }
        
        ////Clear the comment box
        for (UIView *subView in cell.viewComment.subviews) {
            [subView removeFromSuperview];
        }
        
        float yGap = 33.;
        NSArray *arrayComments = [dicFeedInfo objectForKey:@"CommentList"];
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
        rect.size.height = 110. - lineHeight;
        [cell.imgLineView setFrame:rect];
        
        CGRect rectForMoreButton = cell.viewMoreComment.frame;
        rectForMoreButton.origin.y = 120. - lineHeight;
        [cell.viewMoreComment setFrame:rectForMoreButton];
        cell.btnMoreComment.center = cell.viewMoreComment.center;
        
        return cell;
    }
    else if (indexPath.row == 1) {  //Like User Cell
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LikeUserCellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UILabel *lblNLikes = (UILabel*)[cell viewWithTag:100];
        lblNLikes.text = [NSString stringWithFormat:@"%d", (int)arrayLikes.count];
        
        UIView *viewContent = [cell viewWithTag:101];
        ////Clear the comment box
        for (UIView *subView in viewContent.subviews) {
            [subView removeFromSuperview];
        }
        
        int nLimitCount = 7;
        float xGap = 3.;
        float sizeForPhoto = 32.f;
        for (int i = 0; i < nLimitCount && i < arrayLikes.count; i ++) {
            NSDictionary *dicUserInfo = [arrayLikes objectAtIndex:i];
            UIImageView *imgPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(0 + i * (xGap + sizeForPhoto), 0, sizeForPhoto, sizeForPhoto)];
            [imgPhotoView setContentMode:UIViewContentModeScaleAspectFill];
            [imgPhotoView sd_setImageWithURL:[NSURL URLWithString:[AppData fixURLForPizap:dicUserInfo[@"ProfileImage"]]]];
            imgPhotoView.layer.cornerRadius = imgPhotoView.frame.size.width / 2.;
            imgPhotoView.clipsToBounds = YES;
            imgPhotoView.layer.borderColor = [UIColor grayColor].CGColor;
            imgPhotoView.layer.borderWidth = 0.5f;
            
            UIButton *btnPhoto = [[UIButton alloc] initWithFrame:imgPhotoView.frame];
            btnPhoto.tag = i;
            [btnPhoto addTarget:self action:@selector(clickOnUserLikeList:) forControlEvents:UIControlEventTouchUpInside];
            
            [viewContent addSubview:imgPhotoView];
            [viewContent addSubview:btnPhoto];
        }
        
        UIButton *btnMore = (UIButton*)[cell viewWithTag:102];
        [btnMore addTarget:self action:@selector(clickMoreLikeUsers) forControlEvents:UIControlEventTouchUpInside];

        
        return cell;
    }

    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return [self calculateCellHeight:indexPath];
    }
    else if (indexPath.row == 1) {
        return 65.;
    }
    else{
        return 200;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
