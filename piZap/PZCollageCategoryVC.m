//
//  PZCollageCategoryVC.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright © 2015 Digital Palette LLC. All rights reserved.
//

#import "PZCollageCategoryVC.h"
#import "AppData.h"
#import "PZAPI.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>
#import "PZCollageListVC.h"
#import "PZCollageListRectangleVC.h"

@interface PZCollageCategoryVC ()<UITableViewDataSource, UITableViewDelegate>{
    NSArray *arrayCollages;
    NSString *strCollagePath;
    
    NSInteger selectedRow;
}

@property (nonatomic, weak) IBOutlet UITableView *tblCollageCategories;

@end

@implementation PZCollageCategoryVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadCategoriesFromAPI];
    self.tblCollageCategories.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API Call
- (void)loadCategoriesFromAPI{
    //Set some information from assets JSON
    NSDictionary *dicStickerInfo = [[AppData appData].assetsJsonObj objectForKey:@"Collages"];
    NSString *strRootPath = [[AppData appData].assetsJsonObj objectForKey:@"CDNPath"];
    strCollagePath = [strRootPath stringByAppendingPathComponent:dicStickerInfo[@"Path"]];
    arrayCollages = [dicStickerInfo objectForKey:@"items"];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"GoToCollagesList"]) {
        PZCollageListVC *collageListVC = (PZCollageListVC*)[segue destinationViewController];
        collageListVC.dicCollageCat = [arrayCollages objectAtIndex:selectedRow];
        collageListVC.strRootPath = strCollagePath;
    }
    else if ([segue.identifier isEqualToString:@"GoToCollageListWithSubMenu"]) {
        PZCollageListRectangleVC *collageListVC = (PZCollageListRectangleVC*)[segue destinationViewController];
        collageListVC.dicCollageCat = [arrayCollages objectAtIndex:selectedRow];
        collageListVC.strRootPath = strCollagePath;
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
    return [arrayCollages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CollageCategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicInfo = [arrayCollages objectAtIndex:indexPath.row];
    UILabel *lblTitle = (UILabel*)[cell viewWithTag:101];
    lblTitle.text = [dicInfo objectForKey:@"Name"];
    
    UIImageView *imgView = (UIImageView*)[cell viewWithTag:100];
    NSString *strThumbCatImagePath = [strCollagePath stringByAppendingPathComponent:[dicInfo objectForKey:@"Thumb"]];
    [imgView sd_setImageWithURL:[NSURL URLWithString:strThumbCatImagePath]];
    imgView.layer.cornerRadius = 8.f;
    imgView.clipsToBounds = YES;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedRow = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dicInfo = [arrayCollages objectAtIndex:indexPath.row];
    if ([dicInfo objectForKey:@"Pages"]) {
        [self performSegueWithIdentifier:@"GoToCollageListWithSubMenu" sender:self];        
    }
    else{
        [self performSegueWithIdentifier:@"GoToCollagesList" sender:self];
    }
    

}

@end