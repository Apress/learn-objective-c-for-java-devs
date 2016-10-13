//
//  Greeter.m
//  Greeter
//
//  Created by James Bucanek on 4/7/09.
//  Copyright 2009 Apress. All rights reserved.
//

#import "Greeter.h"

#import "Guest.h"

@implementation Greeter

- (void)sayHello
{
	NSLog(@"Greeter %@ was asked to sayHello",self);
}

- (void)greetGuest:(bycopy Guest*)guest
{
	NSLog(@"Greeter %@ was asked to greetGuest:%@",self,guest);
	[guest listen:[NSString stringWithFormat:@"I'm pleased to meet you, %@!",guest]];
}

- (NSString*)sayGoodbye
{
	NSLog(@"Greeter %@ was asked to sayGoodbye",self);
	return @"It was a pleasure serving you.";
}

@end
