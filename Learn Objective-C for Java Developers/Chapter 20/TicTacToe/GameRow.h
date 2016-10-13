//
//	GameRow.h
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TicTacToeDefs.h"

@class TicTacToeGame;

//
// GameRow encapsulates a single row in a Tic Tac Toe game.
//
// It can be any row: horizontal, vertical, or diagonal.
// The |row| array holds the marks (empty/X/O) in each square.
// The |map| array indicates the index from the original game board where
//	each |row| member came from.
//

@interface GameRow : NSObject {
	@public
	Row			row;
	SquareMap	map;
}

+ (GameRow*)rowWithThree:(SquareMark)fill;
+ (GameRow*)rowWithTwo:(SquareMark)fill;
+ (GameRow*)rowWithOne:(SquareMark)fill;

- (id)initWithGame:(TicTacToeGame*)board squares:(const SquareMap*)squares;
- (id)initWithRow:(GameRow*)row rotating:(unsigned int)rotation;

- (BOOL)matches:(GameRow*)row;

@end
