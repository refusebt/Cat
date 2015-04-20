//
//  CatUI.m
//  Cat
//
//  Created by GZH on 14-10-6.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import "CatUI.h"
#import "CatWindowControllerConfig.h"
//#import "CATWindowControllerImageCheck.h"
#import "CatShortcutsUnit.h"

@interface CatUI ()
{

}
@property (nonatomic, strong) CatData *cataData;

@property (nonatomic, strong) NSMenuItem *miConfig;
@property (nonatomic, strong) NSMenuItem *miAdd;
@property (nonatomic, strong) NSMenuItem *miChange;
@property (nonatomic, strong) NSMenuItem *miDelete;
@property (nonatomic, strong) NSMenuItem *miFind;
@property (nonatomic, strong) NSMenuItem *miFindInWorkspace;
@property (nonatomic, strong) NSMenuItem *miMoveToCodeLeft;
@property (nonatomic, strong) NSMenuItem *miDeleteLine;
//@property (nonatomic, strong) NSMenuItem *miImageCheck;

@property (nonatomic, strong) NSMenuItem *miXCodeFind;
@property (nonatomic, strong) NSMenuItem *miXCodeFindSelection;
@property (nonatomic, strong) NSMenuItem *miXCodeFindInWorkspace;

- (void)performConfig:(id)sender;
- (void)performAdd:(id)sender;
- (void)performChange:(id)sender;
- (void)performDelete:(id)sender;
- (void)performFind:(id)sender;
- (void)performFindInWorkspace:(id)sender;
- (void)performMoveToCodeLeft:(id)sender;
- (void)performDeleteLine:(id)sender;
//- (void)performImageCheck:(id)sender;

- (NSRange)recountSeletectedRange:(NSRange)selectedRange
						InContent:(NSAttributedString*) content
					  WithNewline:(NSString*) newline;

- (NSMenuItem*)findMenuItemWithNames:(NSArray*)names;
- (NSMenuItem*)findMenuItemWithName:(NSString*)name InMenu:(NSMenu*)menu;

- (NSMenuItem*)addMenuItemWithName:(NSString*)name AndSEL:(SEL)sel InMenu:(NSMenu*)menu;

@end

@implementation CatUI

