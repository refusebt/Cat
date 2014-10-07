//
//  CatData.m
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import "CatData.h"
#import "CatShortcutsUnit.h"

@interface CatData ()
- (CatShortcutsUnit *)addShortcutToStore:(NSString *)name Key:(NSString *)key KeyModifierMask:(NSUInteger)mask;
@end

@implementation CatData
@synthesize userDict = _userDict;
@synthesize commentAddStart = _commentAddStart;
@synthesize commentAddEnd = _commentAddEnd;
@synthesize commentChangeStart = _commentChangeStart;
@synthesize commentChangeEnd = _commentChangeEnd;
@synthesize commentDeleteStart = _commentDeleteStart;
@synthesize commentDeleteEnd = _commentDeleteEnd;
@synthesize isAppendTime = _isAppendTime;
@synthesize currentPaths = _currentPaths;
@synthesize shortcutsDict = _shortcutsDict;
@synthesize shortcutsArray = _shortcutsArray;

- (id)init
{
	self = [super init];
	if (self)
	{
		_userDict = nil;
		_commentAddStart = @"";
		_commentAddEnd = @"";
		_commentChangeStart = @"";
		_commentChangeEnd = @"";
		_commentDeleteStart = @"";
		_commentDeleteEnd = @"";
		_isAppendTime = 1;
		_currentPaths = [[CatLimitQueue alloc] init];
		_shortcutsDict = [[NSMutableDictionary alloc] init];
		_shortcutsArray = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)load
{
	_userDict = [RFStorageKit defaultsDict];
	
	// 注释
	[self loadCommentFromDomain:_userDict];
	
	// 最近使用注释文件
	[self loadCurrentPathsFromDomain:_userDict];
	
	// 快捷键
	[self loadShortcutsStoreFromDomain:_userDict];
}

- (void)save
{
	// 注释
	[self saveCommentToDomain:_userDict];
	
	// 最近使用注释文件
	[self saveCurrentPathsToDomain:_userDict];
	
	// 快捷键
	[self saveShortcutsStoreToDomain:_userDict];
	
	[RFStorageKit saveDefaultsDict:_userDict];
}

- (void)loadCommentFromDomain:(NSMutableDictionary *)domain
{
	self.commentAddStart = J2Str([domain objectForKey:@"commentAddStart"]);
	if ([NSString isEmpty:self.commentAddStart])
		self.commentAddStart = @"// AS Debug";
	
	self.commentAddEnd = J2Str([domain objectForKey:@"commentAddEnd"]);
	if ([NSString isEmpty:self.commentAddEnd])
		self.commentAddEnd = @"// AE Debug";
	
	self.commentChangeStart = J2Str([domain objectForKey:@"commentChangeStart"]);
	if ([NSString isEmpty:self.commentChangeStart])
		self.commentChangeStart = @"// CS Debug";
	
	self.commentChangeEnd = J2Str([domain objectForKey:@"commentChangeEnd"]);
	if ([NSString isEmpty:self.commentChangeEnd])
		self.commentChangeEnd = @"// CE Debug";
	
	self.commentDeleteStart = J2Str([domain objectForKey:@"commentDeleteStart"]);
	if ([NSString isEmpty:self.commentDeleteStart])
		self.commentDeleteStart = @"// DS Debug";
	
	self.commentDeleteEnd = J2Str([domain objectForKey:@"commentDeleteEnd"]);
	if ([NSString isEmpty:self.commentDeleteEnd])
		self.commentDeleteEnd = @"// DE Debug";
	
	{
		NSNumber *value = [domain objectForKey:@"isAppendTime"];
		if (value != nil)
		{
			self.isAppendTime = J2Integer([domain objectForKey:@"isAppendTime"]);
		}
		else
		{
			self.isAppendTime = 1;
		}
	}
}

- (void)saveCommentToDomain:(NSMutableDictionary *)domain
{
	[domain setObject:self.commentAddStart forKey:@"commentAddStart"];
	[domain setObject:self.commentAddEnd forKey:@"commentAddEnd"];
	[domain setObject:self.commentChangeStart forKey:@"commentChangeStart"];
	[domain setObject:self.commentChangeEnd forKey:@"commentChangeEnd"];
	[domain setObject:self.commentDeleteStart forKey:@"commentDeleteStart"];
	[domain setObject:self.commentDeleteEnd forKey:@"commentDeleteEnd"];
	[domain setObject:V2NumInteger(self.isAppendTime) forKey:@"isAppendTime"];
}

- (void)loadCurrentPathsFromDomain:(NSMutableDictionary *)domain
{
	NSArray *array = J2Array([domain objectForKey:@"currentPaths"]);
	if (array != nil)
		_currentPaths = [[CatLimitQueue alloc] initWithArray:array];
	else
		_currentPaths = [[CatLimitQueue alloc] init];
}

- (void)saveCurrentPathsToDomain:(NSMutableDictionary *)domain
{
	[domain setObject:_currentPaths.queue forKey:@"currentPaths"];
}

- (void)loadShortcutsStoreFromDomain:(NSMutableDictionary *)domain
{
	// 预设
	{
		// MENU_NAME_CONFIG
		[self addShortcutToStore:MENU_NAME_CONFIG Key:@"" KeyModifierMask:0];
		
		// MENU_NAME_ADD_COMMENT
		[self addShortcutToStore:MENU_NAME_ADD_COMMENT Key:@"A" KeyModifierMask:NSCommandKeyMask];
		
		// MENU_NAME_CHANGE_COMMENT
		[self addShortcutToStore:MENU_NAME_CHANGE_COMMENT Key:@"C" KeyModifierMask:NSCommandKeyMask];
		
		// MENU_NAME_DELETE_COMMENT
		[self addShortcutToStore:MENU_NAME_DELETE_COMMENT Key:@"D" KeyModifierMask:NSCommandKeyMask];
		
		// MENU_NAME_Find_C
		[self addShortcutToStore:MENU_NAME_Find_C Key:@"f" KeyModifierMask:NSCommandKeyMask];
		
		// MENU_NAME_Find_IN_WORKSPACE_C
		[self addShortcutToStore:MENU_NAME_Find_IN_WORKSPACE_C Key:@"F" KeyModifierMask:NSCommandKeyMask];
		
		// MENU_NAME_MOVE_TO_CODE_LEFT
		[self addShortcutToStore:MENU_NAME_MOVE_TO_CODE_LEFT Key:@"↖" KeyModifierMask:0];
		
		// ADD CAT0.1 代码行删除机能追加 GZH -S- 20111231
		// MENU_NAME_DELETE_LINE
		[self addShortcutToStore:MENU_NAME_DELETE_LINE Key:@"" KeyModifierMask:0];
		// ADD CAT0.1 代码行删除机能追加 GZH -E- 20111231
		
		// MENU_NAME_DELETE_LINE
		[self addShortcutToStore:MENU_NAME_IMAGE_CHECK Key:@"" KeyModifierMask:0];
	}
	
	// 用户设置覆盖
	NSArray *store = [domain objectForKey:@"shortcuts"];
	if (store != nil)
	{
		for (NSInteger i = 0; i < store.count; i++)
		{
			NSData *data = [store objectAtIndex:i];
			NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			CatShortcutsUnit *userUnit = [unArchiver decodeObject];
			if (userUnit != nil)
			{
				CatShortcutsUnit *unit = [_shortcutsDict objectForKey:userUnit.shortcutName];
				if (unit != nil)
				{
					unit.shortcutKey = userUnit.shortcutKey;
					unit.shortcutKeyModifierMask = userUnit.shortcutKeyModifierMask;
				}
			}
		}
	}
}

- (void)saveShortcutsStoreToDomain:(NSMutableDictionary *)domain
{
	NSMutableArray *store = [[NSMutableArray alloc] initWithCapacity:_shortcutsArray.count];
	
	for (NSInteger i = 0; i < _shortcutsArray.count; i++)
	{
		CatShortcutsUnit *unit = [_shortcutsArray objectAtIndex:i];
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		
		[archiver encodeObject:unit];
		[archiver finishEncoding];
		[store addObject:data];
	}

	[domain setObject:store forKey:@"shortcuts"];
}

- (CatShortcutsUnit *)addShortcutToStore:(NSString *)name Key:(NSString *)key KeyModifierMask:(NSUInteger)mask
{
	CatShortcutsUnit *unit = [[CatShortcutsUnit alloc] initWithName:name
																Key:key
													KeyModifierMask:mask];
	[_shortcutsDict setObject:unit forKey:unit.shortcutName];
	[_shortcutsArray addObject:unit];
	return unit;
}

@end
