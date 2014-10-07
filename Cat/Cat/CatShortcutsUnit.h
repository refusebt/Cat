//
//  CatShortcutsUnit.h
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatShortcutsUnit : NSObject <NSCoding>
{
	
}
@property (strong, nonatomic) NSString *shortcutName;
@property (strong, nonatomic) NSString *shortcutKey;
@property (assign, nonatomic) NSUInteger shortcutKeyModifierMask;
@property (strong, nonatomic) NSMenuItem *menuItem;

- (id)initWithName:(NSString*)name Key:(NSString*)key KeyModifierMask:(NSUInteger)mask;

@end
