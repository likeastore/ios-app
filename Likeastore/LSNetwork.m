//
//  LSNetwork.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 20.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSNetwork.h"
#import "NSDictionary+LSItem.h"

@implementation LSNetwork

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        __id = [dictionary objectForKeyNotNull:@"id"];
        _service = [dictionary objectForKeyNotNull:@"service"];
        _disabled = [[dictionary objectForKeyNotNull:@"disabled"] boolValue];
    }
    
    return  self;
}

@end
