//
//  LSLikeastoreHTTPClient.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSLikeastoreHTTPClient.h"

@implementation LSLikeastoreHTTPClient

// creates singleton instance
+ (LSLikeastoreHTTPClient *)create {
    static LSLikeastoreHTTPClient *_sharedLikeastoreHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLikeastoreHTTPClient = [[self alloc] init];
    });
    
    return _sharedLikeastoreHTTPClient;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    return self;
}

- (AFHTTPRequestOperation *)getEmailAndAPIToken:(NSString *)userId success:(void (^)(AFHTTPRequestOperation *operation, id user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"id", SHARED_SECRET,@"access_token", nil];
    
    return [self GET:[AUTH_URL stringByAppendingString:@"/mobile/user"] parameters:user success:success failure:failure];
}

- (AFHTTPRequestOperation *)loginWithCredentials:(id)credentials
                                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:[AUTH_URL stringByAppendingString:@"/local/login"] parameters:credentials success:success failure:failure];
}

- (AFHTTPRequestOperation *)getAccessToken:(id)parameters
                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    return [self POST:[API_URL stringByAppendingString:@"/auth/login"] parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)setupUser:(id)userData success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self POST:[AUTH_URL stringByAppendingString:@"/setup"] parameters:userData success:success failure:failure];
}

- (AFHTTPRequestOperation *)logout
{
    return [self logoutWithSuccessBlock:nil failure:nil];
}

- (AFHTTPRequestOperation *)logoutWithSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:[API_URL stringByAppendingString:@"/auth/logout"] parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)getUser:(void (^)(AFHTTPRequestOperation *operation, id user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/users/me"] parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)getFeed:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/feed"] parameters:@{@"page": [@(page) stringValue], @"pageSize": @"15"} success:success failure:failure];
}

- (AFHTTPRequestOperation *)getFavoritesWithType:(NSString *)type byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *uri = [type isEqualToString:@"all"] ?
        [API_URL stringByAppendingString:@"/items"] :
        [API_URL stringByAppendingFormat:@"/items/%@", type];
    
    return [self GET:uri parameters:@{@"page": [@(page) stringValue], @"pageSize": @"15"} success:success failure:failure];
}

- (AFHTTPRequestOperation *)deleteFavoritesItemByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self DELETE:[API_URL stringByAppendingFormat:@"/items/%@", _id] parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)getPopularCollections:(void (^)(AFHTTPRequestOperation *operation, id collections))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/collections/explore"] parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)searchPopularCollectionsByText:(NSString *)text success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self GET:[API_URL stringByAppendingString:@"/collections/search"] parameters:@{@"text": text} success:success failure:failure];
}

@end
