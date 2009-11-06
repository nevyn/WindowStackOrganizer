//
//  BlockExtensions.h
//  BambProxy
//
//  Created by Joachim Bengtsson on 2009-07-22.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>

// This is needed because a block literal is allocated ON THE STACK, and [retain] does NOT move it heap, while [copy] does, which allows it to be stored somewhere else after it disappears off the scope (e g in a collection as below)
#define toheap(o) [[o copy] autorelease]


@interface NSArray (TCNSArrayBlockExtensions)
-(NSArray*)tcMap:(id(^)(id))mapper;
@end

@interface NSObject (TCBlockExtensions)
-(void)tcInvoke;
@end