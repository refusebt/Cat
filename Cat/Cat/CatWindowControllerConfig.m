//
//  CatWindowControllerConfig.m
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import "CatWindowControllerConfig.h"
#import "Cat.h"
#import "CatShortcutsUnit.h"

#define DEF_SELECT_FILE @"File..."

@interface CatWindowControllerConfig(private)
- (NSString *)getCurrentCommentText;
- (void)resetCurrentPaths;
- (void)resetCurrentShortcuts;
- (void)resetCurrentShortcutsInputStatus:(CatShortcutsUnit *)unit;
- (NSError *)parseCommentFile:(NSString *)filepath;
- (void)parseCommentSettingLine:(NSString *)line ToDictionary:(NSMutableDictionary *) dict;
- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context;
@end

@implementation CatWindowControllerConfig
@synthesize tabs;
@synthesize cbCommentFile;
@synthesize svCurrentComment;
@synthesize chkAppendTime;
@synthesize cbShortcuts;
@synthesize chkShift;
@synthesize chkCtrl;
@synthesize chkCommand;
@synthesize chkAlt;
@synthesize tfKeyEquivalent;

- (void)windowDidLoad
{
	[svCurrentComment.contentView.documentView setString:[self getCurrentCommentText]];
	
	[cbCommentFile setDelegate:self];
	[self resetCurrentPaths];
	[cbCommentFile selectItemAtIndex:0];
	oldCBSeletedItemIndex = cbCommentFile.indexOfSelectedItem;
	
	if ([Cat sharedPlugin].catData.isAppendTime == 1)
		chkAppendTime.state = NSOnState;
	else
		chkAppendTime.state = NSOffState;
	
	[cbShortcuts setDelegate:self];
	[self resetCurrentShortcuts];
	[cbShortcuts selectItemAtIndex:0];
	
	[tabs selectTabViewItemAtIndex:0];
	
	[super windowDidLoad];
}

- (BOOL)windowShouldClose:(id)sender
{
	[[Cat sharedPlugin].catData save];
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp stopModal];
}

- (IBAction)btnSaveAll:(id)sender
{
	[[Cat sharedPlugin].catData save];
}

- (IBAction)btnAppendTime:(id)sender
{
	if (chkAppendTime.state == NSOnState)
		[Cat sharedPlugin].catData.isAppendTime = 1;
	else
		[Cat sharedPlugin].catData.isAppendTime = 0;
}

- (IBAction)btnCommentReadClick:(id)sender
{
	// 获取路径
	NSComboBoxCell *cell = [cbCommentFile objectValueOfSelectedItem];
	if (cell != nil)
	{
		NSString *title = [cell title];
		if (![title isEqualToString:DEF_SELECT_FILE])
		{
			NSError *error = [self parseCommentFile:title];
			if (error == nil)
			{
				// 成功
				[svCurrentComment.contentView.documentView setString:[self getCurrentCommentText]];
				
				// 重设列表顺序
				[[Cat sharedPlugin].catData.currentPaths enqueue:title];
				[self resetCurrentPaths];
				[cbCommentFile selectItemAtIndex:0];
			}
			else
			{
				// 错误
				NSAlert *alert = [NSAlert alertWithError:error];
				[alert runModal];
				
				// 移除选项
				[[Cat sharedPlugin].catData.currentPaths removeByEqualMethod:title];
				
				// 重设列表
				[self resetCurrentPaths];
				[cbCommentFile selectItemAtIndex:0];
			}
		}
	}
}

- (IBAction)btnShortcutsReset:(id)sender
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName: NSComboBoxSelectionDidChangeNotification 
                      object:cbShortcuts
						userInfo:nil];
}

