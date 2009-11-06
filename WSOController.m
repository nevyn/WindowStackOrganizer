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
}
-(id)init;
{
	if(![super init]) return nil;
	
	return self;
}
-(void)awakeFromStart;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	
	[pool release];
}
-(void)dealloc;
{
	[super dealloc];
}




@end
