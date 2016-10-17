//
//  PZAPI.m
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//



#import "PZAPI.h"
#import "AppData.h"
#import <AFNetworking/AFNetworking.h>

#define REGISTER_ACTION                             @"/register"
#define LOGIN_ACTION                                @"/login"
#define POSTIMAGE_ACTION                            @"/api/image/post"
#define USERSETTING_ACTION                          @"/api/user"
#define GETUSERDETAIL_ACTION                        @"/me"
#define GETCATALOG_ACTION                           @"/mobile/achievements"
#define CHANGEUSERNAME_ACTION                       @"/api/user/change"

#define POSTCOMMENT_ACTION                          @"/api/comment"
#define GETRECENTCOMMENT_ACTION                     @"/comment/"
#define GET_PROFILE_IMAGE_ACTION                    @"/u/"
#define GET_LIST_OF_TOP_ARTISTS_ACTION              @"/api/following/topartists"
#define GET_USERS_TO_FOLLOW_ACTION                  @"/api/following/find"
#define MATCH_CONTACTS_ACTION                       @"/api/contacts/find"
#define SEARCH_MATCH_USERS_ACTION                   @"/search/user/"
#define GET_IMAGE_DETAILS_ACTION                    @"/image/"
#define GET_LIST_OF_PHOTOS_ACTION                   @"/svc/mypizap"
#define SUBMIT_CONTACT_US_ACTION                    @"/form/contact_us"
#define PURCHASE_UPGRADE_ACTION                     @"/purchase/coin/"
#define AUTHORIZE_ACTION                            @"/oauth/authorize"
#define BUY_UPGRADE_COINS                           @"/store/buy/"
#define LOG_EVENT                                   @"/log/"
#define GET_LIST_OF_THEMES                          @"/api/theme/default"
#define GET_GALLERY_LIST_FOR_FOLLOWING_FEED_ACTION  @"/api/gallery/following/"
#define GET_GALLERY_LIST_FOR_POPULAR_FEED_ACTION    @"/mobile/gallery/views/today/"
#define LIKE_IMAGE_ACTION                           @"/api/like/"
#define REPORT_IMAGE_ACTION                         @"/api/report/"
#define REPOST_IMAGE_ACTION                         @"/api/repost/"
#define FOLLOW_USER_ACTION                          @"/api/follow/"
#define GET_NOTIFICATION                            @"/api/notifications"
#define PROCESS_FACEBOOK                            @"/process_facebook"
#define GET_USER_FOLLOWERS                          @"/api/user/"
#define GET_USER_FOLLOWINGS                         @"/api/user/"
#define GET_TOKENS_ACTION                           @"/notify/token"
#define GET_USER_INFO                               @"/mobile/user/"


@implementation PZAPI


#pragma mark - Param Check

/**
 A function that check if any param is nil
 @param1 the first param
 @param2 the second number
 ...
 @returns bool value for check result
 */
+ (BOOL)checkStringParamsNil:(NSString*)param1, ... NS_REQUIRES_NIL_TERMINATION{
    va_list args;
    va_start(args, param1);
    for (NSString *arg = param1; arg != nil; arg = va_arg(args, NSString*))
    {
        if (!arg || arg.length < 1){
            return NO;
        }
    }
    va_end(args);
    
    return YES;
}

#pragma mark - Authentication

/**
 A function that make user register
 @param 
 @param
 @return
 */
+ (void) registerWithClientID:(NSString *)client_id
                response_type:(NSString *)response_type
                       isajax:(NSString *)isajax
                     username:(NSString *)username
                     password:(NSString *)password
                   password_c:(NSString *)password_c
                        email:(NSString *)email
                      email_c:(NSString *)email_c
                       mobile:(BOOL)mobile
           andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"Error");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:client_id, response_type, isajax, username, password, password_c, email, email_c, nil]) {
        completionBlock(NO, @"Error");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:REGISTER_ACTION];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?client_id=%@", client_id]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&response_type=%@", response_type]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&isajax=%@", isajax]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"username": username, @"password": password, @"password_c": password_c, @"email": email, @"email_c":email_c, @"mobile":[NSNumber numberWithBool:mobile]};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *errorMsg;
        if (responseObject && (errorMsg = [responseObject objectForKey:@"Error"])) {
            completionBlock(NO, errorMsg);
        }else{
            completionBlock(YES, responseObject);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, @"Error");
    }];
}

