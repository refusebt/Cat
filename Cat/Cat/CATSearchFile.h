//
//  CATSearchFile.h
//  SkyXCodeKit
//
//  Created by g g on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATSearchFile : NSObject
{
	@protected NSString *baseURL;
	@protected NSMutableArray *extensions;
	@protected NSMutableArray *resultArray;
	@protected NSMutableDictionary *resultDict;
	@protected NSFileManager *fileMgr;
}
@property (strong) NSString *baseURL;
@property (readonly) NSMutableArray *extensions;
@property (readonly) NSMutableArray *resultArray;
@property (readonly) NSMutableDictionary *resultDict;

- (void)search;
- (void)setExtensionsString:(NSString*)extensionsString;

@end