- (void)configWithData:(CatData *)catData
{
	self.cataData = catData;
	
	// Edit
	NSMenu *mEdit = [[[NSApp mainMenu] itemAtIndex:2] submenu];
	
	// 分割
	[mEdit addItem: [NSMenuItem separatorItem]];
	
	// CAT
	NSMenuItem *miCAT= [mEdit addItemWithTitle:MENU_NAME_CAT action:nil keyEquivalent:@""];
	NSMenu *miCATSubMenu = [[NSMenu alloc] init];
	[miCAT setSubmenu:miCATSubMenu];
	
	// Config
	_miConfig = [self addMenuItemWithName:MENU_NAME_CONFIG AndSEL:@selector(performConfig:) InMenu:miCATSubMenu];
	
	// 分割
	[miCATSubMenu addItem: [NSMenuItem separatorItem]];
	
	// Add
	_miAdd = [self addMenuItemWithName:MENU_NAME_ADD_COMMENT AndSEL:@selector(performAdd:) InMenu:miCATSubMenu];
	
	// Change
	_miChange = [self addMenuItemWithName:MENU_NAME_CHANGE_COMMENT AndSEL:@selector(performChange:) InMenu:miCATSubMenu];
	
	// Delete
	_miDelete = [self addMenuItemWithName:MENU_NAME_DELETE_COMMENT AndSEL:@selector(performDelete:) InMenu:miCATSubMenu];
	
	// 分割
	[miCATSubMenu addItem: [NSMenuItem separatorItem]];
	
	// Find(C)
	_miFind = [self addMenuItemWithName:MENU_NAME_Find_C AndSEL:@selector(performFind:) InMenu:miCATSubMenu];
	
	// Find in Workspace(C)
	_miFindInWorkspace = [self addMenuItemWithName:MENU_NAME_Find_IN_WORKSPACE_C AndSEL:@selector(performFindInWorkspace:) InMenu:miCATSubMenu];
	
	// Move to Code Left
	_miMoveToCodeLeft = [self addMenuItemWithName:MENU_NAME_MOVE_TO_CODE_LEFT AndSEL:@selector(performMoveToCodeLeft:) InMenu:miCATSubMenu];
	
	// Delete Line
	_miDeleteLine = [self addMenuItemWithName:MENU_NAME_DELETE_LINE AndSEL:@selector(performDeleteLine:) InMenu:miCATSubMenu];
	
	// 分割
	[miCATSubMenu addItem: [NSMenuItem separatorItem]];
	
//	// 图片检查
//	_miImageCheck = [self addMenuItemWithName:MENU_NAME_IMAGE_CHECK AndSEL:@selector(performImageCheck:) InMenu:miCATSubMenu];
	
	///////////////////////////
	// 获取XCODE菜单项
	///////////////////////////
	
	// Edit->Find->Find…
	_miXCodeFind = [self findMenuItemWithNames:[NSArray arrayWithObjects:@"Find", @"Find…", nil]];
	if (_miXCodeFind == nil)
	{
		_miXCodeFind = [self findMenuItemWithNames:[NSArray arrayWithObjects:@"Edit", @"Find", @"Find…", nil]];
	}
	
	// Edit->Find->Use Selection for Find
	_miXCodeFindSelection = [self findMenuItemWithNames:[NSArray arrayWithObjects:@"Find", @"Use Selection for Find", nil]];
	if (_miXCodeFindSelection == nil)
	{
		_miXCodeFindSelection = [self findMenuItemWithNames:[NSArray arrayWithObjects:@"Edit", @"Find", @"Use Selection for Find", nil]];
	}
	
	// Edit->Find->Find in Workspace…
	_miXCodeFindInWorkspace = [self findMenuItemWithNames:[NSArray arrayWithObjects:@"Find", @"Find in ", nil]];
	if (_miXCodeFindInWorkspace == nil)
	{
		_miXCodeFindInWorkspace = [self findMenuItemWithNames:[NSArray arrayWithObjects:@"Find", @"Find in Workspace…", nil]];
	}
	if (_miXCodeFindInWorkspace == nil)
	{
		_miXCodeFindInWorkspace = [self findMenuItemWithNames:[NSArray arrayWithObjects:@"Edit", @"Find", @"Find in Workspace…", nil]];
	}
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	
	if (anItem == _miConfig
//		|| anItem == _miImageCheck
		)
	{
		return YES;
	}
	
	// 仅代码编辑器可用
	if (anItem == _miAdd
		|| anItem == _miChange
		|| anItem == _miDelete
		|| anItem == _miDeleteLine
		)
	{
		if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
		{
			if ([responder isKindOfClass:NSClassFromString(@"DVTSourceTextView")])
			{
				return YES;
			}
		}
	}
	
	// 文本输入可用
	if (
		anItem == _miFind
		|| anItem == _miFindInWorkspace
		|| anItem == _miMoveToCodeLeft
		)
	{
		if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
		{
			return YES;
		}
	}
	
	return NO;
}


- (void)performConfig:(id)sender
{
	CatWindowControllerConfig *wcConfig = [[CatWindowControllerConfig alloc] initWithWindowNibName:@"CatWindowControllerConfig"];
	if (wcConfig != nil)
	{
		[NSApp runModalForWindow:[wcConfig window]];
	}
}

