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
	self.windows = nil;
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSArray *forbiddenIdentifiers = [NSArray arrayWithObjects:[[NSBundle mainBundle] bundleIdentifier], nil];
	[windowsController setFilterPredicate:[NSPredicate predicateWithFormat:@"layer = %@ && NOT (app.bundleIdentifier in %@)", [NSNumber numberWithInt:kCGNormalWindowLevel], forbiddenIdentifiers]];
	
	[table registerForDraggedTypes:[NSArray arrayWithObjects:WSOWindowRowType, nil]];

	
}

-(void)reload;
{
	[[self mutableArrayValueForKey:@"windows"] setArray:[TCSystemWindow allWindows]];
	[table reloadData];
}

- (void)windowDidBecomeKey:(NSNotification *)notification;
{
	[self reload];	
	TCSystemWindow *underCursor = [self.windows windowUnderCursor];
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
	[self performSelector:@selector(reload) withObject:nil afterDelay:0.1];
	
	return YES;
}




@end
