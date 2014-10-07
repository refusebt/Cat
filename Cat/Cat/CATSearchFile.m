//
//  CATSearchFile.m
//  SkyXCodeKit
//
//  Created by g g on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CATSearchFile.h"

@interface CATSearchFile(private)
- (void)search:(NSString*)currentURL;
- (BOOL)fitExtensions:(NSString*)path;
@end

@implementation CATSearchFile
@synthesize extensions;
@synthesize resultArray;
@synthesize resultDict;
@synthesize baseURL;

- (id)init
{
    self = [super init];
    if (self) 
	{
		extensions = [[NSMutableArray alloc] init];
		resultArray = [[NSMutableArray alloc] init];
		resultDict = [[NSMutableDictionary alloc] init];
		fileMgr = [NSFileManager defaultManager];
    }
    return self;
}


- (void)search
{
	[resultArray removeAllObjects];
	[resultDict removeAllObjects];
	if ((baseURL != nil) && ![baseURL isEqualToString:@""]) 
	{
		[self search:baseURL];
	}
}

- (void)search:(NSString*)currentURL
{
	NSArray *ret = [fileMgr contentsOfDirectoryAtURL:[NSURL fileURLWithPath:currentURL] 
						  includingPropertiesForKeys:nil
											 options:NSDirectoryEnumerationSkipsHiddenFiles 
											   error:nil];
	if (ret != nil) 
	{
		for (NSURL *url in ret)
		{
			NSString *path = url.path;
			BOOL isDirectory = YES;
			[fileMgr fileExistsAtPath:path isDirectory:&isDirectory];
			if (isDirectory) 
			{
				[self search:path];
			}
			else
			{
				if ([self fitExtensions:path]) 
				{
					[resultArray addObject:path];
					NSString *file = [[url pathComponents] lastObject];
					[resultDict setObject:file forKey:path];
				}
			}
		}
	}

}

- (BOOL)fitExtensions:(NSString*)path
{
	if (path != nil) 
	{
		if (extensions.count == 0) 
		{
			return YES;
		}
		else
		{
			NSURL *url = [NSURL fileURLWithPath:path];
			NSString *ext = url.pathExtension;
			for (NSString *select in extensions)
			{
				if ([select isCaseInsensitiveLike:ext]) 
				{
					return YES;
				}
			}
		}
	}
	return NO;
}

- (void)setExtensionsString:(NSString*)extensionsString
{
	if ((extensionsString != nil) && (extensionsString.length > 0)) 
	{
		NSArray *array = [extensionsString componentsSeparatedByString:@","];
		for (__strong NSString *ext in array)
		{
			ext = [ext stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if (ext.length > 0) 
			{
				[extensions addObject:ext];
			}
		}
	}
}

@end
