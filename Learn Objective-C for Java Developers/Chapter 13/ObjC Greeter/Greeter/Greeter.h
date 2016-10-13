/*
 *  Greeter.h
 *  Greeter
 *
 *  Created by James Bucanek on 4/7/09.
 *  Copyright 2009 Apress. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#define SERVICE_NAME_DEFAULT	@"ObjCGreeter"
#define SOCKET_PATH_DEFAULT		@"/tmp/ObjCGreeter.socket"


@class Guest;

@interface Greeter : NSObject

- (void)sayHello;
- (void)greetGuest:(Guest*)guest;
- (NSString*)sayGoodbye;

@end
