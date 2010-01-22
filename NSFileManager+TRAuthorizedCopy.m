//
//  NSFileManagerAdditions.m
//  TRKit
//

#import "NSFileManager+TRAuthorizedCopy.h"
#import <Carbon/Carbon.h>
#include <stdlib.h>


static AuthorizationRef authorizationRef = NULL;

@implementation NSFileManager (TRAuthorizedCopy)
+(AuthorizationRef)TRauth;
{
	return authorizationRef;
}
- (NSString *)newTmpFilePath
{
	return [NSString stringWithFormat:@"/tmp/%@", [[NSProcessInfo processInfo] globallyUniqueString]];
	//return [NSString stringWithCString:mktemp("/tmp/trauthorizedcopy.XXXXXXX") encoding:NSUTF8StringEncoding]; // WTF, crashes?
}

- (BOOL)authorizedMovePath:(NSString *)source toPath:(NSString *)destination
{
	NSString * trkitMoveUtilityPath = @"/bin/mv";
	
	OSStatus status;
	
	if (authorizationRef == NULL)
	{
		// Get Authorization.
		status = AuthorizationCreate(NULL,
									 kAuthorizationEmptyEnvironment,
									 kAuthorizationFlagDefaults,
									 &authorizationRef);
	}
	else
	{
		status = noErr;
	}
	
	// Make sure we have authorization.
	if (status != noErr)
	{
		NSLog(@"Could not get authorization, failing.");
		return NO;
	}
	
	// Set up the arguments.
	char * args[3] = {
	  [0] = (char *)[[source stringByStandardizingPath] UTF8String],
	  [1] = (char *)[[destination stringByStandardizingPath] UTF8String],
	  [2] = NULL
	};
	
	status = AuthorizationExecuteWithPrivileges(authorizationRef,
												[[trkitMoveUtilityPath stringByStandardizingPath] UTF8String],
												0, args, NULL);
	
	if (status != noErr)
	{
		NSLog(@"Could not move file.");
		return NO;
	}
	else
	{
		return YES;
	}
	
	return NO;
}
- (BOOL)authorizedMoveURL:(NSURL *)source toURL:(NSURL *)destination;
{
	return [self authorizedMovePath:[source path] toPath:[destination path]];
}

- (BOOL)authorizedCopyPath:(NSString *)source toPath:(NSString *)destination
{
	NSString * tempFile = [self newTmpFilePath];
	if(![self copyItemAtPath:source toPath:tempFile error:nil]) return NO;
	return [self authorizedMovePath:tempFile toPath:destination];
}
- (BOOL)authorizedCopyURL:(NSURL *)source toURL:(NSURL *)destination;
{
	return [self authorizedCopyPath:[source path] toPath:[destination path]];
}

@end
