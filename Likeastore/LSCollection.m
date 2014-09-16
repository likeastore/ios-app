//
//  LSCollection.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSCollection.h"
#import "NSDictionary+LSItem.h"

#import <Underscore.m/Underscore.h>

@interface LSCollection ()

@property NSDictionary *owner;
@property NSDictionary *userData;

@end

@implementation LSCollection

@synthesize description;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        __id = [dictionary objectForKeyNotNull:@"_id"];
        _title = [dictionary objectForKeyNotNull:@"title"];
        description = [dictionary objectForKeyNotNull:@"description"];
        _owner = [dictionary objectForKeyNotNull:@"owner"];
        _userData = [dictionary objectForKeyNotNull:@"userData"];
        _color = [dictionary objectForKeyNotNull:@"color"];
        _thumbnail = [dictionary objectForKeyNotNull:@"thumbnail"];
        _followersCount = [dictionary objectForKeyNotNull:@"followersCount"];
        _itemsCount = [dictionary objectForKeyNotNull:@"count"];
        _followers = [dictionary objectForKeyNotNull:@"followers"];
    }
    
    return  self;
}

- (NSString *)description {
    if ([description isEqualToString:@""]) {
        return nil;
    }
    return description;
}

- (NSString *)ownerID {
    if (_owner) {
        return [_owner objectForKey:@"_id"];
    } else if (_userData) {
        return [_userData objectForKey:@"_id"];
    }
    
    return nil;
}

- (NSString *)ownerName {
    if (_owner) {
        return [_owner objectForKey:@"name"];
    } else if (_userData) {
        return [_userData objectForKey:@"name"];
    }
    
    return nil;
}

- (NSString *)ownerAvatar {
    if (_owner) {
        return [_owner objectForKey:@"avatar"];
    } else if (_userData) {
        return [_userData objectForKey:@"avatar"];
    }
    
    return nil;
}

- (BOOL)isDescription {
    if ([description isEqualToString:@""]) {
        return NO;
    }
    return description ? YES : NO;
}

- (BOOL)thumbnailIsGIF {
    return [[_thumbnail pathExtension] isEqualToString:@"gif"] ? YES : NO;
}

// check if user is following this collection
- (BOOL)followedByUser:(NSString *)userId {
    __block BOOL followed = NO;
    Underscore.array(_followers).each(^(NSDictionary *follower) {
        if ([[follower objectForKey:@"_id"] isEqualToString:userId]) {
            followed = YES;
        }
    });
    
    return followed;
}

- (void)addFollower:(NSString *)userId {
    @autoreleasepool {
        NSMutableArray *newFollowers = [NSMutableArray arrayWithArray:_followers];
        [newFollowers addObject:@{@"_id": userId}];
        [self setFollowers:[newFollowers mutableCopy]];
        [newFollowers removeAllObjects];
    }
}

- (void)removeFollower:(NSString *)userId {
    @autoreleasepool {
        NSMutableArray *newFollowers = [NSMutableArray arrayWithArray:_followers];
        id followerToRemove = Underscore.array(newFollowers)
            .find(^BOOL(NSDictionary *follower) {
                return [[follower objectForKey:@"_id"] isEqualToString:userId];
            });
        
        if (followerToRemove) {
            [newFollowers removeObject:followerToRemove];
            [self setFollowers:[newFollowers mutableCopy]];
            [newFollowers removeAllObjects];
        }
    }
}

@end
