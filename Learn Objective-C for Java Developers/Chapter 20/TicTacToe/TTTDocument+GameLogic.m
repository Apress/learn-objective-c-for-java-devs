//
//	TTTDocument+GameLogic.m
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import "TTTDocument+GameLogic.h"


@implementation TTTDocument (GameLogic)

- (IBAction)reset:(id)sender
{
	// Push the previous game state onto the undo stack
	[[self undoManager] registerUndoWithTarget:self selector:@selector(undoGame:) object:self.contents];
	[[self undoManager] setActionName:@"Reset"];

	// Clear the game
	[self willChangeValueForKey:@"game"];
	[game clear];
	[self didChangeValueForKey:@"game"];

	self.gameOutcome = @"";
}

- (IBAction)playForPlayer:(id)sender
{
	// Make a play on behalf of the user
	SquareIndex nextMove = [game nextMoveForPlayer:USER_PLAYER];
	if (nextMove!=INVALID_MOVE)
		[self playerClickedSquare:nextMove];
}

- (void)playerClickedSquare:(SquareIndex)index
{
	NSDictionary *saveContents = self.contents;

	if ([game playSquare:index withMark:USER_PLAYER]) {
		// Push the previous game state onto the undo stack
		[[self undoManager] registerUndoWithTarget:self selector:@selector(undoGame:) object:saveContents];
		[[self undoManager] setActionName:@"Move"];
		
		[self willChangeValueForKey:@"game"];			// game state is about to change
		if ([game isFinished]) {
			// Game is over
			if ([game winner]==USER_PLAYER) {
				// User won
				NSArray *conceedMessages = [NSArray arrayWithObjects:
											@"Wow, I didn't see that one coming!",
											@"Congratulations!",
											@"How about two out of three?",
											@"You are a Tic Tac Toe master!",
											@"I bow to your superior skill.",
											nil];
				self.gameOutcome = [conceedMessages objectAtIndex:random()%[conceedMessages count]];
			} else {
				// No winner: draw
				NSArray *drawMessages = [NSArray arrayWithObjects:
										 @"We're pretty evenly matched.",
										 @"Draw",
										 @"I'll beat you next time for sure.",
										 @"No winner here.",
										 nil];
				self.gameOutcome = [drawMessages objectAtIndex:random()%[drawMessages count]];
			}
		} else {
			// Game is not over: Schedule the computer to make the next move
			[NSTimer scheduledTimerWithTimeInterval:1.0
											 target:self
										   selector:@selector(computerMoveTime:)
										   userInfo:nil
											repeats:NO];
		}
		[self didChangeValueForKey:@"game"];
	} else {
		// You can't play that square
		NSBeep();
	}
}

- (void)computerMoveTime:(NSTimer*)timer
{
	// The computer's turn to play
	SquareIndex nextMove = [game nextMoveForPlayer:COMPUTER_PLAYER];
	if (nextMove!=INVALID_MOVE) {
		[self willChangeValueForKey:@"game"];			// game state is about to change
		if ([game playSquare:nextMove withMark:COMPUTER_PLAYER]) {
			// See if the computer won
			if ([game winner]==COMPUTER_PLAYER) {
				NSArray *gloatMessages = [NSArray arrayWithObjects:
										  @"I win!",
										  @"Would you like another game?",
										  @"I am a computer, after all.",
										  @"It's all in the bits.",
										  @"Better luck next time.",
										  nil];
				self.gameOutcome = [gloatMessages objectAtIndex:random()%[gloatMessages count]];
			}
		}
		[self didChangeValueForKey:@"game"];
	}
}

@end
