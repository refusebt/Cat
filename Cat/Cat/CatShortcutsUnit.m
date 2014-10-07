//
//  CatShortcutsUnit.m
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import "CatShortcutsUnit.h"

@implementation CatShortcutsUnit
@synthesize shortcutName;
@synthesize shortcutKey;
@synthesize shortcutKeyModifierMask;
@synthesize menuItem;

- (id)initWithName:(NSString*)name Key:(NSString*)key KeyModifierMask:(NSUInteger)mask
{
	self = [super init];
	if (self)
	{
		self.shortcutName = name;
		self.shortcutKey = key;
		self.shortcutKeyModifierMask = mask;
		self.menuItem = nil;
	}
	return self;
}


- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:shortcutName forKey:@"shortcutName"];
	[coder encodeObject:shortcutKey forKey:@"shortcutKey"];
	[coder encodeInteger:shortcutKeyModifierMask forKey:@"shortcutKeyModifierMask"];
	// menuItem
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if (self = [super init])
	{
		if (decoder == nil)
		{
			return self;
		}
		
		self.shortcutName = [decoder decodeObjectForKey:@"shortcutName"];
		self.shortcutKey = [decoder decodeObjectForKey:@"shortcutKey"];
		self.shortcutKeyModifierMask = [decoder decodeIntegerForKey:@"shortcutKeyModifierMask"];
		self.menuItem = nil;
	}
	return self;
}

@end
