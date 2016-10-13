//
//	GameRow.m
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import "GameRow.h"

#import "TicTacToeGame.h"


@implementation GameRow

+ (GameRow*)rowWithThree:(SquareMark)fill
{
	// Create an anonymous row with all squared filled with the same mark
	GameRow *row = [GameRow new];
	row->row.mark[0] = row->row.mark[1] = row->row.mark[2] = fill;
	return row;
}

+ (GameRow*)rowWithTwo:(SquareMark)fill
{
	// Create an anonymous row filled with two marks and an empty square
	GameRow *row = [GameRow new];
	row->row.mark[0] = row->row.mark[1] = fill;
	return row;
}

+ (GameRow*)rowWithOne:(SquareMark)fill
{
	// Create an anonymous row filled with a single mark and two empty squares
	GameRow *row = [GameRow new];
	row->row.mark[0] = fill;
	return row;
}

- (id)initWithGame:(TicTacToeGame*)board squares:(const SquareMap*)squares
{
	// Construct a row with the squares described by |squares|
	self = [super init];
	if (self != nil) {
		map = *squares;										// copy indexes
		row.mark[0] = [board markAtSquare:map.index[0]];	// fetch marks at indexes
		row.mark[1] = [board markAtSquare:map.index[1]];
		row.mark[2] = [board markAtSquare:map.index[2]];
	}
	return self;
}

- (id)initWithRow:(GameRow*)originalRow rotating:(unsigned int)rotation
{
	// Construct a row that's a copy of another row, rotated zero or more time
	self = [super init];
	if (self != nil) {
		row = originalRow->row;
		map = originalRow->map;
		rotation %= 3;
		while (rotation--) {
			SquareMark m = row.mark[0];
			row.mark[0] = row.mark[1];
			row.mark[1] = row.mark[2];
			row.mark[2] = m;
			SquareIndex i = map.index[0];
			map.index[0] = map.index[1];
			map.index[1] = map.index[2];
			map.index[2] = i;
		}
	}
	return self;
}

- (BOOL)matches:(GameRow*)otherRow
{
	// returns YES if the marks in the two rows are the same (ignore the map)
	return (otherRow->row.mark[0]==row.mark[0]
			&& otherRow->row.mark[1]==row.mark[1]
			&& otherRow->row.mark[2]==row.mark[2] );
}

@end
