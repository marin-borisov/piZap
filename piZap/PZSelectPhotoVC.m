//
//  PZSelectPhotoVC.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZSelectPhotoVC.h"
#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>
#import <AddressBook/AddressBook.h>
#import <UzysAssetsPickerController.h>

#import "PZUserShortInfo.h"
#import "PZPeopleToFollowVC.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface PZSelectPhotoVC ()<UITableViewDataSource, UITableViewDelegate, UzysAssetsPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    NSArray *arrayTitles;
    NSArray *arrayImageNames;
    
    NSMutableArray *arrayToSend;
}

@property (nonatomic, weak) IBOutlet UITableView *tblActions;

@end


@implementation PZSelectPhotoVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayTitles = @[@"Photos", @"Facebook", @"Backgrounds", @"Camera"];
    arrayImageNames = @[@"photos_icon", @"icon_facebook_logo", @"icon_home_backgrounds", @"camera_icon"];
    
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
        
    }
}



#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrayTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectPhotoCell";
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
    
    if (indexPath.row == 0) {  //Photos
        if (self.multiSelection) {
            UzysAppearanceConfig *appearanceConfig = [[UzysAppearanceConfig alloc] init];
            appearanceConfig.finishSelectionButtonColor = [UIColor blueColor];
            appearanceConfig.cellSpacing = 1.0f;
            appearanceConfig.assetsCountInALine = 3;
            appearanceConfig.cameraImageName = @"";
            appearanceConfig.assetsGroupSelectedImageName = @"";
            [UzysAssetsPickerController setUpAppearanceConfig:appearanceConfig];
            UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
            
            picker.delegate = self;
            picker.maximumNumberOfSelectionVideo = 0;
            picker.maximumNumberOfSelectionPhoto = self.multiSelectionCount;
            
            [self presentViewController:picker animated:YES completion:^{
                
            }];
            
        }
        else{
        
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PiZap" message:@"Camera roll is not available right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
            UIImagePickerController *imagerPicker = [[UIImagePickerController alloc] init];
            imagerPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagerPicker.delegate = self;
            [self.navigationController presentViewController:imagerPicker animated:YES completion:nil];
        }

    }
    else if (indexPath.row == 1) {  //Facebook
    
    }
    else if (indexPath.row == 2) {  //Backgrounds
        
    }
    else if (indexPath.row == 3) {  //Camera
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PiZap" message:@"Camera is not available right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
        UIImagePickerController *imagerPicker = [[UIImagePickerController alloc] init];
        imagerPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagerPicker.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
        imagerPicker.delegate = self;
        [self.navigationController presentViewController:imagerPicker animated:YES completion:nil];
    }
}

#pragma mark - Image Picker Controller Delegate Methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *imageData = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectPhotoController:didChooseImage:)]) {
                [self.delegate selectPhotoController:self didChooseImage:imageData];
            }
        }];
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ELCImagePickerController Delegate
#pragma mark - UzysAssetsPickerControllerDelegate methods
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSMutableArray *imageArray = [NSMutableArray array];
    
    [SVProgressHUD show];
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        int nCount = assets.count;
        __weak typeof(self) weakSelf = self;
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                               scale:representation.defaultRepresentation.scale
                                         orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
            
            [imageArray addObject:img];
            if (imageArray.count >= nCount) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(selectPhotoController:didChooseMultiImages:)]) {
                    [weakSelf.delegate selectPhotoController:weakSelf didChooseMultiImages:imageArray];
                }
            }
            
        }];
    }];
}


@end