- (IBAction)btnShortcutsConfirm:(id)sender
{
	NSComboBoxCell *cell = [cbShortcuts objectValueOfSelectedItem];
	if (cell != nil)
	{
		NSString *title = [cell title];
		CatShortcutsUnit *unit = [[Cat sharedPlugin].catData.shortcutsDict objectForKey:title];
		if (unit != nil)
		{
			unit.shortcutKey = [tfKeyEquivalent stringValue];
			unit.shortcutKeyModifierMask = 
				(chkShift.state == NSOnState ? NSShiftKeyMask:0) | 
				(chkCtrl.state == NSOnState ? NSControlKeyMask:0) | 
				(chkCommand.state == NSOnState ? NSCommandKeyMask:0) | 
				(chkAlt.state == NSOnState ? NSAlternateKeyMask:0)
			;
			
			[unit.menuItem setKeyEquivalentModifierMask:unit.shortcutKeyModifierMask];
			[unit.menuItem setKeyEquivalent:unit.shortcutKey];
		}
	}
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	if (cbCommentFile == notification.object)
	{
		NSComboBoxCell *cell = [cbCommentFile objectValueOfSelectedItem];
		if (cell != nil)
		{
			NSString *title = [cell title];
			if ([title isEqualToString:DEF_SELECT_FILE])
			{
				// 打开文件菜单
				NSOpenPanel *panel = [NSOpenPanel openPanel];
				[panel setCanChooseFiles: YES];
				[panel setCanChooseDirectories:NO];
				[panel setAllowsMultipleSelection:NO];
				[panel setDirectoryURL:nil];
				[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"ini", @"txt", nil]]; // 文件类型
				[panel beginSheetModalForWindow:self.window completionHandler:
				 ^(NSInteger returnCode){
					 [self openPanelDidEnd:panel returnCode:returnCode contextInfo:nil];
				}];
			}
			else
			{
				oldCBSeletedItemIndex = cbCommentFile.indexOfSelectedItem;
			}
		}
	}
	else if (cbShortcuts == notification.object)
	{
		NSComboBoxCell *cell = [cbShortcuts objectValueOfSelectedItem];
		if (cell != nil)
		{
			NSString *title = [cell title];
			CatShortcutsUnit *unit = [[Cat sharedPlugin].catData.shortcutsDict objectForKey:title];
			if (unit != nil)
			{
				[self resetCurrentShortcutsInputStatus:unit];
			}
		}
	}
}

- (void)openPanelDidEnd:(NSOpenPanel*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)context;
{
    if (returnCode == NSFileHandlingPanelOKButton)
	{
        NSArray *fileNameUrls = [sheet URLs];
		NSURL *fileUrl = [fileNameUrls objectAtIndex:0];
		NSString *fileName = [fileUrl path];
		[[Cat sharedPlugin].catData.currentPaths enqueue:fileName];
		[self resetCurrentPaths];
		[cbCommentFile selectItemAtIndex:0];
    }
	else
	{
		[cbCommentFile selectItemAtIndex:oldCBSeletedItemIndex];
	}
}

#pragma mark -私有方法-

- (NSString*)getCurrentCommentText
{
	NSMutableString *mstr = [[NSMutableString alloc] init];
	
	[mstr appendFormat:@"AS=%@\r\n", [Cat sharedPlugin].catData.commentAddStart];
	[mstr appendFormat:@"AE=%@\r\n", [Cat sharedPlugin].catData.commentAddEnd];
	[mstr appendFormat:@"CS=%@\r\n", [Cat sharedPlugin].catData.commentChangeStart];
	[mstr appendFormat:@"CE=%@\r\n", [Cat sharedPlugin].catData.commentChangeEnd];
	[mstr appendFormat:@"DS=%@\r\n", [Cat sharedPlugin].catData.commentDeleteStart];
	[mstr appendFormat:@"DE=%@\r\n", [Cat sharedPlugin].catData.commentDeleteEnd];

	return mstr;
}

- (void)resetCurrentPaths
{
	// 清空
	[cbCommentFile removeAllItems];
	
	// 最近使用
	NSArray *array = [[Cat sharedPlugin].catData.currentPaths queue];
	for (NSInteger i = array.count - 1; i >= 0; i--)
	{
		NSString *title = [array objectAtIndex:i];
		if (title != nil)
		{
			NSComboBoxCell *cell = [[NSComboBoxCell alloc] initTextCell:title];
			[cbCommentFile addItemWithObjectValue:cell];
		}
	}
	
	// 文件
	NSComboBoxCell *cell = [[NSComboBoxCell alloc] initTextCell:DEF_SELECT_FILE];
	[cbCommentFile addItemWithObjectValue:cell];
	
	[cbCommentFile reloadData];
}

