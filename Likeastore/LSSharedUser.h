//
//  LSSharedUser.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 16.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSUser.h"

@protocol LSSharedUserDelegate <NSObject>

@optional
- (void)didAuthorizationCheck:(BOOL)isAuthorized;
- (void)haveSharedUser:(LSUser *)user;

@end

@interface LSSharedUser : NSObject

@property (weak, nonatomic) id <LSSharedUserDelegate> delegate;

+ (instancetype)create;
+ (LSUser *)sharedUser;
- (void)checkUserAuthorized;
- (void)needsAuthorizedUser;
+ (void)deleteAuthCookie;

@end
