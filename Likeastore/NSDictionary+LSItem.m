//
//  NSDictionary+NSObject.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 01.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "NSDictionary+LSItem.h"

@implementation NSDictionary (NSObject)

- (id)objectForKeyNotNull:(id)key {
    __weak id object = [self objectForKey:key];
    
    if (object == [NSNull null]) {
        return nil;
    }
    
    return object;
}

@end
