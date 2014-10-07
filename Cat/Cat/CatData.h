//
//  CatData.h
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatLimitQueue.h"

@interface CatData : NSObject
{
	
}
@property (nonatomic, strong) NSMutableDictionary *userDict;
@property (nonatomic, strong) NSString *commentAddStart;
@property (nonatomic, strong) NSString *commentAddEnd;
@property (nonatomic, strong) NSString *commentChangeStart;
@property (nonatomic, strong) NSString *commentChangeEnd;
@property (nonatomic, strong) NSString *commentDeleteStart;
@property (nonatomic, strong) NSString *commentDeleteEnd;
@property (nonatomic, assign) NSInteger isAppendTime;
@property (nonatomic, strong) CatLimitQueue *currentPaths;
@property (nonatomic, strong) NSMutableDictionary *shortcutsDict;
@property (nonatomic, strong) NSMutableArray *shortcutsArray;

- (void)load;
- (void)save;

- (void)loadCommentFromDomain:(NSMutableDictionary*)domain;
- (void)saveCommentToDomain:(NSMutableDictionary*)domain;

- (void)loadCurrentPathsFromDomain:(NSMutableDictionary*)domain;
- (void)saveCurrentPathsToDomain:(NSMutableDictionary*)domain;

- (void)loadShortcutsStoreFromDomain:(NSMutableDictionary*)domain;
- (void)saveShortcutsStoreToDomain:(NSMutableDictionary*)domain;

@end
