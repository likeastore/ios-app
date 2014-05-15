//
//  LSCollection.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSCollection.h"
#import "NSDictionary+LSItem.h"

@interface LSCollection ()

@property NSDictionary *owner;

@end

@implementation LSCollection

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        __id = [dictionary objectForKeyNotNull:@"_id"];
        _title = [dictionary objectForKeyNotNull:@"title"];
        _description = [dictionary objectForKeyNotNull:@"description"];
        _owner = [dictionary objectForKeyNotNull:@"owner"];
        _color = [dictionary objectForKeyNotNull:@"color"];
        _thumbnail = [dictionary objectForKeyNotNull:@"thumbnail"];
    }
    
    return  self;
}

- (NSString *) description {
    if ([_description isEqualToString:@""]) {
        return nil;
    }
    return _description;
}

- (NSString *) ownerID {
    return [_owner objectForKey:@"_id"];
}

- (NSString *) ownerName {
    return [_owner objectForKey:@"name"];
}

- (NSString *) ownerAvatar {
    return [_owner objectForKey:@"avatar"];
}

- (BOOL) isDescription {
    if ([_description isEqualToString:@""]) {
        return NO;
    }
    return _description ? YES : NO;
}

- (BOOL) thumbnailIsGIF {
    return [[_thumbnail pathExtension] isEqualToString:@"gif"] ? YES : NO;
}

@end
