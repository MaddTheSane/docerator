/*
 
 Docerator Mac OS X application -- GUI for docerator.py
 
 MIT License
 
 Copyright (C) 2010 Sveinbjorn Thordarson  
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <Cocoa/Cocoa.h>
#import "DoceratorImageView.h"

@interface DoceratorAppDelegate : NSObject <DoceratorImageDelegate, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>
{
    IBOutlet NSWindow			*window;
	IBOutlet DoceratorImageView	*appIconImageView;
	IBOutlet NSTextField		*appIconFilenameLabel;
	IBOutlet NSButton		*size1024Checkbox;
	IBOutlet NSButton		*size512Checkbox;
	IBOutlet NSButton		*size256Checkbox;
	IBOutlet NSButton		*size128Checkbox;
	IBOutlet NSButton		*size32Checkbox;
	IBOutlet NSButton		*size16Checkbox;
	IBOutlet NSTableView	*iconLabelsTableView;
	IBOutlet NSButton		*addLabelButton;
	IBOutlet NSButton		*removeLabelButton;
	IBOutlet NSButton		*clearButton;
	IBOutlet NSButton		*createIconButton;
	IBOutlet NSProgressIndicator	*progressIndicator;
	IBOutlet NSTextField			*dropAppIconHereLabel;
	IBOutlet NSWindow				*progressWindow;
	IBOutlet NSWindow				*commandStringWindow;
	IBOutlet NSTextView				*commandStringTextView;
	
	NSString *loadedIconPath;
	NSMutableArray *labels;
	NSMutableArray *smallLabels;
}
@property (readonly, copy) NSString *iconPath;
- (IBAction)clear:(id)sender;
- (IBAction)createIcon:(id)sender;
- (IBAction)addLabel:(id)sender;
- (IBAction)removeSelectedLabel: (id)sender;
- (IBAction)openFile:(id)sender;
- (NSMutableArray<NSString*> *)generateDoceratorShellCommand: (NSString *)destinationPath;
- (IBAction)showCommandString:(id)sender;
- (IBAction)closeCommandStringWindow: (id)sender;
- (NSString *)icnsForAppBundle: (NSString *)appBundlePath;
- (BOOL)loadFile: (NSString *)filePath;
- (BOOL)loadIcnsFile: (NSString *)filePath;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (void)sheetAlert: (NSString *)message subText: (NSString *)subtext;
- (IBAction) openWebsite: (id)sender;
@end