- (void)performAdd:(id)sender
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
	{
		id client = responder;
		NSRange selectedRange = [client selectedRange];
		NSString *newline = [CatKit getNewlineString: [[client attributedString] string]];
		NSRange reselectedRange = [self recountSeletectedRange:selectedRange InContent:[client attributedString] WithNewline:newline];
		NSString *reselectedText = [[[client attributedString] attributedSubstringFromRange:reselectedRange] string];
		
		// 生成新字串
		NSMutableString *mstr = [[NSMutableString alloc] init];
		[mstr appendString:self.cataData.commentAddStart];
		if (self.cataData.isAppendTime == 1)
			[mstr appendFormat:@" %@", [CatKit getTimeString]];
		[mstr appendString:newline];
		[mstr appendString:reselectedText];
		[mstr appendString:newline];
		[mstr appendString:self.cataData.commentAddEnd];
		if (self.cataData.isAppendTime == 1)
			[mstr appendFormat:@" %@", [CatKit getTimeString]];
		
		// 替换
		[client insertText:mstr replacementRange:reselectedRange];
		[client setSelectedRange:NSMakeRange(reselectedRange.location, mstr.length)];
	}
}

- (void)performChange:(id)sender
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
	{
		id client = responder;
		NSRange selectedRange = [client selectedRange];
		NSString *newline = [CatKit getNewlineString: [[client attributedString] string]];
		NSRange reselectedRange = [self recountSeletectedRange:selectedRange InContent:[client attributedString] WithNewline:newline];
		NSString *reselectedText = [[[client attributedString] attributedSubstringFromRange:reselectedRange] string];
		
		// 生成新字串
		NSMutableString *mstr = [[NSMutableString alloc] init];
		
		[mstr appendString:self.cataData.commentChangeStart];
		if (self.cataData.isAppendTime == 1)
			[mstr appendFormat:@" %@", [CatKit getTimeString]];
		[mstr appendString:newline];
		
		NSArray *textByLine = [reselectedText componentsSeparatedByString:newline];
		for (NSUInteger i = 0; i < textByLine.count; i++)
		{
			[mstr appendString:@"//"];
			[mstr appendString:[textByLine objectAtIndex:i]];
			[mstr appendString:newline];
		}
		
		[mstr appendString:newline];
		[mstr appendString:self.cataData.commentChangeEnd];
		if (self.cataData.isAppendTime == 1)
			[mstr appendFormat:@" %@", [CatKit getTimeString]];
		
		// 替换
		[client insertText:mstr replacementRange:reselectedRange];
		[client setSelectedRange:NSMakeRange(reselectedRange.location, mstr.length)];
	}
}

- (void)performDelete:(id)sender
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
	{
		id client = responder;
		NSRange selectedRange = [client selectedRange];
		NSString *newline = [CatKit getNewlineString: [[client attributedString] string]];
		NSRange reselectedRange = [self recountSeletectedRange:selectedRange InContent:[client attributedString] WithNewline:newline];
		NSString *reselectedText = [[[client attributedString] attributedSubstringFromRange:reselectedRange] string];
		
		// 生成新字串
		NSMutableString *mstr = [[NSMutableString alloc] init];
		
		[mstr appendString:self.cataData.commentDeleteStart];
		if (self.cataData.isAppendTime)
			[mstr appendFormat:@" %@", [CatKit getTimeString]];
		[mstr appendString:newline];
		
		NSArray *textByLine = [reselectedText componentsSeparatedByString:newline];
		for (NSUInteger i = 0; i < textByLine.count; i++)
		{
			[mstr appendString:@"//"];
			[mstr appendString:[textByLine objectAtIndex:i]];
			[mstr appendString:newline];
		}
		
		[mstr appendString:self.cataData.commentDeleteEnd];
		if (self.cataData.isAppendTime)
			[mstr appendFormat:@" %@", [CatKit getTimeString]];
		
		// 替换
		[client insertText:mstr replacementRange:reselectedRange];
		[client setSelectedRange:NSMakeRange(reselectedRange.location, mstr.length)];
	}
}

- (void)performFind:(id)sender
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
	{
		id client = responder;
		
		// Edit->Find->Find…
		if (_miXCodeFind != nil)
		{
			[[NSApplication sharedApplication] sendAction:_miXCodeFind.action to:_miXCodeFind.target from:_miXCodeFind];
		}
		
		// 如选择文字使用选择进行搜索
		// Edit->Find->Use Selection for Find
		if ([client respondsToSelector:@selector(selectedRange)])
		{
			NSRange selectedRange = [client selectedRange];
			if (selectedRange.length > 0)
			{
				if (_miXCodeFindSelection != nil)
				{
					[client tryToPerform:_miXCodeFindSelection.action with:_miXCodeFindSelection];
				}
			}
		}
	}
}

