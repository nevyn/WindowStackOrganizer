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

@interface TCSystemWindow : SDModelObject {
	NSImage *cachedImage;
	NSRect bounds;
}
@property (retain) NSString *title;
@property CGSWindow ident;
@property (retain) NSRunningApplication *app;
@property NSRect bounds;
@property int layer;

-(NSImage*)image;

+(NSArray*)allWindows;

-(void)fade;

@end
