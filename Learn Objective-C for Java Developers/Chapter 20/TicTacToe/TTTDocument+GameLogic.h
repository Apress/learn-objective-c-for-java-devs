//
//	TTTDocument+GameLogic.h
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TTTDocument.h"

//
// Catagory of TTTDocument that implements the game interface methods
//
//	-reset:					UI command (button & menu) to reset the game
//	-playForPlayer:			UI command (menu) to make a play on behalf of the user
//	-playerClickedSquare:	Sent by ChalkboardView when the user clicks on a square
//	-computerMoveTime:		Sent by a timer when the computer is ready to move.
//

#define USER_PLAYER		PLAYER_X		// user always plays "X"
#define COMPUTER_PLAYER PLAYER_O		// computer always plays "O"

@interface TTTDocument (GameLogic)

- (IBAction)reset:(id)sender;

- (IBAction)playForPlayer:(id)sender;
- (void)playerClickedSquare:(SquareIndex)index;
- (void)computerMoveTime:(NSTimer*)timer;

@end
