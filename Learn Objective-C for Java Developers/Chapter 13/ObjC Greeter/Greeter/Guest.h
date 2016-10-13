//
//  Guest.h
//  Greeter
//
//  Created by James Bucanek on 4/7/09.
//  Copyright 2009 Apress. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GUEST_SUPPORTS_BY_COPY	0	/* 0=pass Guest by reference, 1=pass by copy */

@interface Guest : NSObject
#if GUEST_SUPPORTS_BY_COPY
							<NSCoding>
#endif

- (void)listen:(NSString*)message;

@end
