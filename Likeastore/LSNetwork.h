//
//  LSNetwork.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 20.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSNetwork : NSObject

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *service;
@property BOOL disabled;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
