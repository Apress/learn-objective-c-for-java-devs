//
//  Guest.m
//  Greeter
//
//  Created by James Bucanek on 4/7/09.
//  Copyright 2009 Apress. All rights reserved.
//

#import "Guest.h"

#import "Greeter.h"

@implementation Guest

- (void)listen:(NSString*)message
{
	NSLog(@"%@ heard \"%@\"",self,message);
}

#if GUEST_SUPPORTS_BY_COPY
// For an object to be passed bycopy to a distant object, it must
//	- Support sequential archiving
//	- Override replacementObjectForPortCoder: to decide when it should be copied

- (id)initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self!=nil) {
		// property = [decoder decode...];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	// [encoder encode...:property];
}

- (id)replacementObjectForPortCoder:(NSPortCoder*)coder
{
//	NSLog(@"%s %@, %@",__func__,self,([coder isBycopy]?@"isBycopy":@"isByref"));

	// By returning |self|, the actual object is archived and transmitted to the remote object.
	// The base class implementation of replacementObjectForPortCoder substitutes an
	//	NSDistantObject object that acts as a proxy for this one.
	if ([coder isBycopy])
		return self;
	return [super replacementObjectForPortCoder:coder];
}

#endif

@end

