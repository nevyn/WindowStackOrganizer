//
//  Window_Stack_OrganizerAppDelegate.m
//  Window Stack Organizer
//
//  Created by Joachim Bengtsson on 2009-11-05.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Window_Stack_OrganizerAppDelegate.h"

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
	[[self mutableArrayValueForKey:@"windows"] addObjectsFromArray:[TCSystemWindow allWindows]];
	NSArray *forbiddenIdentifiers = [NSArray arrayWithObjects:[[NSBundle mainBundle] bundleIdentifier], nil];
	[windowsController setFilterPredicate:[NSPredicate predicateWithFormat:@"layer = %@ && NOT (app.bundleIdentifier in %@)", [NSNumber numberWithInt:kCGNormalWindowLevel], forbiddenIdentifiers]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
	TCSystemWindow *tcsw = [[windowsController selectedObjects] objectAtIndex:0];
	[tcsw fade];
}

// Finding window under cursor:
/*OSStatus CGSFindWindowByGeometry(int cid, int zero, int one, int zero_again,
                CGPoint *screen_point, CGPoint *window_coords_out,
                int *wid_out, int *cid_out);*/

// Ordering: extern OSStatus CGSOrderWindow(const CGSConnection cid, CGSWindow wid, CGSWindowOrderingMode place, CGSWindow relativeToWindowID /* can be NULL */);




@end
