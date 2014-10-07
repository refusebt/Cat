//
//  Cat.h
//  Cat
//
//  Created by GZH on 14-10-6.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "CatUI.h"
#import "CatData.h"

@interface Cat : NSObject
{

}
@property (nonatomic, readonly) NSBundle *bundle;
@property (nonatomic, readonly) CatUI *catUI;
@property (nonatomic, readonly) CatData *catData;

+ (instancetype)sharedPlugin;

@end