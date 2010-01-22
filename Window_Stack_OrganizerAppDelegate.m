//
//  Window_Stack_OrganizerAppDelegate.m
//  Window Stack Organizer
//
//  Created by Joachim Bengtsson on 2009-11-05.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Window_Stack_OrganizerAppDelegate.h"
#import "WSOController.h"
#import "CollectionUtils.h"
#import "NSFileManager+TRAuthorizedCopy.h"

NSString * const WSOWindowRowType = @"eu.thirdcog.WSO.windowRow";


@interface Window_Stack_OrganizerAppDelegate ()
@property (retain) NSMutableArray *windows;
@end



@implementation Window_Stack_OrganizerAppDelegate

@synthesize window, windows;

-(id)init;
{
	self.windows = [NSMutableArray array];
	
	return self;
}
-(void)dealloc;
{
	[NSEvent removeMonitor:globalEventHandler];
	[NSEvent removeMonitor:localEventHandler];
	self.windows = nil;
	[super dealloc];
}

-(NSURL*)dylibURL;
{
	NSURL *myFrameworks = [[NSBundle mainBundle] privateFrameworksURL];
	NSURL *WSOFramework = [myFrameworks URLByAppendingPathComponent:@"WindowStackOrganizer.framework"];
	NSURL *dylib = [WSOFramework URLByAppendingPathComponent:@"WindowStackOrganizer"];
	return dylib;
}
-(BOOL)isInstalled;
{
	NSURL *dockInnards = [NSURL URLWithString:@"/System/Library/CoreServices/Dock.app/Contents/MacOS"];
	NSURL *dock = [dockInnards URLByAppendingPathComponent:@"Dock"];
	NSURL *realDock = [dockInnards URLByAppendingPathComponent:@"Dock_WSOMovedAside"];
	
	if( ! [[NSFileManager defaultManager] fileExistsAtPath:[realDock path]])
		return NO;
	
	NSString *trampolineContents = [NSString stringWithContentsOfURL:dock encoding:NSUTF8StringEncoding error:nil];
	if( [trampolineContents rangeOfString:[self.dylibURL path]].location == NSNotFound )
		return NO;
		
	return YES;
}
-(void)install;
{
	NSURL *dockInnards = [NSURL URLWithString:@"/System/Library/CoreServices/Dock.app/Contents/MacOS"];
	NSURL *dock = [dockInnards URLByAppendingPathComponent:@"Dock"];
	NSURL *realDock = [dockInnards URLByAppendingPathComponent:@"Dock_WSOMovedAside"];
	
	BOOL success = [[NSFileManager defaultManager] authorizedMoveURL:dock toURL:realDock];
	if( ! success ) {
		NSRunAlertPanel(@"Couldn't install", @"The Dock couldn't be moved aside.", @"Bummer", nil, nil);
		[NSApp terminate:nil];
	}
	
	NSString *template = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"trampoline_template" withExtension:@""] encoding:NSUTF8StringEncoding error:nil];
	
	NSString *sortaSafeDylibPath = [[self.dylibURL path] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
	
	NSString *script = [template stringByReplacingOccurrencesOfString:@"<<WSOPATH>>" withString:sortaSafeDylibPath];
	
	NSURL *scriptURL = [NSURL fileURLWithPath:[[NSFileManager defaultManager] newTmpFilePath]];
	success = [script writeToURL:scriptURL atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	if(success)
		success &= [[NSFileManager defaultManager] authorizedCopyURL:scriptURL toURL:realDock];
	
	if( ! success ) {
		NSRunAlertPanel(@"Couldn't install", @"The replacement Dock script couldn't be moved into place.", @"Bummer", nil, nil);
		[[NSFileManager defaultManager] authorizedMoveURL:realDock toURL:dock];
		[NSApp terminate:nil];
	}
	
	char * args[2] = {"Dock", NULL};
	OSStatus status = AuthorizationExecuteWithPrivileges([NSFileManager TRauth], "/usr/bin/killall", 0, args, NULL);
	
	if( status != noErr) {
		NSRunAlertPanel(@"Couldn't restart the dock to finish installation", @"Log out and back in and everything should work fine", @"Oh well", nil, nil);
		[NSApp terminate:nil];
	}

}

-(void)installIfNeeded;
{
	if( ! [self isInstalled]) {
		NSInteger clickedButton = NSRunAlertPanel(@"Hack installation needed", @"An unsupported hack needs to be installed into the Dock for this application to work. Mind if I go ahead and do that? Since this app is in early development, you probably want to feel secure in removing bash scripts from CoreServices in case something goes wrong.", @"Install", @"Quit", nil);
		if(clickedButton == NSAlertAlternateReturn)
			[NSApp terminate:nil];
		
		// We got a go-ahead; install the stuff.
		[self install];
	}
}

-(void)deactivate;
{
	[[NSApplication sharedApplication] hide:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSArray *forbiddenIdentifiers = [NSArray arrayWithObjects:[[NSBundle mainBundle] bundleIdentifier], nil];
	[windowsController setFilterPredicate:[NSPredicate predicateWithFormat:@"layer = %@ && NOT (app.bundleIdentifier in %@)", [NSNumber numberWithInt:kCGNormalWindowLevel], forbiddenIdentifiers]];
	
	[table registerForDraggedTypes:[NSArray arrayWithObjects:WSOWindowRowType, nil]];
	
	globalEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask|NSKeyUpMask handler:^(NSEvent *evt) {
		BOOL ourEvent = YES;
		ourEvent &= (evt.modifierFlags&NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask; // Command key is held
		ourEvent &= evt.keyCode == 10; // Top-left-most key (§) on my keyboard at least
		
		if(!ourEvent) return;
		
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[self.window makeKeyAndOrderFront:nil];
	}];
	globalEventHandler = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask|NSKeyUpMask handler:^ NSEvent * (NSEvent *evt) {
		BOOL ourEvent = YES;
		ourEvent &= (evt.modifierFlags&NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask; // Command key is held
		ourEvent &= evt.keyCode == 10; // Top-left-most key (§) on my keyboard at least
		
		ourEvent |= evt.keyCode == 53; // esc
		
		if(!ourEvent) return evt;
		
		[self deactivate];
		
		return nil;
	}];
	
	[table setTarget:self];
	[table setDoubleAction:@selector(goToWindowRow:)];
	
	[self installIfNeeded];
}

-(void)reload;
{
	NSArray *newWindows = [TCSystemWindow allWindows];
	//[[self mutableArrayValueForKey:@"windows"] mergeWithTCSystemWindowArray:newWindows]; // doesn't work
	[[self mutableArrayValueForKey:@"windows"] setArray:newWindows];
	for (TCSystemWindow *tcsw in [self mutableArrayValueForKey:@"windows"]) {
		[tcsw invalidateCache];
	}
}
- (void)windowDidResignKey:(NSNotification *)notification;
{
	[self.window orderOut:nil];
	self.window.alphaValue = 0;
}

NSScreen *screenAtPoint(NSPoint p) {
	for (NSScreen *screen in [NSScreen screens])
		if(NSPointInRect(p, screen.frame))
			return screen;
	return nil;
}

- (void)windowDidBecomeKey:(NSNotification *)notification;
{
	[self reload];
	NSPoint cursor = [NSEvent mouseLocation];
	TCSystemWindow *underCursor = [self.windows windowUnderPoint:cursor];
	
	NSRect screenFrame = screenAtPoint(cursor).visibleFrame;
	float x = cursor.x-window.frame.size.width/2;
	if(x < screenFrame.origin.x) x = screenFrame.origin.x;
	if(x > screenFrame.origin.x + screenFrame.size.width - window.frame.size.width)
		x = screenFrame.origin.x + screenFrame.size.width - window.frame.size.width;
	
	NSRect newFrame = NSMakeRect(x, NSMinY(screenFrame), window.frame.size.width, NSHeight(screenFrame));
	
	int rowOfUnderCursor = [[windowsController arrangedObjects] indexOfObject:underCursor];
	
	if(underCursor) {
		[table scrollRowToVisible:rowOfUnderCursor];
		
	}
	
	
	[window setFrame:newFrame display:YES];
	self.window.alphaValue = 1;
	
}


- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{	
	// Declare our "moved rows" drag type
	[pboard declareTypes:$array(WSOWindowRowType) owner:self];
	
	// Just add the rows themselves to the pasteboard
	[pboard setPropertyList:rows forType:WSOWindowRowType];
		
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
	// if drag source is our own table view, it's a move or a copy
	if ([info draggingSource] == table) {
		[tv setDropRow:row dropOperation:NSTableViewDropAbove];
		return NSDragOperationMove;		
	}
	
	// Don't allow drops from anywhere else
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)newRow dropOperation:(NSTableViewDropOperation)op
{
	if (newRow < 0)
	{
		newRow = 0;
	}
	
	NSArray *oldRows = [[info draggingPasteboard] propertyListForType:WSOWindowRowType];
	NSInteger oldRow = [[oldRows objectAtIndex:0] integerValue];
	
	TCSystemWindow *moving = [[windowsController arrangedObjects] objectAtIndex:oldRow];
	TCSystemWindow *adjacent = nil;
	NSString *notifName = WSOMoveWindowUpKey;
	
	if(newRow == [[windowsController arrangedObjects] count]) {
		// Dragging to bottom-most row
		notifName = WSOMoveWindowDownKey;
		adjacent = nil;
	} else
		adjacent = [[windowsController arrangedObjects] objectAtIndex:newRow];
	
	NSDictionary *userInfo = $dict(
		WSOWindowIDKey, $object(moving.ident),
		WSOOtherWindowIDKey, $object(adjacent.ident)
	);
	
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:WSOMoveWindowUpKey object:nil userInfo:userInfo];
	[self performSelector:@selector(reload) withObject:nil afterDelay:0];
	
	return YES;
}

-(IBAction)goToWindowRow:(id)sender;
{
	TCSystemWindow *focusThis = [[windowsController arrangedObjects] objectAtIndex:[table clickedRow]];
		NSDictionary *userInfo = $dict(
		WSOWindowIDKey, $object(focusThis.ident),
	);
	
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:WSOMoveWindowUpKey object:nil userInfo:userInfo];
	[self deactivate];
}



@end
