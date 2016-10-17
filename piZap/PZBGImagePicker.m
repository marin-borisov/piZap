//
//  PZBGImagePicker.m
//  piZap
//
//  Created by Assure Developer on 6/14/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZBGImagePicker.h"
#import "AppData.h"
#import "PZAPI.h"

#import <SVProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"


@interface PZBGImagePicker ()<UICollectionViewDataSource, UICollectionViewDelegate>{
    NSMutableArray *arrayImgsInfo;
    NSInteger selectedTag;
    
    int nPages;
}

@property (nonatomic, weak) IBOutlet UICollectionView *myBGCollectionView;

@end

@implementation PZBGImagePicker

-(void)viewDidLoad{
    [super viewDidLoad];
    arrayImgsInfo = [NSMutableArray array];
    
    //Add bottom refresh
    self.myBGCollectionView.alwaysBounceVertical = YES;
    [self.myBGCollectionView addInfiniteScrollingWithActionHandler:^{
        [self loadMoreImages];
    }];
    
    [self.myBGCollectionView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    self.myBGCollectionView.showsInfiniteScrolling = NO;
    
    //Initialize the page number
    nPages = 1;
    
    selectedTag = 0;
    [self loadThemeImages];
}

#pragma mark - API Integration
- (void)loadThemeImages{
    
    [SVProgressHUD show];
    
    [PZAPI GetListOfThemesWithAccessToken:[AppData appData].userAccessToken andCompletionBlock:^(BOOL isResult, id resultObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            arrayImgsInfo = [NSMutableArray arrayWithArray:resultObj];
            [self.myBGCollectionView reloadData];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting Themes Image Error" message:resultObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
    
    
}

- (void)loadMoreImages{
    nPages ++;

    [SVProgressHUD show];
    [PZAPI GetListOfPhotosForUserWithUserName:self.strUsername isPublic:[NSNumber numberWithBool:YES] access_token:[AppData appData].userAccessToken page:nPages andCompletionBlock:^(BOOL isResult, id resultObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            if ([resultObj count] > 0) {
                
                [arrayImgsInfo addObjectsFromArray:resultObj];
                [self.myBGCollectionView reloadData];
                
                self.myBGCollectionView.showsInfiniteScrolling = NO;
            }
            else{
                self.myBGCollectionView.showsInfiniteScrolling = NO;
            }
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Getting My PiZap Image Error" message:resultObj delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        
        [self.myBGCollectionView.infiniteScrollingView stopAnimating];
        
    }];
}

- (void)loadMyPizapImages{
    
    nPages = 1;
    [SVProgressHUD show];
    [PZAPI GetListOfPhotosForUserWithUserName:self.strUsername isPublic:[NSNumber numberWithBool:self.isPublic] access_token:[AppData appData].userAccessToken page:nPages andCompletionBlock:^(BOOL isResult, id resultObj) {
        [SVProgressHUD dismiss];
        
        if (isResult) {
            arrayImgsInfo = [NSMutableArray arrayWithArray:resultObj];
            [self.myBGCollectionView reloadData];
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
    return [arrayImgsInfo count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PiZapBGImagePickerCollectionCell";
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                  forIndexPath:indexPath];
    
    UIImageView *imgPhoto = (UIImageView*)[cell.contentView viewWithTag:100];
    imgPhoto.layer.cornerRadius = 4;
    imgPhoto.clipsToBounds = YES;
    
    if (selectedTag == 0) {   //Themes
        NSDictionary *dicInfo = [arrayImgsInfo objectAtIndex:indexPath.row];
        NSString *strImageUrl = [dicInfo objectForKey:@"Thumbnail"];
        strImageUrl = [AppData fixURLForPizap:strImageUrl];
        
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:strImageUrl]];
    }
    else if (selectedTag == 1) {  //Pizap images
        NSDictionary *dicInfo = [arrayImgsInfo objectAtIndex:indexPath.row];
        NSString *strImageUrl = [dicInfo objectForKey:@"s"];
        
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:strImageUrl]];
    }
    

    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate) {
        if (selectedTag == 0) { //Themes
            NSDictionary *dicInfo = [arrayImgsInfo objectAtIndex:indexPath.row];
            NSString *strImageUrl = [dicInfo objectForKey:@"Theme"];
            strImageUrl = [AppData fixURLForPizap:strImageUrl];
            
            int rValue = [[dicInfo objectForKey:@"R"] intValue];
            int gValue = [[dicInfo objectForKey:@"G"] intValue];
            int bValue = [[dicInfo objectForKey:@"B"] intValue];
            
            UIColor *bgColor = [UIColor colorWithRed:rValue / 255. green:gValue / 255. blue:bValue / 255. alpha:1.0f];
            
            [self.delegate imagePicker:self didChooseThemeImage:strImageUrl withBGColor:bgColor];
        }
        else if (selectedTag == 1) {   //PiZap
            NSDictionary *dicInfo = [arrayImgsInfo objectAtIndex:indexPath.row];
            NSString *strImageUrl = [dicInfo objectForKey:@"s"];
            
            [self.delegate imagePicker:self didChoosePiZapImage:strImageUrl];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - User Interaction
- (IBAction)clickOnMenuButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changedOnSegement:(id)sender{
    NSInteger tag = [(UISegmentedControl*)sender selectedSegmentIndex];
    if (tag == selectedTag) {
        return;
    }
    
    selectedTag = tag;
    if (selectedTag == 0) { //Themes
    self.myBGCollectionView.showsInfiniteScrolling = NO;
        [self loadThemeImages];
    }
    else{
        self.myBGCollectionView.showsInfiniteScrolling = YES;
        [self loadMyPizapImages];
    }
}

@end
