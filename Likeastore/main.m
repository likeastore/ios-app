//
//  main.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        // Uncomment these line on DEBUG for development purposes
       //[NUISettings setAutoUpdatePath:@"/Users/dmitri/ios/Likeastore/Beta/Likeastore/Likeastore/LSNUITheme.nss"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([LSAppDelegate class]));
    }
}
