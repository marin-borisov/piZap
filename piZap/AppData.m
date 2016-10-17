//
//  AppData.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//


#import "AppData.h"
#import <Reachability.h>
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

static AppData * instance;
static NSString * const API_KEY       = @"15U1U29p42mG0914h7148376qdlV8n1j";
static NSString * const BASEURL_PROD  = @"https://api.pizap.com";
static NSString * const BASEURL_DEVEL = @"https://pizaptest.pizap.com";
static const BOOL DEVEL_SERVER  = NO;

static NSString * const ASSETS_JSON_PATH = @"http://cdn.pizap.com/html5/assets.json";

@implementation AppData
{
    NSUserDefaults * _userDefaults;
    Reachability *_reachability;
}

@synthesize latitude, longitude;

+ (AppData *)appData{
    static AppData *sharedMyAppData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyAppData = [[self alloc] init];
    });
    return sharedMyAppData;
}

- (id)init{
    self = [super init];
    if (self){
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _reachability = [Reachability reachabilityWithHostname:[self getBaseUrl]];
        _isLoggedIn = NO;
        [_reachability startNotifier];
        
        [self getFonts];
    }
    return self;
}


#pragma mark - Fonts
- (void)getFonts{
    self.arrayFonts = [NSMutableArray array];
    for (NSString* family in [UIFont familyNames])
    {
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            [self.arrayFonts addObject:name];
        }
    }
}

#pragma mark - Label
- (CGFloat)getActualFontSizeForLabel:(UILabel *)label
{
    NSStringDrawingContext *labelContext = [NSStringDrawingContext new];
    labelContext.minimumScaleFactor = label.minimumScaleFactor;
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:label.text attributes:@{ NSFontAttributeName: label.font }];
    [attributedString boundingRectWithSize:label.frame.size
                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   context:labelContext];
    
    CGFloat actualFontSize = label.font.pointSize * labelContext.actualScaleFactor;
    return actualFontSize;
}

#pragma mark - globa preferences

- (NSString *)username{
    return [_userDefaults objectForKey:@"username"];
}
- (void)setUsername:(NSString *)username{
    [_userDefaults setObject:username forKey:@"username"];
    [_userDefaults synchronize];
}

- (NSString *)firstname{
    return [_userDefaults objectForKey:@"firstname"];
}
- (void)setFirstname:(NSString *)firstname{
    [_userDefaults setObject:firstname forKey:@"firstname"];
    [_userDefaults synchronize];
}

- (NSString *)lastname{
    return [_userDefaults objectForKey:@"lastname"];
}
- (void)setLastname:(NSString *)lastname{
    [_userDefaults setObject:lastname forKey:@"lastname"];
    [_userDefaults synchronize];
}

- (NSString *)userAccessToken{
    return [_userDefaults objectForKey:@"userAccessToken"];
}

- (void)setUserAccessToken:(NSString*)userAccessToken{
    [_userDefaults setObject:userAccessToken forKey:@"userAccessToken"];
    [_userDefaults synchronize];
}

- (void)goToLoggedInVC{
    self.isLoggedIn = YES;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PZBaseViewController"];
    
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] setRootViewController:vc];
}

- (void)loggedOut{
    self.isLoggedIn = NO;
    
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] setRootViewController:self.firstTabBarVC];
    
    //Clear Token
    [AppData appData].userAccessToken = @"";
    
    //Clear cached image
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}

