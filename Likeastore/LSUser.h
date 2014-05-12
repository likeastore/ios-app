//
//  LSUser.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 12.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSUser : NSObject

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *username; // name on third-party service
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *warning;
@property (strong, nonatomic) NSString *provider;
@property (strong, nonatomic) NSString *firstTimeUser;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

- (BOOL) isFirstTimeUser;
- (BOOL) isWarning;
- (BOOL) isLocalProvider;

@end
