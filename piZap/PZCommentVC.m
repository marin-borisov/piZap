//
//  PZCommentVC.m
//  piZap
//
//  Created by Assure Developer on 7/29/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZCommentVC.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PZProfileViewController.h"
#import "PZCommentCell.h"

#import "AppData.h"
#import "PZAPI.h"
#import <SVProgressHUD.h>
#import "UIImageView+WebCache.h"

@interface PZCommentVC ()<UITableViewDataSource, UITableViewDelegate>{
    NSInteger selectedRow;
    float scrollContentHeight;
    
    BOOL isFirstTime;
}

@property (nonatomic, strong) NSMutableArray *arrayComments;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollContentView;

@property (nonatomic, weak) IBOutlet UITableView *tblComments;

@property (nonatomic, weak) IBOutlet UITextField *txtComment;

@end

@implementation PZCommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectedRow = 0;
    self.arrayComments = [NSMutableArray array];
    isFirstTime = YES;
    
    scrollContentHeight = 464.;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.scrollContentView setContentSize:CGSizeMake(320., scrollContentHeight)];
    
    //Dismiss Keyboard outside of it
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.scrollContentView addGestureRecognizer:tap];
    
    //Change the color of placeholder for comment text field
    if ([self.txtComment respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:114./255. green:125./255. blue:142./255. alpha:1.0];
        self.txtComment.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add a Comment" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    //Call API
    [self getCommentsFromAPI];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Register keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    scrollContentHeight = 464.;
    
    if (isFirstTime && self.isOpenKeyboard) {
        [self.txtComment becomeFirstResponder];
        isFirstTime = NO;
    }

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //Register keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.txtComment resignFirstResponder];
}

#pragma mark -
#pragma mark Keyboard Notification

- (void)keyboardWillShow: (NSNotification *)notif
{
    NSDictionary* userInfo = [notif userInfo];
    
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    // resize the scrollview
    CGRect viewFrame = self.scrollContentView.frame;
    viewFrame.size.height = 504. - keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:animationDuration];
    [self.scrollContentView setFrame:viewFrame];
    [UIView commitAnimations];
    
    [self.scrollContentView scrollRectToVisible:CGRectMake(0, 100., 320., 100.) animated:NO];
}
- (void)keyboardWillHide: (NSNotification *)notif
{
    NSDictionary* userInfo = [notif userInfo];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    // resize the scrollview
    CGRect viewFrame = self.scrollContentView.frame;
    viewFrame.size.height = scrollContentHeight;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:animationDuration];
    [self.scrollContentView setFrame:viewFrame];
    [UIView commitAnimations];
    
}


#pragma mark - UI designs
-(void)dismissKeyboard {
    [self.txtComment resignFirstResponder];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [self dismissKeyboard];
    if ([segue.identifier isEqualToString:@"GoToProfile"]) {
        PZProfileViewController *profileVC = [segue destinationViewController];
        
        NSDictionary *dicCommentInfo = [self.arrayComments objectAtIndex:selectedRow];
        [profileVC setStrUsername:[dicCommentInfo objectForKey:@"UserName"]];
    }
}


#pragma mark - User Interaction
- (IBAction)clickOnBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickOnProfileName:(id)sender{
    selectedRow = [(UIButton*)sender tag];
    [self performSegueWithIdentifier:@"GoToProfile" sender:self];
}

-(IBAction)clickOnDone:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickOnSendBtn:(id)sender{
    [self.txtComment resignFirstResponder];
    
    if (self.txtComment.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment is empty!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;

    }
    
    [SVProgressHUD show];
    [PZAPI postNewCommentWithComment:self.txtComment.text imageName:self.strImageName access_token:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id responseObj){
        [SVProgressHUD dismiss];
        if (isResult) {
            NSDictionary *dicNewComment = responseObj;
            [self.arrayComments insertObject:dicNewComment atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            
            [self.tblComments beginUpdates];
            [self.tblComments insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tblComments endUpdates];
            
            self.txtComment.text = @"";
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Comments Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
    
}

#pragma mark - API Call
- (void) getCommentsFromAPI{
    [SVProgressHUD show];
    [PZAPI getMostRecentCommentsWithImageName:self.strImageName andCompletionBlock:^(BOOL isResult, id responseObj) {
        [SVProgressHUD dismiss];
        if (isResult) {
            self.arrayComments = [NSMutableArray arrayWithArray:responseObj];
            [self.tblComments reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Comments Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }];
}

#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayComments count];
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
    static NSString *CellIdentifier = @"CommentCell";
    PZCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[PZCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicCommentInfo = [self.arrayComments objectAtIndex:indexPath.row];
    cell.lblUsername.text = [dicCommentInfo objectForKey:@"Name"];
    if (cell.lblUsername.text.length == 0) {
        cell.lblUsername.text = [dicCommentInfo objectForKey:@"UserName"];
    }
    
    cell.lblTimeStamp.text = [dicCommentInfo objectForKey:@"CreatedString"];
    
    cell.lblComment.text = [dicCommentInfo objectForKey:@"Comment"];
    CGRect rectComment = cell.lblComment.frame;
    rectComment.size.height = [self getLabelHeight:cell.lblComment];
    cell.lblComment.frame = rectComment;
    
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[AppData urlForUserPhoto:[dicCommentInfo objectForKey:@"UserName"]]]];
    
    cell.btnProfile.tag = indexPath.row;
    [cell.btnProfile addTarget:self action:@selector(clickOnProfileName:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnProfileImg.tag = indexPath.row;
    [cell.btnProfileImg addTarget:self action:@selector(clickOnProfileName:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.arrayComments count] > 0) {
        NSDictionary *dicCommentInfo = [self.arrayComments objectAtIndex:indexPath.row];
        UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(47, 22, 266, 15)];
        lblComment.text = [dicCommentInfo objectForKey:@"Comment"];
        [lblComment setFont:[UIFont fontWithName:@"GeezaPro" size:10.f]];
        return [self getLabelHeight:lblComment] + lblComment.frame.origin.y + 6.0f;
    }
    else{
        return 44.;
    }
}

#pragma mark - Calculation of cell

- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, 20000.0f);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}


@end
