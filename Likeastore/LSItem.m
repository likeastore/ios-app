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
        _thumbnail = [dictionary objectForKeyNotNull:@"thumbnail"];//[NSURL URLWithString:dictionary[@"thumbnail"]];
        _source = [dictionary objectForKeyNotNull:@"source"];//[NSURL URLWithString:dictionary[@"source"]];
        _type = [dictionary objectForKeyNotNull:@"type"];
        _author = [dictionary objectForKeyNotNull:@"author"];
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

- (UIImage *) thumbnailImage {
    NSURL * thumbnailURL = [NSURL URLWithString:_thumbnail];
    NSData *imageData = [NSData dataWithContentsOfURL:thumbnailURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
}

- (BOOL) isThumbnail {
    return _thumbnail ? YES : NO;
}

@end
