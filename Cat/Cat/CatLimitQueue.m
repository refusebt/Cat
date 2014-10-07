//
//  CatLimitQueue.m
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import "CatLimitQueue.h"

@implementation CatLimitQueue
@synthesize maxCount = _maxCount;
@synthesize queue = _queue;

- (id)init
{
	self = [super init];
	if (self)
	{
		_maxCount = 5;
		_queue = [[NSMutableArray alloc] initWithCapacity:_maxCount];
	}
	return self;
}

- (id)initWithArray:(NSArray *)array
{
	self = [super init];
	if (self)
	{
		_queue = [[NSMutableArray alloc] initWithArray:array];
		_maxCount = MAX(_queue.count, 5);
	}
	return self;
}

- (id)dequeue
{
	@synchronized(self)
	{
		id ret = nil;
		
		if (_queue.count > 0)
		{
			ret = [_queue objectAtIndex:0];
			[_queue removeObjectAtIndex:0];
		}
		
		return ret;
	}
}

- (id)enqueue:(id)obj
{
	@synchronized(self)
	{
		id ret = nil;
		
		if (_maxCount > 0)
		{
			if (_queue.count >= _maxCount)
			{
				ret = [self dequeue];
			}
			
			// 移除同名项
			[self removeByEqualMethod:obj];
			
			[_queue addObject:obj];
		}
		
		return ret;
	}
}

- (void)removeByEqualMethod:(id)obj
{
	@synchronized(self)
	{
		for (NSInteger i = _queue.count-1; i >= 0; i--)
		{
			id origin = [_queue objectAtIndex:i];
			if ([origin isEqual:obj])
			{
				[_queue removeObject:origin];
			}
		}
	}
}

@end
