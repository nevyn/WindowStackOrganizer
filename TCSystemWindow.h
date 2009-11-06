//
//  TCSystemWindow.h
//  Window Stack Organizer
//
//  Created by Joachim Bengtsson on 2009-11-05.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SDModelObject.h"
#import "CoreGraphicsServices.h"

extern NSString * const WSOMoveWindowUpKey;
extern NSString * const WSOMoveWindowDownKey;
extern NSString * const WSOMoveWindowAboveOtherKey;
extern NSString * const WSOMoveWindowBelowOtherKey;
extern NSString * const WSOWindowIDKey;
extern NSString * const WSOOtherWindowIDKey;

@interface TCSystemWindow : SDModelObject {
	NSImage *cachedImage;
	NSRect bounds;
}

+(id)windowFromDescription:(NSDictionary*)dict;
+(id)windowFromCGSWindow:(CGSWindow)cgsWin;
-(id)initFromDescription:(NSDictionary*)dict;
-(id)initFromCGSWindow:(CGSWindow)cgsWin;


@property (retain) NSString *title;
@property CGSWindow ident;
@property (retain) NSRunningApplication *app;
@property NSRect bounds;
@property int layer;

-(NSImage*)image;
-(void)invalidateCache;

+(NSArray*)allWindows;

-(void)fade;
-(void)unfade;
-(void)moveWindow:(NSWindowOrderingMode)mode relativeTo:(TCSystemWindow*)other;

@end

@interface NSArray (TCSystemWindowUnderCursor)
-(TCSystemWindow*)windowUnderCursor;

@end