+ (void) loginWithClientID:(NSString *)client_id
             response_type:(NSString *)response_type
                    isajax:(NSString *)isajax
                  username:(NSString *)username
                  password:(NSString *)password
                       ach:(NSString *)ach
        andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"Error");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:client_id, response_type, isajax, username, password, ach, nil]) {
        completionBlock(NO, @"Error");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:LOGIN_ACTION];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?client_id=%@", client_id]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&response_type=%@", response_type]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&isajax=%@", isajax]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&ach=%@", ach]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"username": username, @"password": password};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSString *errorMsg;
        if (responseObject && (errorMsg = [responseObject objectForKey:@"Error"])) {
            completionBlock(NO, errorMsg);
        }else{
            completionBlock(YES, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, @"Error");
    }];
}


#pragma mark -
+ (void) postImageWithTitle:(NSString *)title
             posttofacebook:(NSString *)posttofacebook
                publicvalue:(NSString *)publicvalue
              posttotwitter:(NSString *)posttotwitter
               posttotumblr:(NSString *)posttotumblr
                       data:(NSData *)data
               access_token:(NSString *)access_token
         andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, nil]) {
        completionBlock(NO, @"No Access Token");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:POSTIMAGE_ACTION];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    
    
    NSDictionary *params = @{@"title" : title, @"posttofacebook": posttofacebook, @"publicvalue": publicvalue, @"posttotwitter": posttotwitter, @"posttotumblr" : posttotumblr};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"data" fileName:@"1.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}


+ (void) saveUserSettingWithName:(NSString *)name
                         tagline:(NSString *)tagline
                           style:(NSString *)style
                    profileImage:(NSString *)profileImage
                           email:(NSString *)email
                    access_token:(NSString *)access_token
              andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token,nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:USERSETTING_ACTION];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) {
        [params setObject:name forKey:@"name"];
    }
    
    if (tagline) {
        [params setObject:tagline forKey:@"tagline"];
    }
    
    if (style) {
        [params setObject:style forKey:@"style"];
    }
    
    if (profileImage) {
        [params setObject:profileImage forKey:@"profileImage"];
    }
    
    if (email) {
        [params setObject:email forKey:@"email"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) getUserDetailsWithAccessToken:(NSString *)access_token
                                   ach:(NSString *)ach
                    andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, ach, nil]) {
        completionBlock(NO, nil);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GETUSERDETAIL_ACTION];
    
    NSDictionary *params = @{@"access_token" : access_token, @"ach" : ach};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if (responseObject) {
            completionBlock(YES, responseObject);
        }
        else{
            completionBlock(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, @"Error");
    }];
}

+ (void) getCatalogAchievementWithCompletionBlock:(void(^)(BOOL))completionBlock{
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GETCATALOG_ACTION];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) changeUserNameWithNewUserName:(NSString *)newUserName
                              password:(NSString *)password
                                 email:(NSString *)email
                          access_token:(NSString *)access_token
                    andCompletionBlock:(void(^)(BOOL, NSString *))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:newUserName, password, email, access_token, nil]) {
        completionBlock(NO, @"There is nil param");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:CHANGEUSERNAME_ACTION];
    
    NSDictionary *params = @{@"newUserName" : newUserName, @"password": password, @"email": email, @"access_token": access_token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject) {
            
            id errorMsg;
            if ([[responseObject objectForKey:@"Success"] boolValue]) {
                completionBlock(YES, nil);
            }
            else if ((errorMsg = [responseObject objectForKey:@"Error"])){
                completionBlock(NO, errorMsg);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, @"WebService Call Error");
    }];
}

+ (void) postNewCommentWithComment:(NSString *)comment
                         imageName:(NSString *)imageName
                      access_token:(NSString *)access_token
                andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:comment, imageName, access_token, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:POSTCOMMENT_ACTION];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"comment" : comment, @"imageName": imageName};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}


+ (void) getMostRecentCommentsWithImageName:(NSString *)ImageName
                         andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:ImageName, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", GETRECENTCOMMENT_ACTION, ImageName]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) getProfileImageWithUserName:(NSString *)UserName
                  andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:UserName, nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@/profileImage.jpg",GET_PROFILE_IMAGE_ACTION, UserName]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"UserName" : UserName};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) getListOfTopArtistsWithAccessToken:(NSString *)access_token
                         andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GET_LIST_OF_TOP_ARTISTS_ACTION];
    
    NSDictionary *params = @{@"access_token" : access_token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];

}

