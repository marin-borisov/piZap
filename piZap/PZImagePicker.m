//
//  PZImagePicker.m
//  piZap
//
//  Created by Assure Developer on 6/20/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZImagePicker.h"
#import "AppData.h"
#import "PZAPI.h"

#import <SVProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"

@interface PZImagePicker ()<UICollectionViewDataSource, UICollectionViewDelegate>{
    NSMutableArray *arrayMyPizapImgInfos;
    int nPages;
}

@property (nonatomic, weak) IBOutlet UICollectionView *myPizapCollectionView;

@end

@implementation PZImagePicker

-(void)viewDidLoad{
    [super viewDidLoad];
    arrayMyPizapImgInfos = [NSMutableArray array];
    
    //Add bottom refresh
    self.myPizapCollectionView.alwaysBounceVertical = YES;
    [self.myPizapCollectionView addInfiniteScrollingWithActionHandler:^{
        [self loadMoreImages];
    }];
    
    [self.myPizapCollectionView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    self.myPizapCollectionView.showsInfiniteScrolling = YES;
    
    //Initialize the page number
    nPages = 1;
    
    [self loadMyPizapImages];
}

- (void)loadMoreImages{
    nPages ++;
    [SVProgressHUD show];
    [PZAPI GetListOfPhotosForUserWithUserName:self.strUsername isPublic:[NSNumber numberWithBool:YES] access_token:[AppData appData].userAccessToken page:nPages andCompletionBlock:^(BOOL isResult, id resultObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            if ([resultObj count] > 0) {
                
                [arrayMyPizapImgInfos addObjectsFromArray:resultObj];
                [self.myPizapCollectionView reloadData];
                
                self.myPizapCollectionView.showsInfiniteScrolling = YES;
            }
            else{
                self.myPizapCollectionView.showsInfiniteScrolling = NO;
            }
            
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My PiZap Image Error" message:resultObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
        [self.myPizapCollectionView.infiniteScrollingView stopAnimating];
    }];
}

- (void)loadMyPizapImages{
    
    nPages = 1;
    [SVProgressHUD show];
    [PZAPI GetListOfPhotosForUserWithUserName:self.strUsername isPublic:[NSNumber numberWithBool:self.isPublic] access_token:[AppData appData].userAccessToken page:nPages andCompletionBlock:^(BOOL isResult, id resultObj) {
       [SVProgressHUD dismiss];
        
        if (isResult) {
            arrayMyPizapImgInfos = [NSMutableArray arrayWithArray:resultObj];
            [self.myPizapCollectionView reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My PiZap Image Error" message:resultObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
    
    
}

#pragma mark - UICollectionView Datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [arrayMyPizapImgInfos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PiZapImagePickerCollectionCell";
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                  forIndexPath:indexPath];
    
    
    
    NSDictionary *dicInfo = [arrayMyPizapImgInfos objectAtIndex:indexPath.row];
    NSString *strImageUrl = [dicInfo objectForKey:@"s"];
    UIImageView *imgPhoto = (UIImageView*)[cell.contentView viewWithTag:100];
    [imgPhoto sd_setImageWithURL:[NSURL URLWithString:strImageUrl]];
    
    imgPhoto.layer.cornerRadius = 4;
    imgPhoto.clipsToBounds = YES;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate) {
        NSDictionary *dicInfo = [arrayMyPizapImgInfos objectAtIndex:indexPath.row];
        NSString *strImageUrl = [dicInfo objectForKey:@"l"];

        [self.delegate imagePicker:self didChooseImage:strImageUrl];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - User Interaction
- (IBAction)clickOnMenuButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
