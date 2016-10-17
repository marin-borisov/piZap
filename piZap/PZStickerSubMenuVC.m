//
//  PZStickerSubMenuVC.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZStickerSubMenuVC.h"
#import "AppData.h"
#import <UIImageView+WebCache.h>
#import "PZStickerDetailsSubmenuVC.h"

@interface PZStickerSubMenuVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic, weak) IBOutlet UICollectionView *stickerCollectionView;

@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *arrayStickerInfos;

@property (nonatomic, strong) NSString *strBasePath;

@end

@implementation PZStickerSubMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //Initialize the array info
    self.arrayStickerInfos = [NSMutableArray array];
    
    //Set some information from assets JSON
    NSDictionary *dicStickerInfo = [[AppData appData].assetsJsonObj objectForKey:@"Stickers"];
    self.strBasePath = [[AppData appData].assetsJsonObj objectForKey:@"CDNPath"];
    self.strBasePath = [self.strBasePath stringByAppendingPathComponent:dicStickerInfo[@"Path"]];
    self.arrayStickerInfos = [dicStickerInfo objectForKey:@"items"];

    //Setup CollectionView
    [self.stickerCollectionView setPagingEnabled:YES];
    
    //Setup Page Control
    self.pageControl.numberOfPages = ([self.arrayStickerInfos count] + 9) / 10;
    self.pageControl. currentPage = 0;
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
    
    if ([segue.identifier isEqualToString:@"GoToStickerThumb"]) {
        PZStickerDetailsSubmenuVC *detailStickerVC = (PZStickerDetailsSubmenuVC*)segue.destinationViewController;
        NSDictionary *dicInfo = [self.arrayStickerInfos objectAtIndex:selectedIndexPath.row];
        [detailStickerVC setDicStickerInfo:dicInfo];
        [detailStickerVC setStrBasePath:self.strBasePath];
    }
}


#pragma mark - User Interaction
- (IBAction)clickOnBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CollectionView DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return self.pageControl.numberOfPages * 10;//[self.arrayStickerInfos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StickerCollectionCell";
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                  forIndexPath:indexPath];
    
    if (indexPath.row < [self.arrayStickerInfos count]) {
        NSDictionary *dicItemInfo = [self.arrayStickerInfos objectAtIndex:indexPath.row];
        
        //Item Photo
        UIImageView *imgPhoto = (UIImageView*)[cell.contentView viewWithTag:100];
        NSString *strThumbImagePath = [self.strBasePath stringByAppendingPathComponent:dicItemInfo[@"Thumb"]];
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:strThumbImagePath]];
        
        //Item Label
        UILabel *lblThumb = (UILabel*)[cell.contentView viewWithTag:101];
        lblThumb.text = [dicItemInfo objectForKey:@"Name"];
        
        //Cell conner rounding
        UIView *viewBG = (UIView*)[cell.contentView viewWithTag:102];
        viewBG.layer.cornerRadius = 5;
        viewBG.clipsToBounds = YES;
        cell.layer.cornerRadius = 5;
        cell.clipsToBounds = YES;

        //Adjust the premium icon and background border
        UIImageView *imgPremium = (UIImageView*)[cell.contentView viewWithTag:103];
        if ([dicItemInfo objectForKey:@"UpgradeCost"]) {
            viewBG.layer.borderColor = [UIColor colorWithRed:253./255. green:208./255. blue:43./255. alpha:1.0].CGColor;
            viewBG.layer.borderWidth = 2.0f;
            
            imgPremium.hidden = NO;
        }
        else{
            viewBG.layer.borderColor = [UIColor clearColor].CGColor;
            
            imgPremium.hidden = YES;
        }
        
        //Update the visibility
        cell.contentView.hidden = NO;
    }
    else{
        cell.contentView.hidden = YES;
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"GoToStickerThumb" sender:self];
}

#pragma mark - PageControl Delegate
- (IBAction)pageControlChanged:(id)sender{
    CGFloat pageWidth = self.stickerCollectionView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * self.pageControl.currentPage, 0);
    [self.stickerCollectionView setContentOffset:scrollTo animated:YES];
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.stickerCollectionView.frame.size.width;
    int page = floor((self.stickerCollectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1; //self.stickerCollectionView.contentOffset.x / pageWidth;
    
    if (page >= self.pageControl.numberOfPages - 1)
        self.pageControl.currentPage = page - 1;
    self.pageControl.currentPage = page;
}

@end
