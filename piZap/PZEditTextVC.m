//
//  PZEditTextVC.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZEditTextVC.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PZEditMainVC.h"

#import "AppData.h"
#import <NKOColorPickerView.h>


@interface PZEditTextVC () <UITableViewDataSource, UITableViewDelegate>{
    NKOColorPickerView *colorTextPickerView;
    NKOColorPickerView *colorGlowPickerView;
}

@property (nonatomic, weak) IBOutlet UIView *viewTextColor;
@property (nonatomic, weak) IBOutlet UIView *viewGlowColor;
@property (nonatomic, weak) IBOutlet UISwitch *glowSwitch;

@property (nonatomic, weak) IBOutlet UILabel *lblFont;
@property (nonatomic, weak) IBOutlet UITableView *fontTbl;

@property (nonatomic, weak) IBOutlet UILabel *lblSize;
@property (nonatomic, weak) IBOutlet UISlider *sizeSlider;

@end

@implementation PZEditTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //Fill the existing info
    self.lblFont.text = self.textObj.labelFont.fontName;
    
    float fontSize = self.textObj.labelFont.pointSize;//[[AppData appData] getActualFontSizeForLabel:self.textObj.lblText];
    self.lblSize.text = [NSString stringWithFormat:@"%d", (int)fontSize];
    self.sizeSlider.value = fontSize;
    
    self.viewTextColor.backgroundColor = self.textObj.textColor;
    self.viewGlowColor.backgroundColor = self.textObj.growColor;
    
    if (self.textObj.growColor == [UIColor clearColor]) {
        self.glowSwitch.on = NO;
    }
    else{
        self.glowSwitch.on = YES;
    }

    
    //Customize the controls
    self.fontTbl.hidden = YES;
    self.fontTbl.layer.cornerRadius = 10.f;
    self.fontTbl.layer.masksToBounds = YES;
    
    [self setupColorPickers];
    [self setupSizeSlider];
    
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

#pragma mark - UI 

- (void)setupColorPickers{
    self.viewGlowColor.layer.cornerRadius = 3.f;
    [self.viewGlowColor setClipsToBounds:YES];
    
    self.viewTextColor.layer.cornerRadius = 3.f;
    [self.viewTextColor setClipsToBounds:YES];
    
    //Setup Color Picker fot Text color
    NKOColorPickerDidChangeColorBlock colorTextDidChangeBlock = ^(UIColor *color){
        [self.viewTextColor setBackgroundColor:color];
        [self.textObj setLabelTextColor:color];
        
    };
    
    colorTextPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(5, 0, 170, 190) color:self.viewTextColor.backgroundColor andDidChangeColorBlock:colorTextDidChangeBlock];
    [colorTextPickerView setColor:self.viewTextColor.backgroundColor];
    
    //Setup Color Picker fot Text glow color
    NKOColorPickerDidChangeColorBlock colorGlowDidChangeBlock = ^(UIColor *color){
        [self.viewGlowColor setBackgroundColor:color];
        [self.textObj setTextGrowEffect:color];
    };
    
    colorGlowPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(82, 0, 170, 190) color:self.viewGlowColor.backgroundColor andDidChangeColorBlock:colorGlowDidChangeBlock];
    [colorGlowPickerView setColor:self.viewGlowColor.backgroundColor];
}

- (void)setupSizeSlider{
    [self.sizeSlider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [self.sizeSlider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    
    [self.sizeSlider setThumbImage:[UIImage imageNamed:@"thumb_size_slider"] forState:UIControlStateNormal];
}

- (void)removeColorPicker{
    if (colorTextPickerView.superview != nil) {
        [colorTextPickerView removeFromSuperview];
    }
    
    if (colorGlowPickerView.superview != nil) {
        [colorGlowPickerView removeFromSuperview];
    }
}

- (void)removeFontSelector{
    self.fontTbl.hidden = YES;
}

#pragma mark - User Interaction

- (IBAction)changeSizeSlider:(id)sender{
    [self removeColorPicker];
    [self removeFontSelector];
    
    float fontSize = self.sizeSlider.value;
    self.lblSize.text = [NSString stringWithFormat:@"%d", (int)fontSize];
    
    
    //Update the text object
    UIFont *font = self.textObj.labelFont;
    font = [font fontWithSize:fontSize];
    [self.textObj setTextFont:font];
}

- (IBAction)clickOnBackButton:(id)sender{
    [self removeColorPicker];
    [self removeFontSelector];
    
    PZEditMainVC *mainVC = (PZEditMainVC*)[self.navigationController parentViewController];
    [mainVC deselectCurrentTextObject];
}

- (IBAction)clickOnTextColorBtn:(id)sender{
    [self removeFontSelector];
    [self removeColorPicker];
    //Add color picker to your view
    [self.view addSubview:colorTextPickerView];
}

- (IBAction)clickOnGlowColorBtn:(id)sender{
    [self removeFontSelector];
    [self removeColorPicker];
    //Add color picker to your view
    [self.view addSubview:colorGlowPickerView];
}

- (IBAction)clickOnGlowOnOffBtn:(id)sender{
    [self removeColorPicker];
    [self removeFontSelector];
    
    BOOL isOn = [(UISwitch*)sender isOn];
    if (isOn) {
        [self.textObj setTextGrowEffect:self.viewGlowColor.backgroundColor];
    }
    else{
        [self.textObj setTextGrowEffect:[UIColor clearColor]];        
    }
}

- (IBAction)clickOnEditText:(id)sender{
    [self removeColorPicker];
    [self removeFontSelector];
    
    [self.textObj setEditText];
}

- (IBAction)clickOnFontSelection:(id)sender{
    [self removeColorPicker];
    
    self.fontTbl.hidden = NO;
}

- (IBAction)clickOnBG:(id)sender{
    [self removeColorPicker];
    [self removeFontSelector];
}

#pragma mark - UITableView Delegate and Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[AppData appData].arrayFonts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellFont";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *strFontName = [[AppData appData].arrayFonts objectAtIndex:indexPath.row];
    cell.textLabel.text = strFontName;
    [cell.textLabel setFont:[UIFont fontWithName:strFontName size:15]];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *strFontName = [[AppData appData].arrayFonts objectAtIndex:indexPath.row];
    self.lblFont.text = strFontName;
    
    [self.fontTbl setHidden:YES];
    
    //Set font for text
    UIFont *font = [UIFont fontWithName:strFontName size:self.sizeSlider.value];
    [self.textObj setTextFont:font];
}

@end
