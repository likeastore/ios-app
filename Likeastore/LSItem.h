//
//  LSItem.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSItem : NSObject

@property (strong, nonatomic) NSString *_id;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *repo;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSURL *source;

@property NSDictionary *collection;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

- (BOOL) isThumbnail;
- (BOOL) thumbnailIsGIF;
- (BOOL) isTitle;

@end
