//
//	TwoOneRowEnumerator.m
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import "TwoOneRowEnumerator.h"

#import "GameRow.h"


@implementation TwoOneRowEnumerator

- (id)initWithGame:(TicTacToeGame*)game;
{
	self = [super initWithGame:game];
	if (self != nil) {
		rotation = 2;
	}
	return self;
}

- (id)nextObject
{
	id row = nil;
	
	if (rotation==2)
	{
		// get and remember next row
		row = lastRow = [super nextObject];
		if (row!=nil)
			rotation = 0;
		// return unrotated row or nil
	} else {
		// return the next permutation of the current row
		row = [[GameRow alloc] initWithRow:lastRow rotating:++rotation];
	}
	
	return row;
}

@end
