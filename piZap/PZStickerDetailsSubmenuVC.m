//
//  PZStickerDetailsSubmenuVC.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZStickerDetailsSubmenuVC.h"
#import "AppData.h"
#import <UIImageView+WebCache.h>
#import "PZEditToolCollectionViewFlowLayout.h"

#import "PZStickerSubmenuCell.h"
#import "PZEditMainVC.h"

@interface PZStickerDetailsSubmenuVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UITableView *tblStickerPages;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property                           int nPages;

@property (nonatomic, strong)       NSMutableArray *arrayPageNums;

@end

@implementation PZStickerDetailsSubmenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    //Get the thumbs number and pages number
    if ([self.dicStickerInfo objectForKey:@"Pages"]) {
        _nPages = (int)[[self.dicStickerInfo objectForKey:@"Pages"] count] + 1;
    }
    else{
        _nPages = 1;
    }
    
    //Setup the array for page nums
    self.arrayPageNums = [NSMutableArray array];
    for (int i = 0 ; i < _nPages; i ++) {
        [self.arrayPageNums addObject:[NSNumber numberWithInt:0]];
    }
    
    //Set the title
    self.lblTitle.text = [NSString stringWithFormat:@"Stickers > %@", [self.dicStickerInfo objectForKey:@"Name"]];
    
    //Set Page Control for pages
    if (_nPages == 1) {
        self.pageControl.hidden = YES;
    }
    else{
        self.pageControl.numberOfPages = _nPages;
        self.pageControl.currentPage = 0;
        self.pageControl.transform = CGAffineTransformMakeRotation(M_PI_2);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - User Interaction
- (IBAction)clickOnBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Thumb Info Manipulation
- (int)thumbCountForPage:(NSInteger)page{
    int nThumbs;
    if (page == 0) {
        nThumbs = [[self.dicStickerInfo objectForKey:@"ItemCount"] intValue];
    }
    else{
        NSArray *pagesInfo = [self.dicStickerInfo objectForKey:@"Pages"];
        nThumbs = [[[pagesInfo objectAtIndex:page - 1] objectForKey:@"ItemCount"] intValue];
        
    }
    
    return nThumbs;
}

#pragma mark - CollectionView DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    int tagCollectionView = (int)[collectionView tag];
    int nThumbs = [self thumbCountForPage:tagCollectionView];
    return (nThumbs + 9) / 10 * 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StickerThumbCell";
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                  forIndexPath:indexPath];
    
    int tagCollectionView = (int)[collectionView tag];

    int nThumbs = [self thumbCountForPage:tagCollectionView];
    if (indexPath.row < nThumbs) {
        
        //Get the relevant thumbs info
        NSDictionary *dicThumbPage;
        if (tagCollectionView == 0) {
            dicThumbPage = self.dicStickerInfo;
        }
        else{
            NSArray *pagesInfo = [self.dicStickerInfo objectForKey:@"Pages"];
            dicThumbPage = [pagesInfo objectAtIndex:tagCollectionView - 1];
        }
        
        //get the thumb image names
        NSString* thumbnailExt = @"png";
        NSString* thumbnailPrefix = @"thumb";
        int thumbnailDigits = 1;
        
        NSString* pathExt = @"png";
        NSString* pathPrefix = @"img";
        int pathDigits = 1;
        
        if([dicThumbPage objectForKey:@"ThumbnailExt"]) thumbnailExt = [dicThumbPage objectForKey:@"ThumbnailExt"];
        if([dicThumbPage objectForKey:@"ThumbnailPrefix"]) thumbnailPrefix = [dicThumbPage objectForKey:@"ThumbnailPrefix"];
        if([dicThumbPage objectForKey:@"ThumbnailDigits"]) thumbnailDigits = [[dicThumbPage objectForKey:@"ThumbnailDigits"] intValue];
        
        if([dicThumbPage objectForKey:@"PathExt"]) pathExt = [dicThumbPage objectForKey:@"PathExt"];
        if([dicThumbPage objectForKey:@"PathPrefix"]) pathPrefix = [dicThumbPage objectForKey:@"PathPrefix"];
        if([dicThumbPage objectForKey:@"PathDigits"]) pathDigits = [[dicThumbPage objectForKey:@"PathDigits"] intValue];
        
        NSString *strStickerThumbBasePath = [self.strBasePath stringByAppendingPathComponent:[dicThumbPage objectForKey:@"Path"]];
        
        
        NSString *strDigitSymbol = [NSString stringWithFormat:@"%%0%dd", thumbnailDigits];
        NSString *strThumbImagePath = [strStickerThumbBasePath stringByAppendingPathComponent:thumbnailPrefix];
        strThumbImagePath = [strThumbImagePath stringByAppendingString:[NSString stringWithFormat:strDigitSymbol, (int)indexPath.row + 1]];
        strThumbImagePath = [strThumbImagePath stringByAppendingString:@"."];
        strThumbImagePath = [strThumbImagePath stringByAppendingString:thumbnailExt];
        
        //Item Photo
        UIImageView *imgPhoto = (UIImageView*)[cell.contentView viewWithTag:100];
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:strThumbImagePath]];
        
        //Cell conner rounding
        UIView *viewBG = (UIView*)[cell.contentView viewWithTag:101];
        viewBG.layer.cornerRadius = 5;
        viewBG.clipsToBounds = YES;
        cell.layer.cornerRadius = 5;
        cell.clipsToBounds = YES;
        
        
        
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
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    int tagCollectionView = (int)[collectionView tag];
    int nThumbs = [self thumbCountForPage:tagCollectionView];
    if (indexPath.row < nThumbs) {
        PZEditMainVC *mainVC = (PZEditMainVC*)[self.navigationController parentViewController];
        
        //Get the relevant thumbs info
        NSDictionary *dicThumbPage;
        if (tagCollectionView == 0) {
            dicThumbPage = self.dicStickerInfo;
        }
        else{
            NSArray *pagesInfo = [self.dicStickerInfo objectForKey:@"Pages"];
            dicThumbPage = [pagesInfo objectAtIndex:tagCollectionView - 1];
        }
        
        //get the thumb image names
        NSString* thumbnailExt = @"png";
        NSString* thumbnailPrefix = @"img";
        int thumbnailDigits = 1;
        
        NSString* pathExt = @"png";
        NSString* pathPrefix = @"img";
        int pathDigits = 1;
        
        if([dicThumbPage objectForKey:@"ThumbnailExt"]) thumbnailExt = [dicThumbPage objectForKey:@"ThumbnailExt"];
        if([dicThumbPage objectForKey:@"ThumbnailPrefix"]) thumbnailPrefix = [dicThumbPage objectForKey:@"ThumbnailPrefix"];
        if([dicThumbPage objectForKey:@"ThumbnailDigits"]) thumbnailDigits = [[dicThumbPage objectForKey:@"ThumbnailDigits"] intValue];
        
        if([dicThumbPage objectForKey:@"PathExt"]) pathExt = [dicThumbPage objectForKey:@"PathExt"];
        if([dicThumbPage objectForKey:@"PathPrefix"]) pathPrefix = [dicThumbPage objectForKey:@"PathPrefix"];
        if([dicThumbPage objectForKey:@"PathDigits"]) pathDigits = [[dicThumbPage objectForKey:@"PathDigits"] intValue];
        
        NSString *strStickerThumbBasePath = [self.strBasePath stringByAppendingPathComponent:[dicThumbPage objectForKey:@"Path"]];
        
        
        NSString *strDigitSymbol = [NSString stringWithFormat:@"%%0%dd", thumbnailDigits];
        NSString *strThumbImagePath = [strStickerThumbBasePath stringByAppendingPathComponent:thumbnailPrefix];
        strThumbImagePath = [strThumbImagePath stringByAppendingString:[NSString stringWithFormat:strDigitSymbol, (int)indexPath.row + 1]];
        strThumbImagePath = [strThumbImagePath stringByAppendingString:@"."];
        strThumbImagePath = [strThumbImagePath stringByAppendingString:thumbnailExt];
        
        [mainVC stickerSelected:strThumbImagePath];
    }
    
}

