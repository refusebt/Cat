//
//  Cat.m
//  Cat
//
//  Created by GZH on 14-10-6.
//    Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import "Cat.h"

static Cat *s_sharedPlugin = nil;

@interface Cat()
{
}

- (void)update;

@end

@implementation Cat
@synthesize bundle = _bundle;
@synthesize catUI = _catUI;
@synthesize catData = _catData;

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"])
	{
        dispatch_once(&onceToken, ^{
            s_sharedPlugin = [[self alloc] initWithBundle:plugin];
			[s_sharedPlugin update];
			[s_sharedPlugin.catData load];
			
			// 暂时应急
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[s_sharedPlugin.catUI configWithData:s_sharedPlugin.catData];
			});
			
        });
    }
}

+ (instancetype)sharedPlugin
{
    return s_sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init])
	{
        _bundle = plugin;
		_catUI = [[CatUI alloc] init];
		_catData = [[CatData alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)update
{
	NSInteger newVer = 0;
	NSInteger oldVer = 0;
	NSString *oldVerStr = @"";
	NSString *newVerStr = @"";
	NSDictionary *ud = [RFStorageKit defaultsDict];
	NSDictionary *info = [_bundle infoDictionary];
	
	newVerStr = info[@"CFBundleShortVersionString"];
	if (![NSString isEmpty:newVerStr])
	{
		newVer = [RFKit verStrToInt:newVerStr];
	}
	oldVerStr = ud[@"Ver"];
	if (![NSString isEmpty:oldVerStr])
	{
		oldVer = [RFKit verStrToInt:oldVerStr];
	}

	if (oldVer != newVer)
	{
		// 更新
		
	}
	
	[ud setValue:newVerStr forKey:@"Ver"];
	[RFStorageKit saveDefaultsDict:ud];
	
}

@end
