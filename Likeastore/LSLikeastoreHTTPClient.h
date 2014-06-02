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

#pragma mark - Login and authorization

- (AFHTTPRequestOperation *) getEmailAndAPIToken:(id)userId success:(void (^)(AFHTTPRequestOperation *operation, id user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) loginWithCredentials:(id)credentials success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getAccessToken:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) logout;

- (AFHTTPRequestOperation *) logoutWithSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) setupUser:(id)userData success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark - User

- (AFHTTPRequestOperation *) getUser:(void (^)(AFHTTPRequestOperation *operation, id user))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark - Favorites

- (AFHTTPRequestOperation *) getFeed:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id data))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getFavoritesWithType:(NSString *)type byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) searchFavoritesByText:(NSString *)text byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id collections))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getInboxCount:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)flagItemWithID:(NSString *)itemId withReason:(NSString *)reason success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark - Collections

- (AFHTTPRequestOperation *) getCollections:(void (^)(AFHTTPRequestOperation *operation, id collections))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getCollectionsFollowedByUser:(NSString *)username success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

- (AFHTTPRequestOperation *) getPopularCollections:(void (^)(AFHTTPRequestOperation *operation, id collections))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) searchPopularCollectionsByText:(NSString *)text success:(void (^)(AFHTTPRequestOperation *operation, id collections))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) deleteFavoritesItemByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) followCollectionByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) unfollowCollectionByID:(NSString *)_id success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) getFavoritesFromCollectionID:(NSString *)_id byPage:(CGFloat)page success:(void (^)(AFHTTPRequestOperation *operation, id favorites))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark - Networks

- (AFHTTPRequestOperation *) getNetworks:(void (^)(AFHTTPRequestOperation *operation, id networks))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) connectNetwork:(NSString *)networkName success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) connectDribbble:(NSString *)username success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *) deleteNetwork:(NSString *)networkName success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