#pragma mark - UITableView Datasource



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _nPages;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StickerPageTableCell";
    PZStickerSubmenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[PZStickerSubmenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.collectionView.tag = indexPath.row;
    [cell.collectionView reloadData];
    
    cell.pageControl.tag = indexPath.row;
    cell.pageControl.numberOfPages = ([self thumbCountForPage:indexPath.row] + 9) / 10;
    NSInteger currentPage = [[self.arrayPageNums objectAtIndex:indexPath.row] integerValue];
    cell.pageControl.currentPage = currentPage;
    
    //set scrolling for collectionview
    CGFloat pageWidth = cell.collectionView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * currentPage, 0);
    [cell.collectionView setContentOffset:scrollTo animated:NO];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 161.0f;
}


#pragma mark - PageControl Delegate
- (IBAction)pageControlChanged:(id)sender{
    int nTag = (int)[sender tag];
    PZStickerSubmenuCell *cell = (PZStickerSubmenuCell*)[self.tblStickerPages cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nTag inSection:0]];
    
    CGFloat pageWidth = cell.collectionView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * cell.pageControl.currentPage, 0);
    [cell.collectionView setContentOffset:scrollTo animated:YES];
    
    [self.arrayPageNums replaceObjectAtIndex:nTag withObject:[NSNumber numberWithInteger:cell.pageControl.currentPage]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
   
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = (scrollView.contentOffset.x + pageWidth / 2) / pageWidth;//floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

        int nTag = (int)[scrollView tag];
        PZStickerSubmenuCell *cell = (PZStickerSubmenuCell*)[self.tblStickerPages cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nTag inSection:0]];
        UIPageControl *pageControl = cell.pageControl;
        pageControl.currentPage = page;
        
        [self.arrayPageNums replaceObjectAtIndex:nTag withObject:[NSNumber numberWithInt:page]];
    }
    else if ([scrollView isKindOfClass:[UITableView class]]){
        CGFloat pageHeight = scrollView.frame.size.height;
        int page = (scrollView.contentOffset.y + pageHeight / 2) / pageHeight;//floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

@end