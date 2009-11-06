//
//  BlockExtensions.m
//  BambProxy
//
//  Created by Joachim Bengtsson on 2009-07-22.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "BlockExtensions.h"


@implementation NSArray (TCNSArrayBlockExtensions)
-(NSArray*)tcMap:(id(^)(id))mapper;
{
	NSMutableArray *res = [NSMutableArray arrayWithCapacity:[self count]];
	for (id obj in self)
		[res addObject:mapper(obj)];
	return res;
}
@end


@implementation NSObject (TCBlockExtensions)
-(void)tcInvoke;
{
	void (^block)(void) = (id)self;
	block();
}
@end