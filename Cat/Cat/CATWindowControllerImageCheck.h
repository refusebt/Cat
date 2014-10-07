//
//  CATMainViewController.h
//  SkyXCodeKit
//
//  Created by g g on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CATSearchImageResult : NSObject
{
	@protected NSString *filePath;
	@protected NSString *fileName;
	@protected NSMutableDictionary *used;
	@protected NSMutableDictionary *commented;
}
@property (strong) NSString *filePath;
@property (strong) NSString *fileName;
@property (strong) NSMutableDictionary *used;
@property (strong) NSMutableDictionary *commented;
@end

@interface CATWindowControllerImageCheck : NSWindowController
<
NSWindowDelegate
>
{
	@protected IBOutlet NSTextField *textFieldProjectDir;
	@protected IBOutlet NSTextField *textFieldImageDir;
	@protected IBOutlet NSTextField *textFieldFileExtension;
	@protected IBOutlet NSTextField *textFieldImageExtension;
	@protected IBOutlet NSTextField *textFieldReservedImage;
	@protected IBOutlet NSTextField *textFieldImageMoveTo;
	@protected IBOutlet NSButton *btnImageCheck;
	@protected IBOutlet NSButton *btnDeleteUnused;
	@protected IBOutlet NSButton *btnDeleteCommented;
	
	@protected NSMutableDictionary *images;
	@protected NSMutableDictionary *files;
	@protected NSMutableDictionary *unusedImages;
	@protected NSMutableDictionary *usedImages;
	@protected NSMutableDictionary *commentedImages;
	@protected NSMutableArray *reservedImages;
	@protected BOOL bShoudStop;
	
	@protected IBOutlet NSTextView *textViewStatus;
}
@property (strong) NSMutableDictionary *images;
@property (strong) NSMutableDictionary *files;
@property (strong) NSMutableDictionary *unusedImages;
@property (strong) NSMutableDictionary *usedImages;
@property (strong) NSMutableDictionary *commentedImages;
@property (strong) NSMutableArray *reservedImages;

- (BOOL)windowShouldClose:(id)sender;
- (void)windowWillClose:(NSNotification *)notification;

- (IBAction)btnImageCheck_Click:(id)sender;
- (IBAction)btnDeleteUnused_Click:(id)sender;
- (IBAction)btnDeleteCommented_Click:(id)sender;

@end
