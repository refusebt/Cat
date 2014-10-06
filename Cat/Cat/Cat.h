//
//  Cat.h
//  Cat
//
//  Created by GZH on 14-10-6.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface Cat : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end