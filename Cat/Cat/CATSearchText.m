//
//  CATSearchText.m
//  SkyXCodeKit
//
//  Created by g g on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CATSearchText.h"

#pragma mark -CATSearchTextResult-

@interface CATSearchTextResult(private)

@end

@implementation CATSearchTextResult
@synthesize filePath;
@synthesize searchText;
@synthesize lineContent;
@synthesize lineNum;
@synthesize rangeInLine;
@synthesize isCommented;


- (NSString*)description
{
	NSMutableString *buf = [NSMutableString string];
	[buf appendFormat:@"\tfile:%@\n", filePath];
	[buf appendFormat:@"\tline number:%ld\n", lineNum];
	[buf appendFormat:@"\tline content:%@\n", lineContent];
	[buf appendFormat:@"\tposition:%ld\n", rangeInLine.location];
	if (isCommented) 
	{
		[buf appendString:@"\tcommented\n"];
	}
	else
	{
		[buf appendString:@"\tuncomment\n"];
	}
	return buf;
}

@end

#pragma mark -CATSearchText-

@interface CATSearchText(private)
- (void)searchContent:(NSString*)aContent;
@end

@implementation CATSearchText
@synthesize results;
@synthesize isUTF8;

- (id)initWithContents:(NSArray*)aContents InFile:(NSString*)aFilePath
{
    self = [super init];
    if (self) 
	{
		filePath = aFilePath;
		contents = aContents;
		results = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithSearchText:(NSString*)aSearchText InFile:(NSString*)aFilePath
{
	self = [super init];
    if (self) 
	{
		filePath = aFilePath;
		contents = [NSArray arrayWithObject:aSearchText];
		results = [[NSMutableArray alloc] init];
    }
    return self;
}


+ (CATSearchText*)searchTextReserved
{
	CATSearchText *ret = [[CATSearchText alloc] init];
	ret->filePath = nil;
	ret->contents = nil;
	ret->results = [[NSMutableArray alloc] init];
	ret->isUTF8 = YES;
	
	// 加入一个结果
	CATSearchTextResult *result = [[CATSearchTextResult alloc] init];
	{
		result.filePath = @"系统保留";
		result.searchText = @"系统保留";
		result.lineContent = @"系统保留";
		result.lineNum = 0;
		result.rangeInLine = NSMakeRange(0, 0);
		result.isCommented = NO;
		[ret->results addObject:result];
	}
	
	return ret;
}

- (void)search;
{
	@autoreleasepool
	{
		if (filePath == nil || contents == nil) 
		{
			return;
		}
		
		// 清空结果
		[results removeAllObjects];
		
		// 读取文件(UTF8 > ASCII)
		NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
		if (fileContent != nil) 
		{
			self.isUTF8 = YES;
			[self searchContent:fileContent];
		}
		else
		{
			NSLog(@"File reade error(UTF8)! (File:%@)", filePath);
			self.isUTF8 = NO;
			
			fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
			if (fileContent != nil) 
			{
				[self searchContent:fileContent];
			}
			else
			{
				NSLog(@"File reade error(ASCII)! (File:%@)", filePath);
			}
		}
	}
}

- (void)searchContent:(NSString*)aContent
{
	@autoreleasepool
	{
		NSArray *lines = [aContent componentsSeparatedByString:@"\n"];
		for (NSInteger i = 0; i < lines.count; i++)
		{
			NSString *line = [lines objectAtIndex:i];
			// 查找
			for (NSString *searchText in contents)
			{
				NSRange range = [line rangeOfString:searchText];
				if (range.location != NSNotFound) 
				{
					CATSearchTextResult *result = [[CATSearchTextResult alloc] init];
					{
						result.filePath = filePath;
						result.searchText = searchText;
						result.lineContent = line;
						result.lineNum = i;
						result.rangeInLine = range;
						
						// 检查是否被注释
						NSRange commentRange = [line rangeOfString:@"//"];
						if (commentRange.location < result.rangeInLine.location	) 
						{
							// 被注视掉了
							result.isCommented = YES;
						}
						else
						{
							result.isCommented = NO;
						}
						
						[results addObject:result];
					}
				}
			}
		}
	}
}

@end
