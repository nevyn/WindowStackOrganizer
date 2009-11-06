//
//  SDModelClass.m
//  SnowyTest
//
//  Created by Steven Degutis on 10/31/09.
//  Copyright 2009 Steven Degutis. All rights reserved.
//

#import "SDModelObject.h"

#import <objc/runtime.h>

@implementation SDModelObject

+ (NSArray*) uniqueKeySortDescriptors {
	static NSArray *uniqueKeySortDescriptors;
	if (uniqueKeySortDescriptors == nil) {
		NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"description" ascending:YES] autorelease];
		uniqueKeySortDescriptors = [[NSArray arrayWithObject:descriptor] retain];
	}
	return uniqueKeySortDescriptors;
}

- (id) init {
	if (self = [super init]) {
	}
	return self;
}

- (void) dealloc {
	Class Subclass = [self class];
	unsigned int count;
	objc_property_t *properties = class_copyPropertyList(Subclass, &count);
	
	for (unsigned int i = 0; i < count; i++) {
		objc_property_t property = properties[i];
		
		BOOL isObjCType = (property_getAttributes(property)[1] == '@');
		
		if (isObjCType) {
			void* trash;
			Ivar ivar = object_getInstanceVariable(self, property_getName(property), &trash);
			
			id object = object_getIvar(self, ivar);
			[object release];
			object_setIvar(self, ivar, nil);
		}
	}
	
	free(properties);
	
	[super dealloc];
}

- (BOOL) isEqual:(id)object {
	if ([object isKindOfClass:[self class]] == NO)
		return NO;
	
	NSSet *keys = [[self class] keysToUseAsUniqueIdentifiers];
	
	if ([keys count] == 0)
		return [super isEqual:object];
	
	// sort them alphabetically so they're always in the same order
	NSArray *orderedKeys = [keys sortedArrayUsingDescriptors:[SDModelObject uniqueKeySortDescriptors]];
	NSDictionary *ourValuesAndKeys = [self dictionaryWithValuesForKeys:orderedKeys];
	NSDictionary *theirValuesAndKeys = [object dictionaryWithValuesForKeys:orderedKeys];
	
	for (NSString *key in orderedKeys) {
		// if it isnt an ObjC type or a @property, dont try and compare it.
		// generally, only ObjC types should be returned from the NSSet method anyway.
		
		objc_property_t property = class_getProperty([self class], [key UTF8String]);
		if (property == NULL)
			continue;
		
		BOOL isObjCType = (property_getAttributes(property)[1] == '@');
		if (isObjCType == NO)
			continue;
		
		id ourValue = [ourValuesAndKeys objectForKey:key];
		id theirValue = [theirValuesAndKeys objectForKey:key];
		
		if ([ourValue isEqual: theirValue] == NO)
			return NO;
	}
	
	return YES;
}

- (NSUInteger) hash {
	NSSet *keys = [[self class] keysToUseAsUniqueIdentifiers];
	
	if ([keys count] == 0)
		return [super hash];
	
	// sort them alphabetically so they're always in the same order
	NSArray *orderedKeys = [keys sortedArrayUsingDescriptors:[SDModelObject uniqueKeySortDescriptors]];
	NSDictionary *valuesAndKeys = [self dictionaryWithValuesForKeys:orderedKeys];
	
	// just add the hashes together
	NSUInteger hash = 0;
	for (NSString *key in orderedKeys) {
		id value = [valuesAndKeys objectForKey:key];
		hash += [value hash];
	}
	
	return hash;
}

+ (NSSet*) keysToUseAsUniqueIdentifiers {
	return nil;
}

@end
