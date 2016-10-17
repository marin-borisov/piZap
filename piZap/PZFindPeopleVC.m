//
//  PZFindPeopleVC.m
//  piZap
//
//  Created by Assure Developer on 8/1/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZFindPeopleVC.h"
#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>
#import <AddressBook/AddressBook.h>

#import "PZUserShortInfo.h"
#import "PZPeopleToFollowVC.h"

@interface PZFindPeopleVC ()<UITableViewDataSource, UITableViewDelegate>{
    NSArray *arrayTitles;
    NSArray *arrayImageNames;
    
    NSMutableArray *arrayToSend;
}

@property (nonatomic, weak) IBOutlet UITableView *tblActions;

@end

@implementation PZFindPeopleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayTitles = @[@"Facebook Friends", @"Top Artists", @"Contacts", @"Search by Username"];
    arrayImageNames = @[@"icon_facebook_logo", @"top_artists_icon", @"contacts_icon", @"search_icon_find_people"];
    
    self.tblActions.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"GoToUsersListToFollow"]) {
        PZPeopleToFollowVC *peopleVC = [segue destinationViewController];
        [peopleVC setArrayUsers:arrayToSend];
    }
}



#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FindPeopleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel *lblTitle = (UILabel*)[cell viewWithTag:101];
    lblTitle.text = [arrayTitles objectAtIndex:indexPath.row];
    
    UIImageView *imgView = (UIImageView*)[cell viewWithTag:100];
    [imgView setImage:[UIImage imageNamed:[arrayImageNames objectAtIndex:indexPath.row]]];
    imgView.layer.cornerRadius = 8.f;
    imgView.clipsToBounds = YES;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {  //Facebook Friends
        [SVProgressHUD show];
        [PZAPI getUsersToFollowWithAccessToken:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isSuccess, id responseObj) {
            [SVProgressHUD dismiss];
            if (isSuccess) {
                NSArray *arrayUsers = [NSArray arrayWithArray:responseObj];
                
                arrayToSend = [NSMutableArray array];
                for (NSDictionary *userInfo in arrayUsers) {
                    PZUserShortInfo *user = [[PZUserShortInfo alloc] init];
                    user.strName = [userInfo objectForKey:@"name"];
                    user.strUsername = [userInfo objectForKey:@"fid"];
                    user.strProfileImageURL = [userInfo objectForKey:@"profile_image"];
                    user.isFollowing = [[userInfo objectForKey:@"isFollowing"] boolValue];
                    
                    [arrayToSend addObject:user];
                }
                
                [self performSegueWithIdentifier:@"GoToUsersListToFollow" sender:self];
                
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Facebook Friends Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
    else if (indexPath.row == 1) {  //Top Artists
        [SVProgressHUD show];
        [PZAPI getListOfTopArtistsWithAccessToken:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isSuccess, id responseObj) {
            [SVProgressHUD dismiss];
            if (isSuccess) {
                NSArray *arrayUsers = [NSArray arrayWithArray:responseObj];
                
                arrayToSend = [NSMutableArray array];
                for (NSDictionary *userInfo in arrayUsers) {
                    PZUserShortInfo *user = [[PZUserShortInfo alloc] init];
                    user.strName = [userInfo objectForKey:@"Name"];
                    user.strUsername = [userInfo objectForKey:@"UserName"];
                    user.strProfileImageURL = [userInfo objectForKey:@"ProfileImage"];
                    user.isFollowing = [[userInfo objectForKey:@"isFollowing"] boolValue];
                    
                    [arrayToSend addObject:user];
                }
                
                [self performSegueWithIdentifier:@"GoToUsersListToFollow" sender:self];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Top Artists Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
    else if (indexPath.row == 2) {  //Contacts
        
        __block BOOL userDidGrantAddressBookAccess;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        CFErrorRef addressBookError = NULL;
        
        if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized )
        {
            addressBook = ABAddressBookCreateWithOptions(NULL, &addressBookError);
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
                userDidGrantAddressBookAccess = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else
        {
            if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
                ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted )
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please go to the iPhone Setting and allow this app to use the contacts." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
        }
        
        if (!userDidGrantAddressBookAccess) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please go to the iPhone Setting and allow this app to use the contacts." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return;
        }

        //Get the contacts from the address book
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(people)];
        for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                NSString* email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                [allEmails addObject:email];
            }
            CFRelease(emails);
        }
        CFRelease(addressBook);
        CFRelease(people);
        
        //Define the format with contacts emails.
        NSMutableArray *jsonArray = [NSMutableArray array];
        for (NSString *email in allEmails) {
            [jsonArray addObject:[NSDictionary dictionaryWithObject:email forKey:@"e"]];
        }
        NSDictionary *jsonDic = [NSDictionary dictionaryWithObject:jsonArray forKey:@"data"];
        
        NSString *strJSON = @"";
        NSData *jsonData;
        //Make the json string
        if ([NSJSONSerialization isValidJSONObject:jsonDic]) {
            jsonData = [ NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil ];
            strJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        [SVProgressHUD show];
        [PZAPI getMatchContactWithAccessToken:[AppData appData].userAccessToken body:jsonData andCompletionBlock:^(BOOL isSuccess, id responseObj) {
            [SVProgressHUD dismiss];
            if (isSuccess) {
                NSArray *arrayUsers = [NSArray arrayWithArray:responseObj];
                
                arrayToSend = [NSMutableArray array];
                for (NSDictionary *userInfo in arrayUsers) {
                    PZUserShortInfo *user = [[PZUserShortInfo alloc] init];
                    user.strName = [userInfo objectForKey:@"name"];
                    user.strUsername = [userInfo objectForKey:@"UserName"];
                    user.strProfileImageURL = [userInfo objectForKey:@"profile_image"];
                    user.isFollowing = [[userInfo objectForKey:@"isFollowing"] boolValue];
                    
                    [arrayToSend addObject:user];
                }
                
                [self performSegueWithIdentifier:@"GoToUsersListToFollow" sender:self];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Facebook Friends Error" message:responseObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
    else if (indexPath.row == 3) {  //Search users
        [self performSegueWithIdentifier:@"GoToSearchUser" sender:self];
    }
}


@end
