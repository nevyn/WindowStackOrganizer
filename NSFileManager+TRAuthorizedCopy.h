//
//  NSFileManager+TRAuthorizedCopy.h
//  Window Stack Organizer
//
//  Created by Joachim Bengtsson on 2009-11-08.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface NSFileManager (TRAuthorizedCopy)
- (NSString *)newTmpFilePath;
- (BOOL)authorizedMovePath:(NSString *)source toPath:(NSString *)destination;
- (BOOL)authorizedMoveURL:(NSURL *)source toURL:(NSURL *)destination;
- (BOOL)authorizedCopyPath:(NSString *)source toPath:(NSString *)destination;
- (BOOL)authorizedCopyURL:(NSURL *)source toURL:(NSURL *)destination;
+(AuthorizationRef)TRauth; // Yes, this is an ugly hack. Shut up.
@end
