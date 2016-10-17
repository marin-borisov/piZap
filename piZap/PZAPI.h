//
//  PZAPI.h
//  piZap
//
//  Created by Assure Developer on 5/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PZAPI : NSObject {
    
}

+ (void) registerWithClientID:(NSString *)client_id
                response_type:(NSString *)response_type
                       isajax:(NSString *)isajax
                     username:(NSString *)username
                     password:(NSString *)password
                   password_c:(NSString *)password_c
                        email:(NSString *)email
                      email_c:(NSString *)email_c
                       mobile:(BOOL)mobile
           andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) loginWithClientID:(NSString *)client_id
             response_type:(NSString *)response_type
                    isajax:(NSString *)isajax
                  username:(NSString *)username
                  password:(NSString *)password
                       ach:(NSString *)ach
        andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) postImageWithTitle:(NSString *)title
             posttofacebook:(NSString *)posttofacebook
                publicvalue:(NSString *)publicvalue
              posttotwitter:(NSString *)posttotwitter
               posttotumblr:(NSString *)posttotumblr
                       data:(NSData *)data
               access_token:(NSString *)access_token
         andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) saveUserSettingWithName:(NSString *)name
                         tagline:(NSString *)tagline
                           style:(NSString *)style
                    profileImage:(NSString *)profileImage
                           email:(NSString *)email
                    access_token:(NSString *)access_token
              andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) getUserDetailsWithAccessToken:(NSString *)access_token
                                   ach:(NSString *)ach
                    andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) getCatalogAchievementWithCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) changeUserNameWithNewUserName:(NSString *)newUserName
                              password:(NSString *)password
                                 email:(NSString *)email
                          access_token:(NSString *)access_token
                    andCompletionBlock:(void(^)(BOOL, NSString *))completionBlock;

+ (void) postNewCommentWithComment:(NSString *)comment
                         imageName:(NSString *)imageName
                      access_token:(NSString *)access_token
                andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) getMostRecentCommentsWithImageName:(NSString *)ImageName
                         andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) getProfileImageWithUserName:(NSString *)UserName
                  andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) getListOfTopArtistsWithAccessToken:(NSString *)access_token
                         andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) getUsersToFollowWithAccessToken:(NSString *)access_token
                      andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) getMatchContactWithAccessToken:(NSString *)access_token
                                   body:(NSData *)body
                     andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) SearchForMatchingUsersWithSearch:(NSString *)search
                             access_token:(NSString *)access_token
                       andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetDetailsForImageWithImageName:(NSString *)imageName
                            access_token:(NSString *)access_token
                      andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetListOfPhotosForUserWithUserName:(NSString *)u
                                   isPublic:(NSNumber *)isPublic
                               access_token:(NSString *)access_token
                                       page:(int)page
                         andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) ContactUsFormWithIsAjax:(NSString *)isajax
                  deviceHardware:(NSString *)deviceHardware
                          device:(NSString *)device
                  devicePlatform:(NSString *)devicePlatform
                      deviceType:(NSString *)deviceType
                   deviceVersion:(NSString *)deviceVersion
                            name:(NSString *)name
                           email:(NSString *)email
                         message:(NSString *)message
              andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) PurchaseUpgradeWithUpgradeID:(NSString *)UpgradeId
                         access_token:(NSString *)access_token
                   andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) AuthorizeWithAccessToken:(NSString *)access_token
                        client_id:(NSString *)client_id
                    response_type:(NSString *)response_type
                           native:(NSString *)native
                     redirect_uri:(NSString *)redirect_uri
                          twitter:(NSString *)twitter
                           tumblr:(NSString *)tumblr
               andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) BuyUpgradeWithUserName:(NSString *)UserName
                      UpgradeId:(NSString *)UpgradeId
                   access_token:(NSString *)access_token
             andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) GetLogWithEvent:(NSString *)Event
      andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) GetListOfThemesWithAccessToken:(NSString *)access_token
                     andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetGalleryListForFollowingFeedWithPage:(NSString *)Page
                                   access_token:(NSString *)access_token
                             andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetGalleryListForPopularFeedWithPage:(NSString *)Page
                                 access_token:(NSString *)access_token
                           andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) PostImageLikeWithImageName:(NSString *)ImageName
                       access_token:(NSString *)access_token
                 andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) ReportImageWithImageName:(NSString *)ImageName
                     access_token:(NSString *)access_token
               andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) RepostImageWithImageName:(NSString *)ImageName
                     access_token:(NSString *)access_token
               andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) FollowWithUserName:(NSString *)UserName
               access_token:(NSString *)access_token
         andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetNotificationsWithAccessToken:(NSString *)access_token
                      andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) ProcessFBWithClientID:(NSString *)client_id
                 response_type:(NSString *)response_type
                            id:(NSString *)facebookID
                         email:(NSString *)email
                          name:(NSString *)name
                        gender:(NSString *)gender
                         token:(NSString *)token
            andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetFollowsWithUserName:(NSString *)UserName
                   access_token:(NSString *)access_token
             andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetFollowingsWithUserName:(NSString *)UserName
                      access_token:(NSString *)access_token
                andCompletionBlock:(void(^)(BOOL, id))completionBlock;

+ (void) GetTokensWithDeviceToken:(NSString *)device_token
                        device_id:(NSString *)device_id
                         platform:(NSString *)platform
               andCompletionBlock:(void(^)(BOOL))completionBlock;

+ (void) GetUserInfoWithUsername:(NSString *)UserName
                    access_token:(NSString *)access_token
              andCompletionBlock:(void(^)(BOOL, id))completionBlock;


@end















