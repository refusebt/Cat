//
//  CATSearchText.h
//  SkyXCodeKit
//
//  Created by g g on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATSearchTextResult : NSObject
{
	@protected NSString *filePath;
	@protected NSString *searchText;
	@protected NSString *lineContent;
	@protected NSInteger lineNum;
	@protected NSRange rangeInLine;
	@protected BOOL isCommented;
}
@property (strong) NSString *filePath;
@property (strong) NSString *searchText;
@property (strong) NSString *lineContent;
@property (assign) NSInteger lineNum;
@property (assign) NSRange rangeInLine;
@property (assign) BOOL isCommented;
@end

@interface CATSearchText : NSObject
{
	@protected NSString *filePath;
	@protected NSArray *contents;
	@protected NSMutableArray *results;
	@protected BOOL isUTF8;
}
@property (readonly) NSMutableArray *results;
@property (assign) BOOL isUTF8;

- (id)initWithContents:(NSArray*)aContents InFile:(NSString*)aFilePath;
- (id)initWithSearchText:(NSString*)aSearchText InFile:(NSString*)aFilePath;

- (void)search;

+ (CATSearchText*)searchTextReserved;	// 系统保留

@end
