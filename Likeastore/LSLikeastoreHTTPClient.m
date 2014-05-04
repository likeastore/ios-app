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
+ (LSLikeastoreHTTPClient *) create {
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

- (AFHTTPRequestOperation *) getEmailAndAPIToken:(NSString *)userId success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"id", SHARED_SECRET,@"access_token", nil];
    
    return [self GET:[AUTH_URL stringByAppendingString:@"/mobile/user"] parameters:user success:success failure:failure];
}

- (AFHTTPRequestOperation *) loginWithCredentials:(id)credentials
                                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    return [self POST:[AUTH_URL stringByAppendingString:@"/local/login"] parameters:credentials success:success failure:failure];
}

- (AFHTTPRequestOperation *) getAccessToken:(id)parameters
                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    return [self POST:[API_URL stringByAppendingString:@"/auth/login"] parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *) logout {
    return [self logoutWithSuccessBlock:nil failure:nil];
}

- (AFHTTPRequestOperation *) logoutWithSuccessBlock:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    return [self POST:[API_URL stringByAppendingString:@"/auth/logout"] parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *) getUser:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    return [self GET:[API_URL stringByAppendingString:@"/users/me"] parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *) getFeed:(int)page success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    //ZG1pdHJpLnZvcm9uaWFuc2tpQGdtYWlsLmNvbTsxMzk4ODY5NDUxMTk3O2MzODViNTIzNzY2ZDM3YmMyNTg0MmQxODk0NzUyMzFkODNiZTE4MWU
    
    // bmV3MzAwQGxpa2Vhc3RvcmUuY29tOzEzOTg4NjM0NTE0MTE7NjA2YmQzYTlkMDZiY2U0ZWE5NmZjYmJhY2ZkMjMzN2ZjNmVmMzk3Yg
    return [self GET:[API_URL stringByAppendingString:@"/feed"] parameters:@{@"page": [@(page) stringValue], @"accessToken": @"bmV3MzAwQGxpa2Vhc3RvcmUuY29tOzEzOTg4NjM0NTE0MTE7NjA2YmQzYTlkMDZiY2U0ZWE5NmZjYmJhY2ZkMjMzN2ZjNmVmMzk3Yg"} success:success failure:failure];
}

- (AFHTTPRequestOperation *) getAllFavorites:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    return [self GET:[API_URL stringByAppendingString:@"/items"] parameters:@{@"accessToken": @"bmV3MzAwQGxpa2Vhc3RvcmUuY29tOzEzOTg4NjM0NTE0MTE7NjA2YmQzYTlkMDZiY2U0ZWE5NmZjYmJhY2ZkMjMzN2ZjNmVmMzk3Yg"} success:success failure:failure];
}

@end
