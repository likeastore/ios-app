//
//  LSUser.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 12.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSUser.h"
#import "NSDictionary+LSItem.h"

@implementation LSUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        __id = [dictionary objectForKeyNotNull:@"_id"];
        _name = [dictionary objectForKeyNotNull:@"name"];
        _username = [dictionary objectForKeyNotNull:@"username"];
        _avatar = [dictionary objectForKeyNotNull:@"avatar"];
        _displayName = [dictionary objectForKeyNotNull:@"displayName"];
        _email = [dictionary objectForKeyNotNull:@"email"];
        _provider = [dictionary objectForKeyNotNull:@"provider"];
        _warning = [dictionary objectForKeyNotNull:@"warning"];
        _firstTimeUser = [dictionary objectForKeyNotNull:@"firstTimeUser"];
        _followCollections = [dictionary objectForKeyNotNull:@"followCollections"];
        _apiToken = [dictionary objectForKeyNotNull:@"apiToken"];
        _registered = [dictionary objectForKeyNotNull:@"registered"];
    }
    
    return  self;
}

- (int)followCollectionsCount {
    CGFloat c = [self.followCollections count];
    return c;
}

- (BOOL)isFirstTimeUser {
    return _firstTimeUser ? YES : NO;
}

- (BOOL)isWarning {
    return _warning ? YES : NO;
}

- (BOOL)isLocalProvider {
    return [_provider isEqual:@"local"] ? YES : NO;
}

- (BOOL)isDisplayName {
    return _displayName ? YES : NO;
}

@end
