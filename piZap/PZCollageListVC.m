//
//  PZCollageListVC.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import "PZCollageListVC.h"
#import "AppData.h"
#import <UIImageView+WebCache.h>
#import "PZEditMainVC.h"

@interface PZCollageListVC (){
    NSArray *arrayCollages;
    
    NSInteger selectedRow;
}



@end

@implementation PZCollageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    if ([segue.identifier isEqualToString:@"GoToMainEditVC"]) {
        PZEditMainVC *collageListVC = (PZEditMainVC*)segue.destinationViewController ;

        //Get SVG and SVG background image
        NSDictionary *dicThumbPage = self.dicCollageCat;
        //get the thumb image names
        
        NSString* templateExt = @"svg";
        NSString* templatePrefix = @"collage_";
        int templateDigits = 3;
        
        if([dicThumbPage objectForKey:@"TemplateExt"]) templateExt = [dicThumbPage objectForKey:@"TemplateExt"];
        if([dicThumbPage objectForKey:@"TemplatePrefix"]) templatePrefix = [dicThumbPage objectForKey:@"TemplatePrefix"];
        if([dicThumbPage objectForKey:@"TemplateDigits"]) templateDigits = [[dicThumbPage objectForKey:@"TemplateDigits"] intValue];
        
        NSString *strStickerThumbBasePath = [self.strRootPath stringByAppendingPathComponent:[dicThumbPage objectForKey:@"Path"]];
        
        
        NSString *strDigitSymbol = [NSString stringWithFormat:@"%%0%dd", templateDigits];
        NSString *strSVGImagePath = [strStickerThumbBasePath stringByAppendingPathComponent:templatePrefix];
        strSVGImagePath = [strSVGImagePath stringByAppendingString:[NSString stringWithFormat:strDigitSymbol, (int)selectedRow + 1]];
        strSVGImagePath = [strSVGImagePath stringByAppendingString:@"."];
        
        NSString *strBackgroundImagePath = [strSVGImagePath stringByAppendingString:@"png"];
        strSVGImagePath = [strSVGImagePath stringByAppendingString:templateExt];
        
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:strSVGImagePath forKey:@"SVG_PATH"];
        
        NSLog(@"svg path : %@", strSVGImagePath);
        if([[dicThumbPage objectForKey:@"HasBackground"] boolValue]){
            [dicInfo setObject:strBackgroundImagePath forKey:@"SVG_BACKGROUND_PATH"];
            NSLog(@"svg background : %@", strBackgroundImagePath);
        }
        
        //Check if Edit Collage is possible
        NSString *strCatName = [self.dicCollageCat objectForKey:@"Name"];
        if ([strCatName isEqualToString:@"Circles"]
            || [strCatName isEqualToString:@"Hearts"]
            || [strCatName isEqualToString:@"Shapes"]
            || [strCatName isEqualToString:@"Facebook Timeline Cover"])
        {
            [dicInfo setObject:[NSNumber numberWithBool:YES] forKey:@"SVG_EDIT_ENABLE"];
        }
        else{
            [dicInfo setObject:[NSNumber numberWithBool:NO] forKey:@"SVG_EDIT_ENABLE"];
        }
        
        //Check if Layout Change is possible
        if ([strCatName isEqualToString:@"Facebook Timeline Cover"]){
            [dicInfo setObject:[NSNumber numberWithBool:YES] forKey:@"SVG_EDIT_LAYOUT"];
        }
        else{
            [dicInfo setObject:[NSNumber numberWithBool:NO] forKey:@"SVG_EDIT_LAYOUT"];
        }
        
        //Set info
        [collageListVC setDicCollageInfo:dicInfo];
    }
}


#pragma mark -

#pragma mark - User Interaction
- (IBAction)clickOnMenuBtn:(id)sender{
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
    return [[self.dicCollageCat objectForKey:@"ItemCount"] intValue];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CollageCollectionCell";
    UICollectionViewCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                  forIndexPath:indexPath];
    

    NSDictionary *dicThumbPage = self.dicCollageCat;
    
    //get the thumb image names
    NSString* thumbnailExt = @"png";
    NSString* thumbnailPrefix = @"thumbnail_";
    int thumbnailDigits = 3;
    
    NSString* pathExt = @"png";
    NSString* pathPrefix = @"img";
    int pathDigits = 1;
    
    if([dicThumbPage objectForKey:@"ThumbnailExt"]) thumbnailExt = [dicThumbPage objectForKey:@"ThumbnailExt"];
    if([dicThumbPage objectForKey:@"ThumbnailPrefix"]) thumbnailPrefix = [dicThumbPage objectForKey:@"ThumbnailPrefix"];
    if([dicThumbPage objectForKey:@"ThumbnailDigits"]) thumbnailDigits = [[dicThumbPage objectForKey:@"ThumbnailDigits"] intValue];
    
    if([dicThumbPage objectForKey:@"PathExt"]) pathExt = [dicThumbPage objectForKey:@"PathExt"];
    if([dicThumbPage objectForKey:@"PathPrefix"]) pathPrefix = [dicThumbPage objectForKey:@"PathPrefix"];
    if([dicThumbPage objectForKey:@"PathDigits"]) pathDigits = [[dicThumbPage objectForKey:@"PathDigits"] intValue];
    
    NSString *strStickerThumbBasePath = [self.strRootPath stringByAppendingPathComponent:[dicThumbPage objectForKey:@"Path"]];
    
    
    NSString *strDigitSymbol = [NSString stringWithFormat:@"%%0%dd", thumbnailDigits];
    NSString *strThumbImagePath = [strStickerThumbBasePath stringByAppendingPathComponent:thumbnailPrefix];
    strThumbImagePath = [strThumbImagePath stringByAppendingString:[NSString stringWithFormat:strDigitSymbol, (int)indexPath.row + 1]];
    strThumbImagePath = [strThumbImagePath stringByAppendingString:@"."];
    strThumbImagePath = [strThumbImagePath stringByAppendingString:thumbnailExt];
    
    //Item Photo
    UIImageView *imgPhoto = (UIImageView*)[cell.contentView viewWithTag:100];
    [imgPhoto sd_setImageWithURL:[NSURL URLWithString:strThumbImagePath]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"GoToMainEditVC" sender:self];
}

@end
