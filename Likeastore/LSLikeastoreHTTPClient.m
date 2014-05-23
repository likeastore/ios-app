//
//  LSLikeastoreHTTPClient.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSLikeastoreHTTPClient.h"

#import <JDStatusBarNotification/JDStatusBarNotification.h>

@implementation LSLikeastoreHTTPClient

// creates singleton instance
+ (LSLikeastoreHTTPClient *)create
{
    static LSLikeastoreHTTPClient *_sharedLikeastoreHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLikeastoreHTTPClient = [[self alloc] init];
    });
    
    return _sharedLikeastoreHTTPClient;
}

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [self setupConnectionReachabilityMonitor];
    }
    
    return self;
}

#pragma mark - Reachability

- (void)setupConnectionReachabilityMonitor
{
    // create custom notification styles
    [JDStatusBarNotification addStyleNamed:@"BadConnectionNoty" prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        style.barColor = [UIColor colorWithHexString:@"#f56557"];
        style.textColor = [UIColor whiteColor];
        
        return style;
    }];
    
    // setup block handler
    __weak LSLikeastoreHTTPClient *weakSelf = self;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [JDStatusBarNotification dismissAnimated:YES];
                [weakSelf.operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [JDStatusBarNotification showWithStatus:@"No internet connection" dismissAfter:5.0 styleName:@"BadConnectionNoty"];
                [weakSelf.operationQueue setSuspended:YES];
                break;
                
            default:
                [JDStatusBarNotification dismissAnimated:YES];
                [weakSelf.operationQueue setSuspended:NO];
                break;
        }
    }];
    
    // start monitoring
    [self.reachabilityManager startMonitoring];
}

#pragma mark - Login and authorization

- (AFHTTPRequestOperation *)getEmailAndAPIToken:(NSString *)userId success:(void (^)(AFHTTPRequestOperation *operation, id user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"id", SHARED_SECRET,@"access_token", nil];
    
    return [self GET:[AUTH_URL stringByAppendingString:@"/mobile/user"]
          parameters:user
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)loginWithCredentials:(id)credentials success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:[AUTH_URL stringByAppendingString:@"/local/login"]
           parameters:credentials
              success:success
              failure:failure];
}

- (AFHTTPRequestOperation *)getAccessToken:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:[API_URL stringByAppendingString:@"/auth/login"]
           parameters:parameters
              success:success
              failure:failure];
}

- (AFHTTPRequestOperation *)setupUser:(id)userData success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self POST:[AUTH_URL stringByAppendingString:@"/setup"]
           parameters:userData
              success:success
              failure:failure];
}

- (AFHTTPRequestOperation *)logout
{
    return [self logoutWithSuccessBlock:nil failure:nil];
}

- (AFHTTPRequestOperation *)logoutWithSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:[API_URL stringByAppendingString:@"/auth/logout"]
           parameters:nil
              success:success
              failure:failure];
}

#pragma mark - User

- (AFHTTPRequestOperation *)getUser:(void (^)(AFHTTPRequestOperation *operation, id user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/users/me"]
          parameters:nil
             success:success
             failure:failure];
}

#pragma mark - Favorites

- (AFHTTPRequestOperation *)getFeed:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/feed"]
          parameters:@{@"page": [@(page) stringValue], @"pageSize": @"15"}
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)getFavoritesWithType:(NSString *)type byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *uri = [type isEqualToString:@"all"] ?
        [API_URL stringByAppendingString:@"/items"] :
        [API_URL stringByAppendingFormat:@"/items/%@", type];
    
    return [self GET:uri
          parameters:@{@"page": [@(page) stringValue], @"pageSize": @"15"}
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)searchFavoritesByText:(NSString *)text byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    return [self GET:[API_URL stringByAppendingString:@"/search"]
          parameters:@{@"text": text, @"page": [@(page) stringValue], @"pageSize": @"20"}
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)deleteFavoritesItemByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self DELETE:[API_URL stringByAppendingFormat:@"/items/%@", _id]
             parameters:nil
                success:success
                failure:failure];
}

- (AFHTTPRequestOperation *)getInboxCount:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/items/inbox/count"]
          parameters:nil
             success:success
             failure:failure];
}

#pragma mark - Collections

- (AFHTTPRequestOperation *)getCollections:(void (^)(AFHTTPRequestOperation *operation, id collections))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/collections"]
          parameters:nil
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)getPopularCollections:(void (^)(AFHTTPRequestOperation *operation, id collections))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/collections/explore"]
          parameters:nil
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)searchPopularCollectionsByText:(NSString *)text success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/collections/search"]
          parameters:@{@"text": text}
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)getFavoritesFromCollectionID:(NSString *)_id byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self GET:[API_URL stringByAppendingFormat:@"/collections/%@/items", _id]
          parameters:@{@"page": [@(page) stringValue], @"pageSize": @"15"}
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)followCollectionByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self PUT:[API_URL stringByAppendingFormat:@"/collections/%@/follow", _id]
          parameters:nil
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)unfollowCollectionByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self DELETE:[API_URL stringByAppendingFormat:@"/collections/%@/follow", _id]
          parameters:nil
             success:success
             failure:failure];
}

#pragma mark - Networks

- (AFHTTPRequestOperation *)getNetworks:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/networks"]
          parameters:nil
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)connectNetwork:(NSString *)networkName success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self POST:[API_URL stringByAppendingFormat:@"/networks/%@", networkName]
          parameters:nil
             success:success
             failure:failure];
}

- (AFHTTPRequestOperation *)connectDribbble:(NSString *)username success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self POST:[API_URL stringByAppendingString:@"/networks/dribbble"]
           parameters:@{@"username": username}
              success:success
              failure:failure];
}

- (AFHTTPRequestOperation *)deleteNetwork:(NSString *)networkName success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self DELETE:[API_URL stringByAppendingFormat:@"/networks/%@", networkName]
           parameters:nil
              success:success
              failure:failure];
}

@end
