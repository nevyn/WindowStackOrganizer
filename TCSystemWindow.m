//
//  TCSystemWindow.m
//  Window Stack Organizer
//
//  Created by Joachim Bengtsson on 2009-11-05.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "TCSystemWindow.h"
#import "BlockExtensions.h"
#define oscheck(x) { OSStatus err = (x); if(err != noErr) NSLog(@"Error on " #x ": %d", err); }

@implementation TCSystemWindow
@synthesize appName, title, ident;
-(id)initFromDescription:(NSDictionary*)dict;
{
	if(![super init]) return nil;
	
	self.title = [dict objectForKey:(id)kCGWindowName];
	self.appName = [dict objectForKey:(id)kCGWindowOwnerName];
	self.ident = [[dict objectForKey:(id)kCGWindowNumber] intValue];
	
	return self;
}
-(id)initFromCGSWindow:(CGSWindow)cgsWin;
{
	NSDictionary *desc = [[(id)CGWindowListCreateDescriptionFromArray([NSArray arrayWithObject:[NSNumber numberWithInt:cgsWin]]) autorelease] objectAtIndex:0]
	
	return [self initFromDescription:desc];
}
+(id)windowFromDescription:(NSDictionary*)dict;
{
	return [[[self alloc] initFromDescription:dict] autorelease];
}
+(id)windowFromCGSWindow:(CGSWindow)cgsWin;
{
	return [[[self alloc] initFromCGSWindow:cgsWin] autorelease];
}
-(void)dealloc;
{
	[cachedImage release];
	[super dealloc];
}

+(NSArray*)allWindows;
{
	CGWindowListOption options = kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements;
	NSArray *descs = [(NSArray*)CGWindowListCopyWindowInfo(options, kCGNullWindowID) autorelease];
	return [descs tcMap:^(id desc) { return [TCSystemWindow windowFromDescription:desc]; }];
	/*
	int count = 0;
	oscheck(CGSGetOnScreenWindowCount(_CGSDefaultConnection(), 0, &count));
	CGSWindow *cgswindows = malloc(sizeof(CGSWindow)*count);
	oscheck(CGSGetOnScreenWindowList(_CGSDefaultConnection(), 0, count, cgswindows, &count));
	NSMutableArray *ids = [NSMutableArray array];
	for(int i = 0; i < count; i++) {
		[ids addObject:[NSNumber numberWithInt:cgswindows[i]]]		
	}*/
}

-(void)fade;
{
	oscheck(CGSSetWindowAlpha(_CGSDefaultConnection(), self.ident, 0.5));
}

-(NSImage*)image;
{
	if(cachedImage) return cachedImage;
	
	CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, ident, kCGWindowImageBoundsIgnoreFraming);
	
	if(CGImageGetWidth(windowImage) <= 1) {
		CGImageRelease(windowImage);
		return nil;
	}
	
	cachedImage = [[NSImage alloc] initWithCGImage:windowImage size:NSZeroSize];
	
	return cachedImage;
}

@end