- (NSString*)strPathDocumentDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirectory = [paths objectAtIndex:0];
    
    return appSupportDirectory;
}
- (BOOL)loadAssetJSON{
    NSError *error=nil;
    
    //Load Local Assets
    NSString *strAssetJSONPath = [self strPathDocumentDirectory];
    strAssetJSONPath = [strAssetJSONPath stringByAppendingPathComponent:@"assets.json"];
    NSData *localJsonData=[NSData dataWithContentsOfFile:strAssetJSONPath];
    if (localJsonData) {
        self.assetsJsonObj = [NSJSONSerialization JSONObjectWithData:localJsonData options:NSJSONReadingMutableContainers error:&error];
    }

    
    //Check if there is any change on remote
    NSURL *url=[NSURL URLWithString:ASSETS_JSON_PATH];
    NSData *jsonData=[NSData dataWithContentsOfURL:url];
    if(jsonData != nil){
        error = nil;
        NSString *strJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        strJSON = [strJSON stringByReplacingOccurrencesOfString: @"\\'" withString: @"'"];
        
        jsonData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];
        id remoteJSONObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        if (error == nil){
            if (![localJsonData isEqualToData:jsonData]) {
                [jsonData writeToFile:strAssetJSONPath atomically:YES];
                self.assetsJsonObj = remoteJSONObj;
            }
            return YES;
        }
    }
    
    if (self.assetsJsonObj != nil) {
        return YES;
    }
    return NO;
}

#pragma mark - globa function


-(NSString *)apiKey{
    return API_KEY;
}

- (NSString *)getBaseUrl{
    if (DEVEL_SERVER){
        return BASEURL_DEVEL;
    }
    else{
        return BASEURL_PROD;
    }
}

- (BOOL)wifiAvaiable{
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        return NO;
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        return YES;
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        return YES;
    }
    
    return NO;
    
    /*
    if ([_reachability isReachable]) {
        return YES;
    }
    
    if ([_reachability isReachableViaWiFi]) {
        return YES;
    }
    
    if ([_reachability isReachableViaWWAN]) {
        return YES;
    }
    
    if ([_reachability currentReachabilityStatus] == ReachableViaWWAN){
        return YES;
    }
    if ([_reachability currentReachabilityStatus] == ReachableViaWiFi){
        return YES;
    }
    
    return NO;
    */
}

+ (BOOL)isFieldEmpty:(UITextField *)field{
    if ([field.text length] > 0){
        return NO;
    }
    else{
        return YES;
    }
}


+ (BOOL)isFieldEmail:(UITextField *)field{
    NSString * mail = field.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailText evaluateWithObject:mail];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image width:(float)newWidth {
    
    if (newWidth >= image.size.width) {
        return image;
    }
    
    float rate = image.size.width / newWidth;
    float newHeight = image.size.height / rate;
    CGSize scaledSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image height:(float)newHeight {
    
    if (newHeight >= image.size.height) {
        return image;
    }
    
    float rate = image.size.height / newHeight;
    float newWidth = image.size.width / rate;
    CGSize scaledSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image withSize:(CGSize)newSize {
    
    CGSize scaledSize = newSize;
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}



+ (NSString *)fixURLForPizap:(NSString*)url{
    if ([url hasPrefix:@"//"]){
        if ([url hasPrefix:@"//graph.facebook.com"]) {
            url = [NSString stringWithFormat:@"https:%@", url];
        }
        else{
            url = [NSString stringWithFormat:@"http:%@", url];
        }

    }
    
    if (![url containsString:@":"]){
        url = [NSString stringWithFormat:@"file://%@", url];
    }
    
    url = [url stringByReplacingOccurrencesOfString:@"http://pizap_gallery.s3.amazonaws.com/" withString:@"http://s3.amazonaws.com/pizap_gallery/"];
    url = [url stringByReplacingOccurrencesOfString:@"http://rizap_medium.s3.amazonaws.com/" withString:@"http://s3.amazonaws.com/rizap_medium/"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

+ (NSString *)urlForUserPhoto:(NSString*)username{
    if (!username || username.length == 0) {
        return @"";
    }
    
    NSString *strPhotoUrl = [NSString stringWithFormat:@"%@/u/%@/profileImage.jpg", [[AppData appData] getBaseUrl], username];
    strPhotoUrl = [strPhotoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return strPhotoUrl;
}

@end
