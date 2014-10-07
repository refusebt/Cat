//
//  CatLimitQueue.h
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatLimitQueue : NSObject
{

}
@property (nonatomic, assign) NSInteger maxCount;
@property (atomic, readonly) NSMutableArray *queue;

- (id)init;
- (id)initWithArray:(NSArray *)array;
- (id)dequeue;
- (id)enqueue:(id)obj;
- (void)removeByEqualMethod:(id)obj;

@end