- (void)performFindInWorkspace:(id)sender
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
	{
		id client = responder;
		BOOL ret = NO;
		
		// Edit->Find->Find in Workspace…
		if (_miXCodeFindInWorkspace != nil)
		{
			ret = [[NSApplication sharedApplication] sendAction:_miXCodeFindInWorkspace.action to:_miXCodeFindInWorkspace.target from:_miXCodeFindInWorkspace];
		}
		
		// 如选择文字使用选择进行搜索
		// Edit->Find->Use Selection for Find
		if ([client respondsToSelector:@selector(selectedRange)])
		{
			NSRange selectedRange = [client selectedRange];
			if (selectedRange.length > 0)
			{
				if (_miXCodeFindSelection != nil)
				{
					ret = [client tryToPerform:_miXCodeFindSelection.action with:_miXCodeFindSelection];
				}
			}
		}
	}
}

- (void)performMoveToCodeLeft:(id)sender
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
	{
		if ([responder isKindOfClass:NSClassFromString(@"DVTSourceTextView")])
		{
			// 源码编辑器处理
			id client = responder;
			NSRange selectedRange = [client selectedRange];
			NSString *newline = [CatKit getNewlineString: [[client attributedString] string]];
			NSRange reselectedRange = [self recountSeletectedRange:selectedRange InContent:[client attributedString] WithNewline:newline];
			NSInteger left = reselectedRange.location;
			NSInteger right = selectedRange.location;
			NSRange checkRange = NSMakeRange(left, right - left);
			NSString *checkText = [[[client attributedString] attributedSubstringFromRange:checkRange] string];
			
			// 从左到右寻找
			NSInteger offset = 0;
			for (NSInteger i = 0; i < checkText.length; i++)
			{
				unichar current = [checkText characterAtIndex:i];
				if (current != ' ' && current != '\t')
				{
					offset = i;
					break;
				}
			}
			
			// 修正选择范围
			[client setSelectedRange:NSMakeRange(reselectedRange.location + offset, 0)];
		}
		else if([responder isKindOfClass:NSClassFromString(@"IDEConsoleTextView")])
		{
			// gdb处理
			id client = responder;
			NSRange selectedRange = [client selectedRange];
			NSString *newline = [CatKit getNewlineString: [[client attributedString] string]];
			NSRange reselectedRange = [self recountSeletectedRange:selectedRange InContent:[client attributedString] WithNewline:newline];
			NSString *reselectedText = [[[client attributedString] attributedSubstringFromRange:reselectedRange] string];
			
			// 查找(gdb)
			NSRange gdbRange = [reselectedText rangeOfString:@"(gdb) "];
			if (gdbRange.location == 0 && gdbRange.length == 6)
				[client setSelectedRange:NSMakeRange(reselectedRange.location + 0 + gdbRange.length, 0)];
			else
				[responder moveToBeginningOfLine:sender];
		}
		else
		{
			// 其他的情况回到行首
			[responder moveToBeginningOfLine:sender];
		}
	}
}

- (void)performDeleteLine:(id)sender
{
	NSWindow *nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder = [nsKeyWindow firstResponder];
	if ([responder conformsToProtocol:@protocol(NSTextInputClient)])
	{
		id client = responder;
		NSRange selectedRange = [client selectedRange];
		NSString *newline = [CatKit getNewlineString: [[client attributedString] string]];
		NSRange reselectedRange = [self recountSeletectedRange:selectedRange InContent:[client attributedString] WithNewline:newline];
		
		// 替换
		[client insertText:@"" replacementRange:reselectedRange];
		// 删除空行
		[responder deleteForward:sender];
	}
}