+ (void) getUsersToFollowWithAccessToken:(NSString *)access_token
                      andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection.");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GET_USERS_TO_FOLLOW_ACTION];
    
    NSDictionary *params = @{@"access_token" : access_token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) getMatchContactWithAccessToken:(NSString *)access_token
                                   body:(NSData *)body
                     andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection.");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, body, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:MATCH_CONTACTS_ACTION];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // And finally, add it to HTTP body and job done.
    [request setHTTPBody:body];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
    
    [operation start];
}


+ (void) SearchForMatchingUsersWithSearch:(NSString *)search
                             access_token:(NSString *)access_token
                       andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection.");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, search, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:SEARCH_MATCH_USERS_ACTION];
    url = [url stringByAppendingString:search];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];

}

+ (void) GetDetailsForImageWithImageName:(NSString *)imageName
                            access_token:(NSString *)access_token
                      andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection!");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, imageName, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@/details", GET_IMAGE_DETAILS_ACTION, imageName]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"access_token" : access_token, @"imageName" : imageName};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];

}

+ (void) GetListOfPhotosForUserWithUserName:(NSString *)u
                                   isPublic:(NSNumber *)isPublic
                               access_token:(NSString *)access_token
                                       page:(int)page
                         andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection ");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, u, nil]) {
        completionBlock(NO, @"Params are not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GET_LIST_OF_PHOTOS_ACTION];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&u=%@", u]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&public=%d", isPublic.intValue]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&page=%d", page]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) ContactUsFormWithIsAjax:(NSString *)isajax
                  deviceHardware:(NSString *)deviceHardware
                          device:(NSString *)device
                  devicePlatform:(NSString *)devicePlatform
                      deviceType:(NSString *)deviceType
                   deviceVersion:(NSString *)deviceVersion
                            name:(NSString *)name
                           email:(NSString *)email
                         message:(NSString *)message
              andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:isajax, deviceHardware, device, devicePlatform, deviceType, deviceVersion, name, email, message,  nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:SUBMIT_CONTACT_US_ACTION];
    
    NSDictionary *params = @{@"isajax" : isajax, @"message" : message, @"deviceHardware" : deviceHardware, @"device" : device, @"devicePlatform" : devicePlatform, @"deviceType" : deviceType, @"deviceVersion" : deviceVersion, @"name" : name, @"email" : email};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) PurchaseUpgradeWithUpgradeID:(NSString *)UpgradeId
                         access_token:(NSString *)access_token
                   andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:UpgradeId, access_token, nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", PURCHASE_UPGRADE_ACTION, UpgradeId]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"UpgradeId" : UpgradeId, @"access_token" : access_token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}


+ (void) AuthorizeWithAccessToken:(NSString *)access_token
                        client_id:(NSString *)client_id
                    response_type:(NSString *)response_type
                           native:(NSString *)native
                     redirect_uri:(NSString *)redirect_uri
                          twitter:(NSString *)twitter
                           tumblr:(NSString *)tumblr
               andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, client_id, response_type, native, redirect_uri, twitter, tumblr, nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:AUTHORIZE_ACTION];
    
    NSDictionary *params = @{@"access_token" : access_token, @"client_id" : client_id, @"response_type" : response_type, @"native" : native, @"redirect_uri" : redirect_uri, @"twitter" : twitter, @"tumblr" : tumblr};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) BuyUpgradeWithUserName:(NSString *)UserName
                      UpgradeId:(NSString *)UpgradeId
                   access_token:(NSString *)access_token
             andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, UserName, UpgradeId, nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@/%@", BUY_UPGRADE_COINS, UserName, UpgradeId]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"access_token" : access_token, @"UserName" : UserName, @"UpgradeId" : UpgradeId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];

}


+ (void) GetLogWithEvent:(NSString *)Event
      andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:Event, nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", LOG_EVENT, Event]];
    
    NSDictionary *params = @{@"Event" : Event};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) GetListOfThemesWithAccessToken:(NSString *)access_token
                     andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"Internet connection error");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, nil]) {
        completionBlock(NO, @"Param is not filled");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GET_LIST_OF_THEMES];
    
    NSDictionary *params = @{@"access_token" : access_token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];

}

