//
//  CATMainViewController.m
//  SkyXCodeKit
//
//  Created by g g on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CATWindowControllerImageCheck.h"
#import "CATSearchFile.h"
#import "CATSearchText.h"

#define kMoveToDir			@"!DeleteImage"
#define kMoveToUnusedDir	@"Unused"
#define kMoveToCommented	@"Commented"

#define OUT_MSG(...) \
	([self outMessage:[NSString stringWithFormat:__VA_ARGS__]])

#pragma mark -CATSearchImageResult-

@interface CATSearchImageResult(private)

@end

@implementation CATSearchImageResult
@synthesize filePath;
@synthesize fileName;
@synthesize used;
@synthesize commented;


- (NSString*)description
{
	NSMutableString *buf = [NSMutableString string];
	[buf appendFormat:@"image：%@\n", fileName];
	[buf appendFormat:@"image path：%@\n", filePath];
	[buf appendFormat:@"used：\n%@\n", [used description]];
	[buf appendFormat:@"comment：\n%@\n", [commented description]];
	[buf appendString:@"-"];
	return buf;
}

@end

#pragma mark -CATWindowControllerImageCheck-

@interface CATWindowControllerImageCheck(private)
- (void)showFuncionUIImageCheck;
- (void)outMessage:(NSString*)message;
- (void)initReservedImages;

- (void)processImageCheck;
- (void)processSearchImage;
- (void)processSearchFile;
- (void)processSearchImageInFiles;
- (NSString*)imageCheckResult;
@end

@implementation CATWindowControllerImageCheck
@synthesize images;
@synthesize files;
@synthesize unusedImages;
@synthesize usedImages;
@synthesize commentedImages;
@synthesize reservedImages;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) 
	{
		
    }
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
	
	[self showFuncionUIImageCheck];
}

- (BOOL)windowShouldClose:(id)sender
{
	bShoudStop = YES;
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp stopModal];
}


- (void)showFuncionUIImageCheck
{
	[btnImageCheck setEnabled:YES];
	[btnDeleteUnused setEnabled:NO];
	[btnDeleteCommented setEnabled:NO];
	
//	[textFieldProjectDir setStringValue:@"/Users/gzh/Documents/Workspace/SkyArtist1.3_Public"];
//	[textFieldImageDir setStringValue:@"/Users/gzh/Documents/Workspace/SkyArtist1.3_Public/replace"];
	[textFieldFileExtension setStringValue:@"h,m,mm,xib,nib,plist,c,cpp"];
	[textFieldImageExtension setStringValue:@"png,jpg,gif,bmp"];
	[textFieldReservedImage setStringValue:@"icon.png,Default.png"];
//	[textFieldImageMoveTo setStringValue:@"/Users/gzh/Documents"];
}

- (void)outMessage:(NSString*)message
{
	@synchronized(self)
	{
		NSLog(@"%@", message);
		[textViewStatus performSelectorOnMainThread:@selector(insertText:) withObject:message waitUntilDone:YES];
		[textViewStatus performSelectorOnMainThread:@selector(insertText:) withObject:@"\n" waitUntilDone:YES];
	}
}

- (void)initReservedImages
{
	NSString *value = [textFieldReservedImage stringValue];
	if ((value != nil) && (value.length > 0)) 
	{
		NSArray *array = [value componentsSeparatedByString:@","];
		for (__strong NSString *reservedImg in array)
		{
			reservedImg = [reservedImg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if (reservedImg.length > 0) 
			{
				[reservedImages addObject:reservedImg];
			}
		}
	}
}

- (IBAction)btnImageCheck_Click:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(processImageCheck) toTarget:self withObject:nil];
	[btnImageCheck setEnabled:NO];
}

