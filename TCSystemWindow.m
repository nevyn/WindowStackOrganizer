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

NSString * const WSOMoveWindowUpKey = @"eu.thirdcog.WSO.moveWindowUp";
NSString * const WSOMoveWindowDownKey = @"eu.thirdcog.WSO.moveWindowDown";
NSString * const WSOMoveWindowAboveOtherKey = @"eu.thirdcog.WSO.moveWindowUp";
NSString * const WSOMoveWindowBelowOtherKey = @"eu.thirdcog.WSO.moveWindowDown";

NSString * const WSOWindowIDKey = @"eu.thirdcog.WSO.CGSWindowID";
NSString * const WSOOtherWindowIDKey = @"eu.thirdcog.WSO.OtherCGSWindowID";


@implementation TCSystemWindow
@synthesize title, ident, app, bounds, layer;
-(id)initFromDescription:(NSDictionary*)dict;
{
	if(![super init]) return nil;
	
	self.title = [dict objectForKey:(id)kCGWindowName];
	self.ident = [[dict objectForKey:(id)kCGWindowNumber] intValue];
	self.app = [NSRunningApplication runningApplicationWithProcessIdentifier:[[dict objectForKey:(id)kCGWindowOwnerPID] intValue]];
	CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[dict objectForKey:(id)kCGWindowBounds], (CGRect*)&bounds);
	self.layer = [[dict objectForKey:(id)kCGWindowLayer] intValue];
	return self;
}
-(id)initFromCGSWindow:(CGSWindow)cgsWin;
{
	CFMutableArrayRef cgsObjs = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
	CFArrayAppendValue(cgsObjs, ((const void*)(NSInteger)cgsWin));
	
	NSArray *descs = [(id)CGWindowListCreateDescriptionFromArray(cgsObjs) autorelease];

	if(!descs || [descs count] == 0) {
		NSLog(@"No descs matching window");
		return nil;
	}
	
	NSDictionary *desc = [descs objectAtIndex:0];
	
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
-(void)unfade;
{
	oscheck(CGSSetWindowAlpha(_CGSDefaultConnection(), self.ident, 1.0));
}
-(void)moveWindow:(NSWindowOrderingMode)mode relativeTo:(TCSystemWindow*)other;
{
	NSLog(@"Moving %@ %@ %@", self, (mode == NSWindowAbove) ? @"above" : @"below", other);
	oscheck(CGSOrderWindow(_CGSDefaultConnection(), self.ident, (CGSWindowOrderingMode)mode, other.ident));
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
-(void)invalidateCache;
{
	[cachedImage release]; cachedImage = nil;
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"TCSystemWindow(%d) %@ > %@ @ %@", self.ident, self.app.localizedName, self.title, NSStringFromRect(self.bounds)];
}

@end


@implementation NSArray (TCSystemWindowUnderCursor)
-(TCSystemWindow*)windowUnderCursor;
{
	CGSConnection cid = _CGSDefaultConnection();
	CGPoint curP = NSPointToCGPoint([NSEvent mouseLocation]);
	curP.y = [[NSScreen mainScreen] frame].size.height - curP.y;
	CGPoint outP;
	int widOut;
	int cidOut;
	OSStatus err = CGSFindWindowByGeometry(cid, 0, 1, 0, &curP, &outP, &widOut, &cidOut);
	if(err) {
		NSLog(@"Failed getting window under cursor");
		return nil;
	}
	for (TCSystemWindow *win in self) {
		if(win.ident == widOut)
			return win;
	}
	NSLog(@"Didn't find a window under the cursor");
	return nil;
}
@end