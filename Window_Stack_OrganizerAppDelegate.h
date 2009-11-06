//
//  Window_Stack_OrganizerAppDelegate.h
//  Window Stack Organizer
//
//  Created by Joachim Bengtsson on 2009-11-05.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCSystemWindow.h"

@interface Window_Stack_OrganizerAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	NSMutableArray *windows;
	IBOutlet NSArrayController *windowsController;
}

@property (assign) IBOutlet NSWindow *window;

@end