//- (void)performImageCheck:(id)sender
//{
//	CATWindowControllerImageCheck *wcImageCheck = [[CATWindowControllerImageCheck alloc] initWithWindowNibName:@"CATWindowImageCheck"];
//	if (wcImageCheck != nil)
//	{
//		[NSApp runModalForWindow:[wcImageCheck window]];
//	}
//}

- (NSRange)recountSeletectedRange:(NSRange)selectedRange
						InContent:(NSAttributedString*) content
					  WithNewline:(NSString*) newline
{
	NSInteger location = selectedRange.location;	// 需要"--"循环，避免溢出
	NSInteger length = selectedRange.length;
	NSRange ret = NSMakeRange(location, length);
	NSString *text = [content string];
	unichar startNewline = [newline characterAtIndex:0];
	unichar endNewline = [newline characterAtIndex:(newline.length-1)];
	unichar current = 0;
	
	// 前搜索
	while (location > 0)
	{
		location--;
		if (location > 0)
		{
			current = [text characterAtIndex:location];
			if (current == endNewline)
			{
				location++;
				break;
			}
		}
	}
	ret.location = location;
	
	// 后搜索
	location = selectedRange.location + selectedRange.length;	// 苹果的特化，无选取时长度为0而不是1
	while (location < text.length)
	{
		current = [text characterAtIndex:location];
		if (current != startNewline)
		{
			location++;
		}
		else
		{
			break;
		}
	}
	ret.length = location - ret.location;
	
	return ret;
}

- (NSMenuItem*)findMenuItemWithNames:(NSArray*)names
{
	NSMenuItem *ret = nil;
	BOOL isFail = NO;
	
	if ((names != nil) && (names.count > 0))
	{
		// 搜索submenu
		NSMenu *menu = [NSApp mainMenu];
		for (NSInteger i = 0; i < names.count - 1; i++)
		{
			NSString *name = [names objectAtIndex:i];
			if (name != nil)
			{
				NSMenuItem *item = [self findMenuItemWithName:name InMenu:menu];
				if ((item == nil) || (item.submenu == nil))
				{
					// 搜索失败
					isFail = YES;
					break;
				}
				menu = item.submenu;
			}
		}
		
		// 搜索最后一项
		if (!isFail)
		{
			NSString *name = [names objectAtIndex:(names.count - 1)];
			if (name != nil)
			{
				ret = [self findMenuItemWithName:name InMenu:menu];
			}
		}
	}
	
	return ret;
}

- (NSMenuItem*)findMenuItemWithName:(NSString*)name InMenu:(NSMenu*)menu;
{
	NSMenuItem *ret = nil;
	
	if (menu != nil)
	{
		for (NSInteger i = 0; i < menu.itemArray.count; i++)
		{
			NSMenuItem *item = [menu.itemArray objectAtIndex:i];
			if ((item != nil) && (!item.isSeparatorItem))
			{
				if ([item.title hasPrefix:name])
				{
					ret = item;
					break;
				}
			}
		}
	}
	
	return ret;
}

- (NSMenuItem*)addMenuItemWithName:(NSString*)name AndSEL:(SEL)sel InMenu:(NSMenu*)menu
{
	NSMenuItem *ret = nil;
	
	CatShortcutsUnit *unit = [self.cataData.shortcutsDict objectForKey:name];
	if (unit != nil)
	{
		ret = [menu addItemWithTitle:unit.shortcutName action:sel keyEquivalent:@""];
		[ret setTarget:self];
		[ret setKeyEquivalentModifierMask:unit.shortcutKeyModifierMask];
		[ret setKeyEquivalent:unit.shortcutKey];
		
		unit.menuItem = ret;
	}
	
	return ret;
}

@end

//
//// Sample Menu Item:
//NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
//if (menuItem) {
//	[[menuItem submenu] addItem:[NSMenuItem separatorItem]];
//	NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
//	[actionMenuItem setTarget:self];
//	[[menuItem submenu] addItem:actionMenuItem];
//}

//// Sample Action, for menu item:
//- (void)doMenuAction
//{
//	NSAlert *alert = [NSAlert alertWithMessageText:@"Hello, World" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
//	[alert runModal];
//}
