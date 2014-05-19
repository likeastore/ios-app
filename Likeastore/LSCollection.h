//
//  LSCollection.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSCollection : NSObject

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;

@property (strong, nonatomic) NSString *ownerID;
@property (strong, nonatomic) NSString *ownerName;
@property (strong, nonatomic) NSString *ownerAvatar;

@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *thumbnail;

@property (strong, nonatomic) NSNumber *followersCount;
@property (strong, nonatomic) NSNumber *itemsCount;

@property (strong, nonatomic) NSArray *followers;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

- (BOOL) isDescription;
- (BOOL) thumbnailIsGIF;
- (BOOL) followedByUser:(NSString *)userId;

@end
