//
//  CatKit.m
//  Cat
//
//  Created by GZH on 14-10-6.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import "CatKit.h"

@implementation CatKit

+ (NSString *)getNewlineString:(NSString *)sample
{
	NSString *ret = @"\n";
	NSString *text = sample;
	
	if ([text rangeOfString:@"\r\n"].length > 0)
	{
		ret = @"\r\n";
	}
	else if ([text rangeOfString:@"\r"].length > 0)
	{
		ret = @"\r";
	}
	
	return ret;
}

+ (NSString *)getTimeString
{
	return [[NSDate date] yyyyMMdd];
}

@end
