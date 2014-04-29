//
//  LSConstants.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSConstants.h"

#ifdef DEBUG
NSString * const AUTH_URL = @"http://localhost:3000/auth";
NSString * const API_URL = @"http://localhost:3001/api";
NSString * const BLANK_HTML = @"http://localhost:3000/blank.html";
#else
NSString * const AUTH_URL = @"https://likeastore.com/auth";
NSString * const API_URL = @"https://app.likeastore.com/api";
NSString * const BLANK_HTML = @"https://likeastore.com/blank.html";
#endif

NSString * const SHARED_SECRET = @"b7d4f9c7a3a5379be36cea3e8dbfb5da44a1fdb8";