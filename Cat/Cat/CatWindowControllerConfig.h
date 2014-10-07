//
//  CatWindowControllerConfig.h
//  Cat
//
//  Created by GZH on 14-10-7.
//  Copyright (c) 2014年 RefuseBT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatWindowControllerConfig : NSWindowController
<
	NSWindowDelegate,
	NSComboBoxDelegate
>
{
	// TabView
	@protected IBOutlet NSTabView *tabs;
	
	// Comment
	@protected IBOutlet NSComboBox *cbCommentFile;
	@protected IBOutlet NSScrollView *svCurrentComment;
	@protected IBOutlet NSButton *chkAppendTime;
	
	// Shortcuts
	@protected IBOutlet NSComboBox *cbShortcuts;
	@protected IBOutlet NSButton *chkShift;
	@protected IBOutlet NSButton *chkCtrl;
	@protected IBOutlet NSButton *chkCommand;
	@protected IBOutlet NSButton *chkAlt;
	@protected IBOutlet NSTextField *tfKeyEquivalent;
	
	@protected NSInteger oldCBSeletedItemIndex;
}
@property (strong) NSTabView *tabs;
@property (strong) NSComboBox *cbCommentFile;
@property (strong) NSScrollView *svCurrentComment;
@property (strong) NSButton *chkAppendTime;
@property (strong) NSComboBox *cbShortcuts;
@property (strong) NSButton *chkShift;
@property (strong) NSButton *chkCtrl;
@property (strong) NSButton *chkCommand;
@property (strong) NSButton *chkAlt;
@property (strong) NSTextField *tfKeyEquivalent;

- (BOOL)windowShouldClose:(id)sender;
- (void)windowWillClose:(NSNotification *)notification;

- (IBAction)btnSaveAll:(id)sender;
- (IBAction)btnCommentReadClick:(id)sender;
- (IBAction)btnAppendTime:(id)sender;
- (IBAction)btnShortcutsReset:(id)sender;
- (IBAction)btnShortcutsConfirm:(id)sender;

- (void)comboBoxSelectionDidChange:(NSNotification *)notification;


@end