- (void)resetCurrentShortcuts
{
	// 清空
	[cbShortcuts removeAllItems];
	
	// 最近使用
	NSArray *array = [Cat sharedPlugin].catData.shortcutsArray;
	for (NSInteger i = 0; i < array.count; i++)
	{
		CatShortcutsUnit *unit = [array objectAtIndex:i];
		if (unit != nil)
		{
			NSComboBoxCell *cell = [[NSComboBoxCell alloc] initTextCell:unit.shortcutName];
			[cbShortcuts addItemWithObjectValue:cell];
		}
	}
	
	[cbShortcuts reloadData];
}

- (void)resetCurrentShortcutsInputStatus:(CatShortcutsUnit *)unit
{
	[tfKeyEquivalent setStringValue:unit.shortcutKey];
	
	if (unit.shortcutKeyModifierMask & NSShiftKeyMask)
		[chkShift setState:NSOnState];
	else
		[chkShift setState:NSOffState];
	
	if (unit.shortcutKeyModifierMask & NSControlKeyMask)
		[chkCtrl setState:NSOnState];
	else
		[chkCtrl setState:NSOffState];
	
	if (unit.shortcutKeyModifierMask & NSCommandKeyMask)
		[chkCommand setState:NSOnState];
	else
		[chkCommand setState:NSOffState];
	
	if (unit.shortcutKeyModifierMask & NSAlternateKeyMask)
		[chkAlt setState:NSOnState];
	else
		[chkAlt setState:NSOffState];
}

- (NSError*)parseCommentFile:(NSString*)filepath
{
	NSError *error = nil;
	NSString *content = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
	
	if ((content != nil) && (error == nil))
	{
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		NSString *newline = [CatKit getNewlineString:content];
		
		// 行分解
		NSArray *lines = [content componentsSeparatedByString:newline];
		for (NSUInteger i = 0; i < lines.count; i++)
		{
			[self parseCommentSettingLine:[lines objectAtIndex:i] ToDictionary:dict];
		}
		
		// 提取
		NSString *as = [dict objectForKey:INIKEY_COMMENT_AS];
		NSString *ae = [dict objectForKey:INIKEY_COMMENT_AE];
		NSString *cs = [dict objectForKey:INIKEY_COMMENT_CS];
		NSString *ce = [dict objectForKey:INIKEY_COMMENT_CE];
		NSString *ds = [dict objectForKey:INIKEY_COMMENT_DS];
		NSString *de = [dict objectForKey:INIKEY_COMMENT_DE];
		
		if (as == nil || ae == nil || cs == nil || ce == nil || ds == nil || de == nil)
		{
			NSDictionary *userinfo = [NSDictionary dictionaryWithObject:@"Invalid File Format." forKey:NSLocalizedDescriptionKey];
			error = [NSError errorWithDomain:@"CAT" code:9001 userInfo:userinfo];
		}
		else
		{
			[Cat sharedPlugin].catData.commentAddStart = as;
			[Cat sharedPlugin].catData.commentAddEnd = ae;
			[Cat sharedPlugin].catData.commentChangeStart = cs;
			[Cat sharedPlugin].catData.commentChangeEnd = ce;
			[Cat sharedPlugin].catData.commentDeleteStart = ds;
			[Cat sharedPlugin].catData.commentDeleteEnd = de;
		}
	}
	
	return error;
}

- (void)parseCommentSettingLine:(NSString*)line ToDictionary:(NSMutableDictionary*) dict
{
	NSArray *sections = [line componentsSeparatedByString:@"="];
	if (sections.count == 2)
	{
		[dict setObject:[sections objectAtIndex:1] forKey:[sections objectAtIndex:0]];
	}
}

@end
