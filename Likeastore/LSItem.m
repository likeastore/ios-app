//
//  LSItem.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSItem.h"
#import "NSDictionary+LSItem.h"

@implementation LSItem

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        __id = [dictionary objectForKeyNotNull:@"_id"];
        _title = [dictionary objectForKeyNotNull:@"title"];
        _repo = [dictionary objectForKeyNotNull:@"repo"];
        _name = [dictionary objectForKeyNotNull:@"name"];
        _description = [dictionary objectForKeyNotNull:@"description"];
        _thumbnail = [dictionary objectForKeyNotNull:@"thumbnail"];
        _source = [dictionary objectForKeyNotNull:@"source"];
        _type = [dictionary objectForKeyNotNull:@"type"];
        _gist = [dictionary objectForKeyNotNull:@"gist"];
        _author = [dictionary objectForKeyNotNull:@"authorName"];
        _avatar = [dictionary objectForKeyNotNull:@"avatarUrl"];
        _collection = [NSDictionary dictionaryWithDictionary:dictionary[@"collection"]];
    }
    
    return  self;
}

- (NSString *) title {
    NSString *result;
    
    if (_title) {
        result = _title;
    } else if (_repo) {
        result = _repo;
    } else if (_name) {
        result = _name;
    }
    
    return  result;
}

- (NSString *) description {
    if (_description == _name && [_type isEqualToString:@"facebook"]) {
        return _source;
    }
    if (!_description && self.isGist) {
        return _source;
    }
    return _description;
}

- (BOOL) isThumbnail {
    return _thumbnail ? YES : NO;
}

- (BOOL) thumbnailIsGIF {
    return [[_thumbnail pathExtension] isEqualToString:@"gif"] ? YES : NO;
}

- (BOOL) isTitle {
    return (_title || _repo || _name) ? YES : NO;
}

- (BOOL) isAvatar {
    if ([_type isEqualToString:@"facebook"] ||
        !_avatar) {
        return NO;
    }
    return YES;
}

- (BOOL) isGist {
    return _gist ? YES : NO;
}

- (BOOL) isAuthor {
    return _author ? YES : NO;
}

@end
