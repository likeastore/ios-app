//
//  NSDictionary+NSObject.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 01.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSObject)

- (id)objectForKeyNotNull:(id)key;

@end
