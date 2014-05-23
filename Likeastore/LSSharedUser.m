//
//  LSSharedUser.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 16.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSSharedUser.h"
#import "LSUser.h"
#import "LSLikeastoreHTTPClient.h"

@implementation LSSharedUser

static LSUser *_sharedLikeastoreUser = nil;

+ (instancetype)create {
    static LSSharedUser *_sharedUserLikeastoreClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUserLikeastoreClient = [[self alloc] init];
    });
    
    return _sharedUserLikeastoreClient;
}

#pragma mark - User initializing via API

/**
 * Make request to api server on the first call
 * on other calls return initialized user
 */
+ (LSUser *)sharedUser {
    return _sharedLikeastoreUser;
}

+ (void)unauthorizeSharedUser {
    _sharedLikeastoreUser = nil;
}

/** 
 * Return user in delegate if it was got and authorized
 * make request to server if user is nil
 */
- (void)needsAuthorizedUser:(BOOL)force {
    if (!_sharedLikeastoreUser || force) {
        LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
        [api getUser:^(AFHTTPRequestOperation *operation, id user) {
            _sharedLikeastoreUser = [[LSUser alloc] initWithDictionary:user];
            [self callHaveSharedUserDelegate:_sharedLikeastoreUser];
        } failure:nil];
    } else {
        [self callHaveSharedUserDelegate:_sharedLikeastoreUser];
    }
}

- (void)callHaveSharedUserDelegate:(id)sharedUser {
    if ([self.delegate respondsToSelector:@selector(haveSharedUser:)]) {
        [self.delegate haveSharedUser:sharedUser];
    }
}

#pragma mark - Auth and cookies

- (void)checkUserAuthorized {
    BOOL haveCookie = NO;
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:API_URL]];
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"auth_token"]) {
            haveCookie = YES;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didAuthorizationCheck:)]) {
        [self.delegate didAuthorizationCheck:haveCookie];
    }
}

+ (void)deleteAuthCookie {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:API_URL]];
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"auth_token"]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

@end
