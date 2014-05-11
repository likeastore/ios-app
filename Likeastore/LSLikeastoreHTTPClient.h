//
//  LSLikeastoreHTTPClient.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface LSLikeastoreHTTPClient : AFHTTPRequestOperationManager

+ (LSLikeastoreHTTPClient *) create;

- (instancetype) init;

- (AFHTTPRequestOperation *) getEmailAndAPIToken:(id)userId success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

- (AFHTTPRequestOperation *) loginWithCredentials:(id)credentials
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getAccessToken:(id)parameters
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) logout;

- (AFHTTPRequestOperation *) logoutWithSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getUser:(void (^)(AFHTTPRequestOperation *operation, id user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getFeed:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id data))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getFavoritesWithType:(NSString *)type byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) deleteFavoritesItemByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) followCollectionByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) unfollowCollectionByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
