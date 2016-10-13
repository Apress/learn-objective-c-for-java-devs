//
//	GameRowEnumerator.m
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import "GameRowEnumerator.h"

#import "GameRow.h"
#import "TicTacToeGame.h"

//
// GameRowEnumerator enumerates the rows in a Tic Tac Toe game.
//
// There are eight rows on the board: three horizontal, three vertical, and the two diagonal.
// This enumerator returns a series of GameRow objects with the contents of each row.
//

//	6 | 7 | 8 
// -----------
//	3 | 4 | 5
// -----------
//	0 | 1 | 2

static SquareMap RowMap[ROWS_IN_BOARD] = {
{ { 0, 1, 2 } },	// horizontal rows
{ { 3, 4, 5 } },
{ { 6, 7, 8 } },
{ { 0, 3, 6 } },	// vertical rows
{ { 1, 4, 7 } },
{ { 2, 5, 8 } },
{ { 0, 4, 8 } },	// diagonals
{ { 2, 4, 6 } },
};

// Order that rows are enumerated (this changes each enumeration)
static unsigned int RowOrder[ROWS_IN_BOARD] = { 0, 1, 2, 3, 4, 5, 6, 7 };

@implementation GameRowEnumerator

@synthesize rowIndex;

- (id)initWithGame:(TicTacToeGame*)game;
{
	self = [super init];
	if (self != nil) {
		board = game;
		
		// To mix up the game a little, incrementally scramble the
		//	row order by swapping two order entries each enumeration.
		unsigned int i1 = ((unsigned int)random())%ROWS_IN_BOARD;
		unsigned int i2 = ((unsigned int)random())%ROWS_IN_BOARD;
		unsigned int t = RowOrder[i1];
		RowOrder[i1] = RowOrder[i2];
		RowOrder[i2] = t;
		memcpy(order,RowOrder,sizeof(order));
	}
	return self;
}

- (id)nextObject
{
	if (enumIndex>=ROWS_IN_BOARD)
		return nil;
	
	rowIndex = order[enumIndex++];
	return [[GameRow alloc] initWithGame:board squares:&RowMap[rowIndex]];
}

@end
