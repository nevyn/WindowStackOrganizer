//
//  WSOController.m
//  Window Stack Organizer
//
//  Created by Joachim Bengtsson on 2009-11-05.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "WSOController.h"

static WSOController *singleton;


@interface WSOController ()
@property (retain) NSMutableArray *windows;
@end


@implementation WSOController
@synthesize windows;

+(NSBundle*)bundle;
{
	return [NSBundle bundleWithIdentifier:@"eu.thirdcog.WSO"];
}
+(void)load;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	singleton = [[WSOController alloc] init];
	[singleton performSelector:@selector(awakeFromStart) withObject:nil afterDelay:0.1];
	[pool release];
	
	unsetenv("DYLD_INSERT_LIBRARIES");
}
-(id)init;
{
	if(![super init]) return nil;
	
	return self;
}
-(void)awakeFromStart;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
																											selector:@selector(moveWindowUp:)
																													name:WSOMoveWindowUpKey
																												object:nil
																						suspensionBehavior:NSNotificationSuspensionBehaviorHold];
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
																											selector:@selector(moveWindowDown:)
																													name:WSOMoveWindowDownKey object:nil
																						suspensionBehavior:NSNotificationSuspensionBehaviorHold];
																						
	for (TCSystemWindow *win in [TCSystemWindow allWindows]) {
		[win unfade];
	}
	
	[pool release];
}
-(void)dealloc;
{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:WSOMoveWindowUpKey object:nil];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:WSOMoveWindowDownKey object:nil];
	[super dealloc];
}

-(void)moveWindowUp:(NSNotification*)notif;
{
	TCSystemWindow *window = [TCSystemWindow windowFromCGSWindow:[[[notif userInfo] objectForKey:WSOWindowIDKey] intValue]];
	TCSystemWindow *other = nil;
	if([[notif userInfo] objectForKey:WSOOtherWindowIDKey])
		other = [TCSystemWindow windowFromCGSWindow:[[[notif userInfo] objectForKey:WSOOtherWindowIDKey] intValue]];
	[window moveWindow:NSWindowAbove relativeTo:other]; 
}

-(void)moveWindowDown:(NSNotification*)notif;
{
	TCSystemWindow *window = [TCSystemWindow windowFromCGSWindow:[[[notif userInfo] objectForKey:WSOWindowIDKey] intValue]];
	TCSystemWindow *other = nil;
	if([[notif userInfo] objectForKey:WSOOtherWindowIDKey])
		other = [TCSystemWindow windowFromCGSWindow:[[[notif userInfo] objectForKey:WSOOtherWindowIDKey] intValue]];
	[window moveWindow:NSWindowAbove relativeTo:other];
}


@end