+ (void) GetGalleryListForFollowingFeedWithPage:(NSString *)Page
                                   access_token:(NSString *)access_token
                             andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, Page,nil]) {
        completionBlock(NO, @"Param is not filled");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", GET_GALLERY_LIST_FOR_FOLLOWING_FEED_ACTION, Page]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) GetGalleryListForPopularFeedWithPage:(NSString *)Page
                                 access_token:(NSString *)access_token
                           andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil: Page,nil]) {
        completionBlock(NO, @"Param is not filled");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", GET_GALLERY_LIST_FOR_POPULAR_FEED_ACTION, Page]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAppendingString:@"&comments=1"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) PostImageLikeWithImageName:(NSString *)ImageName
                       access_token:(NSString *)access_token
                 andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, ImageName,nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", LIKE_IMAGE_ACTION, ImageName]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}


+ (void) ReportImageWithImageName:(NSString *)ImageName
                     access_token:(NSString *)access_token
               andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, ImageName,nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", REPORT_IMAGE_ACTION, ImageName]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) RepostImageWithImageName:(NSString *)ImageName
                     access_token:(NSString *)access_token
               andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, ImageName,nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", REPOST_IMAGE_ACTION, ImageName]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"access_token" : access_token, @"ImageName" : ImageName};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) FollowWithUserName:(NSString *)UserName
               access_token:(NSString *)access_token
         andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection!");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token, UserName,nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@", FOLLOW_USER_ACTION, UserName]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) GetNotificationsWithAccessToken:(NSString *)access_token
                      andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:access_token,nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GET_NOTIFICATION];
    
    NSDictionary *params = @{@"access_token" : access_token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) ProcessFBWithClientID:(NSString *)client_id
                 response_type:(NSString *)response_type
                            id:(NSString *)facebookID
                         email:(NSString *)email
                          name:(NSString *)name
                        gender:(NSString *)gender
                         token:(NSString *)token
            andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection.");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:client_id, response_type, facebookID, email, name, gender, token, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:PROCESS_FACEBOOK];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?client_id=%@", client_id]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&response_type=%@", response_type]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"id" : facebookID, @"email" : email, @"name" : name, @"gender" : gender, @"token" : token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        id fragmentInfo;
        if (responseObject &&
            (fragmentInfo = [responseObject objectForKey:@"fragment"])) {
            [AppData appData].userAccessToken = [fragmentInfo objectForKey:@"access_token"];
            [AppData appData].userRefreshToken = [fragmentInfo objectForKey:@"refresh_token"];
            
            completionBlock(YES, responseObject);
        }
        else{
            completionBlock(NO, @"No Token");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) GetFollowsWithUserName:(NSString *)UserName
                   access_token:(NSString *)access_token
             andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:UserName, access_token, nil]) {
        completionBlock(NO, @"Param is not filled.");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@/followers", GET_USER_FOLLOWERS, UserName]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) GetFollowingsWithUserName:(NSString *)UserName
                      access_token:(NSString *)access_token
                andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:UserName, access_token, nil]) {
        completionBlock(NO, @"Param is not filled");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%@/following", GET_USER_FOLLOWINGS, UserName]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];
}

+ (void) GetTokensWithDeviceToken:(NSString *)device_token
                        device_id:(NSString *)device_id
                         platform:(NSString *)platform
               andCompletionBlock:(void(^)(BOOL))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO);
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:device_token, device_id, platform, nil]) {
        completionBlock(NO);
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GET_TOKENS_ACTION];
    
    NSDictionary *params = @{@"device_token" : device_token, @"device_id" : device_id, @"platform" : platform};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO);
    }];
}

+ (void) GetUserInfoWithUsername:(NSString *)UserName
                    access_token:(NSString *)access_token
              andCompletionBlock:(void(^)(BOOL, id))completionBlock{
    //Check Internet Access
    if (![[AppData appData] wifiAvaiable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection! Please check your wifi or cell signal and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        completionBlock(NO, @"No Internet Connection");
        return;
    }
    /////////////////////////
    
    if (![PZAPI checkStringParamsNil:UserName, access_token, nil]) {
        completionBlock(NO, @"Param is incorrect");
        return;
    }
    
    NSString * url = [AppData appData].getBaseUrl;
    url = [url stringByAppendingString:GET_USER_INFO];
    url = [url stringByAppendingString:UserName];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        completionBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionBlock(NO, error.description);
    }];

}

@end