- (IBAction)btnDeleteUnused_Click:(id)sender
{
	NSString *movePath = [NSString stringWithFormat:@"%@/%@/%@", [textFieldImageMoveTo stringValue], kMoveToDir, kMoveToUnusedDir];
	NSAlert *alert = [NSAlert alertWithMessageText:@"Move Unused Image?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
	NSInteger ret = [alert runModal];
	if (ret > 0) 
	{
		OUT_MSG(@"移动未使用图片 -S-");
		
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		
		// 创建文件夹
		if (![fileMgr fileExistsAtPath:movePath]) 
		{
			[fileMgr createDirectoryAtPath:movePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		OUT_MSG(@"移动文件至:%@", movePath);
		
		for (NSString *key in unusedImages)
		{
			CATSearchImageResult *result = [unusedImages objectForKey:key];
			if ([fileMgr fileExistsAtPath:result.filePath]) 
			{
				OUT_MSG(@"移动文件(%@)", result.filePath);
				
				[fileMgr moveItemAtPath:result.filePath toPath:[NSString stringWithFormat:@"%@/%@", movePath, result.fileName] error:nil];
			}
			// 移除2X文件
			{
				NSArray *array = [result.fileName componentsSeparatedByString:@"."];
				if (array.count == 2) 
				{
					NSString *fileName2x = [NSString stringWithFormat:@"%@@2x.%@", [array objectAtIndex:0], [array objectAtIndex:1]];
					NSString *filePath2x = [result.filePath stringByReplacingOccurrencesOfString:result.fileName withString:fileName2x];
					if ([fileMgr fileExistsAtPath:filePath2x]) 
					{
						OUT_MSG(@"移动文件(%@)", filePath2x);
						[fileMgr moveItemAtPath:filePath2x toPath:[NSString stringWithFormat:@"%@/%@", movePath, fileName2x] error:nil];
					}
				}
			}
		}
		
		OUT_MSG(@"移动未使用图片 -E-");
	}
}

- (IBAction)btnDeleteCommented_Click:(id)sender
{
	NSString *movePath = [NSString stringWithFormat:@"%@/%@/%@", [textFieldImageMoveTo stringValue], kMoveToDir, kMoveToCommented];
	NSAlert *alert = [NSAlert alertWithMessageText:@"Move Commented Image?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
	NSInteger ret = [alert runModal];
	if (ret > 0) 
	{
		OUT_MSG(@"移动被注释图片 -S-");
		
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		
		// 创建文件夹
		if (![fileMgr fileExistsAtPath:movePath]) 
		{
			[fileMgr createDirectoryAtPath:movePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		OUT_MSG(@"移动文件至:%@", movePath);
		
		for (NSString *key in commentedImages)
		{
			CATSearchImageResult *result = [commentedImages objectForKey:key];
			if ([fileMgr fileExistsAtPath:result.filePath]) 
			{
				OUT_MSG(@"移动文件(%@)", result.filePath);
				
				[fileMgr moveItemAtPath:result.filePath toPath:[NSString stringWithFormat:@"%@/%@", movePath, result.fileName] error:nil];
			}
			// 移除2X文件
			{
				NSArray *array = [result.fileName componentsSeparatedByString:@"."];
				if (array.count == 2) 
				{
					NSString *fileName2x = [NSString stringWithFormat:@"%@@2x.%@", [array objectAtIndex:0], [array objectAtIndex:1]];
					NSString *filePath2x = [result.filePath stringByReplacingOccurrencesOfString:result.fileName withString:fileName2x];
					if ([fileMgr fileExistsAtPath:filePath2x]) 
					{
						OUT_MSG(@"移动文件(%@)", filePath2x);
						[fileMgr moveItemAtPath:filePath2x toPath:[NSString stringWithFormat:@"%@/%@", movePath, fileName2x] error:nil];
					}
				}
			}
		}
		
		OUT_MSG(@"移动被注释图片 -E-");
	}
}

- (void)processImageCheck
{
	@autoreleasepool
	{
		OUT_MSG(@"图片检查开始 -S-");
		
		// 初始化
		[btnDeleteUnused setEnabled:NO];
		[btnDeleteCommented setEnabled:NO];
		bShoudStop = NO;
		
		self.images = [NSMutableDictionary dictionary];
		self.files = [NSMutableDictionary dictionary];
		self.unusedImages = [NSMutableDictionary dictionary];
		self.usedImages = [NSMutableDictionary dictionary];
		self.commentedImages = [NSMutableDictionary dictionary];
		self.reservedImages = [NSMutableArray array];
		[self initReservedImages];
		
		// 处理
		[self processSearchImage];
		OUT_MSG(@"发现图片数%lu", images.count);
		[self processSearchFile];
		OUT_MSG(@"发现文件数%lu", files.count);
		OUT_MSG(@"开始检索...");
		[self processSearchImageInFiles];
		
		// 输出结果
		OUT_MSG(@"-----------------------------------------------------------");
		OUT_MSG(@"结果输出");
		OUT_MSG(@"%@", [self imageCheckResult]);
		OUT_MSG(@"-----------------------------------------------------------");
		
		OUT_MSG(@"图片检查结束 -E-");
		
		[btnImageCheck setEnabled:YES];
		[btnDeleteUnused setEnabled:YES];
		[btnDeleteCommented setEnabled:YES];
	}
}

- (void)processSearchImage
{
	if (bShoudStop) return;
	
	@autoreleasepool
	{
		CATSearchFile *sf = [[CATSearchFile alloc] init];
		sf.baseURL = textFieldImageDir.stringValue;
		[sf setExtensionsString:textFieldImageExtension.stringValue];
		[sf search];
		self.images = sf.resultDict;
	}
}

- (void)processSearchFile
{
	if (bShoudStop) return;
	
	@autoreleasepool
	{
		CATSearchFile *sf = [[CATSearchFile alloc] init];
		sf.baseURL = textFieldProjectDir.stringValue;
		[sf setExtensionsString:textFieldFileExtension.stringValue];
		[sf search];
		self.files = sf.resultDict;
	}
}

- (void)processSearchImageInFiles
{
	if (bShoudStop) return;
	
	NSInteger i = 1;
	for (NSString *imgPath in images)
	{
		if (bShoudStop) return;
		
		@autoreleasepool
		{
			OUT_MSG(@"正在查找图片(%ld/%ld): %@", i++, images.count, imgPath);
			
			// @2x. 不搜索
			NSRange range2X = [imgPath rangeOfString:@"@2x." options:NSCaseInsensitiveSearch];
			if (range2X.location != NSNotFound) 
			{
				OUT_MSG(@"2X图片，跳过");
				continue;
			}
			
// gzh debug
//			if (unusedImages.count > 2 && commentedImages.count > 2 && usedImages.count > 2) 
//			{
//				return;
//			}
			
			NSMutableDictionary *used = [NSMutableDictionary dictionary];
			NSMutableDictionary *commented = [NSMutableDictionary dictionary];
			NSString *imgFile = [images objectForKey:imgPath];
			
			for (NSString *filePath in files)
			{
				if (bShoudStop) return;
				
				CATSearchText *st = [[CATSearchText alloc] initWithSearchText:imgFile InFile:filePath];
				{
					[st search];
					
					// 检查是否是UTF8文件
					NSURL *fileURL = [NSURL fileURLWithPath:filePath];
					if (
						!st.isUTF8 &&
						![fileURL.pathExtension isCaseInsensitiveLike:@"nib"] &&
						![fileURL.pathExtension isCaseInsensitiveLike:@"plist"]
						) 
					{
						OUT_MSG(@"警告:不是UTF8文件。 (%@)", filePath);
					}
					
					if (st.results.count > 0) 
					{
						// 发现
						[used setValue:st forKey:filePath];
						
						// 检查是否图片在该文件中都被注释
						{
							NSInteger usedCount = 0;
							for (CATSearchTextResult *result in st.results)
							{
								if (bShoudStop) return;
								
								if (!result.isCommented) 
								{
									// 标记使用
									usedCount++;
								}
							}
							if (usedCount == 0) 
							{
								[commented setValue:st forKey:filePath];
							}
						}
					}
					else
					{
						// 未发现
					}
				}
			}
			
			// 生成一条结果
			OUT_MSG(@"此图片查找完成: (%@)", imgPath);
			
			CATSearchImageResult *result = [[CATSearchImageResult alloc] init];
			{
				// 处理保留图片(有大小写敏感，不能用字典)
				for (NSString *reservedImg in reservedImages)
				{
					if ([imgFile isCaseInsensitiveLike:reservedImg]) 
					{
						[used setValue:[CATSearchText searchTextReserved] forKey:@"系统保留"];
					}
				}
				
				result.filePath = imgPath;
				result.fileName = imgFile;
				result.used = used;
				result.commented = commented;
				
				if (used.count > 0) 
				{
					OUT_MSG(@"图片出现数: (%lu)", used.count);
					OUT_MSG(@"图片被注释数: (%lu)", commented.count);
					if (used.count == commented.count) 
					{
						// 完全被注释
						OUT_MSG(@"图片完全被注释");
						[commentedImages setValue:result forKey:imgPath];
					}
					else
					{
						[usedImages setValue:result forKey:imgPath];
					}
				}
				else
				{
					OUT_MSG(@"图片未被使用");
					[unusedImages setValue:result forKey:imgPath];
				}
			}
		}
	}
}

- (NSString*)imageCheckResult
{
	NSMutableString *buf = [NSMutableString string];
	
	[buf appendFormat:@"---------输出汇总---------\n"];
	[buf appendFormat:@"未使用图片：\n"];
	for (NSString *key in unusedImages)
	{
		CATSearchImageResult *result = [unusedImages objectForKey:key];
		[buf appendFormat:@"%@\n", result.filePath];
	}
	[buf appendFormat:@"被注释图片：\n"];
	for (NSString *key in commentedImages)
	{
		CATSearchImageResult *result = [commentedImages objectForKey:key];
		[buf appendFormat:@"%@\n", result.filePath];
	}
	[buf appendFormat:@"被使用图片：\n"];
	for (NSString *key in usedImages)
	{
		CATSearchImageResult *result = [usedImages objectForKey:key];
		[buf appendFormat:@"%@\n", result.filePath];
	}
	
	[buf appendFormat:@"---------输出明细---------\n"];
	[buf appendFormat:@"被注释图片：\n"];
	for (NSString *key in commentedImages)
	{
		CATSearchImageResult *result = [commentedImages objectForKey:key];
		
		[buf appendFormat:@"\t图片路径：%@\n", result.filePath];
		for (NSString *textKey in result.used)
		{
			CATSearchText *st = [result.used objectForKey:textKey];
			for (CATSearchTextResult *textResult in st.results)
			{
				[buf appendFormat:@"\t\t文件：%@\n", textResult.filePath];
				[buf appendFormat:@"\t\t行号：%ld\n", textResult.lineNum];
				[buf appendFormat:@"\t\t行：%@\n", textResult.lineContent];
				[buf appendFormat:@"\t\t位置：%ld\n", textResult.rangeInLine.location];
				if (textResult.isCommented) 
				{
					[buf appendFormat:@"\t\t被注释\n"];
				}
				else
				{
					[buf appendFormat:@"\t\t未被注释\n"];
				}
				[buf appendFormat:@"\t\t--\n"];
			}
		}
		[buf appendFormat:@"\t--\n"];
	}
	[buf appendFormat:@"被使用图片：\n"];
	for (NSString *key in usedImages)
	{
		CATSearchImageResult *result = [usedImages objectForKey:key];
		[buf appendFormat:@"\t图片路径：%@\n", result.filePath];
		for (NSString *textKey in result.used)
		{
			CATSearchText *st = [result.used objectForKey:textKey];
			for (CATSearchTextResult *textResult in st.results)
			{
				[buf appendFormat:@"\t\t文件：%@\n", textResult.filePath];
				[buf appendFormat:@"\t\t行号：%ld\n", textResult.lineNum];
				[buf appendFormat:@"\t\t行：%@\n", textResult.lineContent];
				[buf appendFormat:@"\t\t位置：%ld\n", textResult.rangeInLine.location];
				if (textResult.isCommented) 
				{
					[buf appendFormat:@"\t\t被注释\n"];
				}
				else
				{
					[buf appendFormat:@"\t\t未被注释\n"];
				}
				[buf appendFormat:@"\t\t--\n"];
			}
		}
		[buf appendFormat:@"\t--\n"];
	}
	
	return buf;
}

@end
