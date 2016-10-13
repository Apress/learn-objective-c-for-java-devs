//
//	GameBoard.h
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TicTacToeDefs.h"

@class GameRowEnumerator;

//
// GameBoard is the data model for a Tic Tac Toe game
//

@interface TicTacToeGame : NSObject <NSCopying,NSCoding> {
	Board				board;
	
@private
	Player				nextPlayer;			// Player to move next, or PLAYER_NONE if game over
	Player				winner;				// Player that won or PLAYER_NONE
	unsigned int		winningRow;			// Row that player filled or PLAYER_NONE
	BOOL				started;			// YES once the first move has been made
	BOOL				finished;			// YES when the game is over (win or draw)
	unsigned int		moveCount;			// Count of completed moves
}

@property (readonly) Player nextPlayer;						// PLAYER_X, PLAYER_O, or PLAYER_NONE
@property (readonly) Player winner;							// PLAYER_NONE, PLAYER_X, or PLAYER_O
@property (readonly) unsigned int winningRow;				// Winning row or INVALID_ROW
@property (readonly,getter=isStarted) BOOL started;			// KVO complient
@property (readonly,getter=isFinished) BOOL finished;		// KVO complient

- (void)clear;
- (SquareMark)markAtSquare:(SquareIndex)index;
- (BOOL)playSquare:(SquareIndex)square withMark:(SquareMark)mark;

- (SquareIndex)nextMoveForPlayer:(Player)player;

- (GameRowEnumerator*)rowEnumerator;
- (GameRowEnumerator*)twoOneRowEnumerator;

@end
