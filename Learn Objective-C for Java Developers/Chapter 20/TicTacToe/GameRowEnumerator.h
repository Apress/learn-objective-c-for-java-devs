//
//	GameRowEnumerator.h
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TicTacToeDefs.h"

@class TicTacToeGame;

#define ROWS_IN_BOARD		8
#define INVALID_ROW			ROWS_IN_BOARD


@interface GameRowEnumerator : NSEnumerator {
	TicTacToeGame	*board;
	unsigned int	enumIndex;
	unsigned int	rowIndex;
	unsigned int	order[ROWS_IN_BOARD];
}

@property (readonly) unsigned int rowIndex;

- (id)initWithGame:(TicTacToeGame*)game;

- (id)nextObject;

@end
