//
//	GameBoard.m
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import "TicTacToeGame.h"

#import "GameRow.h"
#import "GameRowEnumerator.h"
#import "TwoOneRowEnumerator.h"


@implementation TicTacToeGame

+ (void)initialize
{
	// Seed the random number generator
	srandom((unsigned int)[NSDate timeIntervalSinceReferenceDate]);
}

#pragma mark Construction

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self clear];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self != nil) {
		SquareIndex i;
		for (i=0; i<9; i++)
			board[i] = [decoder decodeInt32ForKey:[NSString stringWithFormat:@"Square%u",i]];
		nextPlayer = [decoder decodeInt32ForKey:@"Next"];
		winner = [decoder decodeInt32ForKey:@"Winner"];
		winningRow = [decoder decodeInt32ForKey:@"WinningRow"];
		started = [decoder decodeBoolForKey:@"Started"];
		finished = [decoder decodeBoolForKey:@"Finished"];
		moveCount = [decoder decodeInt32ForKey:@"Moves"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
//	[super encodeWithCoder:encoder];	-- superclass does not conform to NSCoding
	
	SquareIndex i;
	for (i=0; i<9; i++)
		[encoder encodeInt32:board[i] forKey:[NSString stringWithFormat:@"Square%u",i]];
	[encoder encodeInt32:nextPlayer forKey:@"Next"];
	[encoder encodeInt32:winner forKey:@"Winner"];
	[encoder encodeInt32:winningRow forKey:@"WinningRow"];
	[encoder encodeBool:started forKey:@"Started"];
	[encoder encodeBool:finished forKey:@"Finished"];
	[encoder encodeInt32:moveCount forKey:@"Moves"];
}

- (id)copyWithZone:(NSZone*)zone
{
	// All of the instance variables in a GameBoard object are primative scalar values,
	//	so a straight copy is all that's needed.
	return NSCopyObject(self,0,zone);
}

#pragma mark Properties

@synthesize nextPlayer, winner, winningRow, started, finished;
// Note: Some of the properties could be computed, but the game state is sufficiently
//		 simple that keeping the properties in agreement isn't too difficult.
//		 For example, nextPlayer and started could be dynamically computed like this:
//	-(Player)nextPlayer { return (finished?PLAYER_NONE:((moveCount%2==0)?PLAYER_X:PLAYER_O)); }
//	-(BOOL)started { return (moveCount!=0); }

- (SquareMark)markAtSquare:(SquareIndex)index
{
	NSParameterAssert(index<9);
	return board[index];
}

#pragma mark Game Play

- (void)clear
{
	// Reset the game
	bzero(board,sizeof(board));					// fill board with MARK_EMPTY
	moveCount = 0;
	nextPlayer = PLAYER_X;
	winner = PLAYER_NONE;
	winningRow = INVALID_ROW;
	[self willChangeValueForKey:@"started"];
	[self willChangeValueForKey:@"finished"];
	started = finished = NO;
	[self didChangeValueForKey:@"finished"];
	[self didChangeValueForKey:@"started"];
}

- (void)start
{
	// Set |started| state to YES and notify any observers
	if (!started) {
		[self willChangeValueForKey:@"started"];
		started = YES;
		[self didChangeValueForKey:@"started"];		
	}
}

- (void)end
{
	// Set |finished| state to YES and notify any observers
	if (!finished) {
		[self willChangeValueForKey:@"finished"];
		finished = YES;
		nextPlayer = PLAYER_NONE;		// also block any future moves
		[self didChangeValueForKey:@"finished"];		
	}
}

- (BOOL)playSquare:(SquareIndex)index withMark:(SquareMark)mark
{
	// Fill a square with an X or O
	// Return YES if allowed, no if prohibited
	NSParameterAssert(index<9);
	NSParameterAssert(mark==MARK_X||mark==MARK_O);
	
	// Reject illegal moves
	if (self.isFinished || mark!=nextPlayer || board[index]!=MARK_EMPTY)
		return NO;
	
	// Make the move
	board[index] = mark;
	
	// Update the game state
	moveCount++;
	nextPlayer = ComplementaryMark(nextPlayer);
	[self start];
	
	// Is there a winner?
	GameRowEnumerator *e = [self rowEnumerator];
	GameRow *xWins = [GameRow rowWithThree:MARK_X]; // [ X X X ]
	GameRow *oWins = [GameRow rowWithThree:MARK_O]; // [ O O O ]
	for (GameRow *row in e) {
		if ([row matches:xWins]) {
			winner = PLAYER_X;
			break;
		}
		if ([row matches:oWins]) {
			winner = PLAYER_O;
			break;
		}
	}
	if (winner!=PLAYER_NONE) {
		// Somebody won, game ends
		winningRow = [e rowIndex];		// save the winning row
		[self end];
	} else {
		if (moveCount>=9) {
			// Board is full: end game without a winner
			[self end];
		}
	}
	
	return YES;
}

#pragma mark Artificial Intelligence

- (SquareIndex)nextMoveForPlayer:(Player)player
{
	// Calculate a move for a player.
	// Assuming the player is X, the logic searches for
	//	1) A winning move containing a row with X X _
	//	2) A blocking move in a row containing O O _
	//	3) An agressive move in a row containins X _ _
	//	4) A random unoccupied square
	// Note that this is a simplistic algorithm that avoids
	//	really stupid moves, but isn't that hard to beat.
	
	if ([self isFinished] || nextPlayer!=player)
		return INVALID_MOVE;
	
	// Search the rows for a winning move
	NSEnumerator *e = [self twoOneRowEnumerator];
	GameRow *searchRow = [GameRow rowWithTwo:player];	// [ X X _ ]
	for (GameRow *row in e) {
		if ([row matches:searchRow]) {
			// The winning move is an X or O in the third square
			return row->map.index[2];
		}
	}

	// Search for a blocking move
	e = [self twoOneRowEnumerator];
	searchRow = [GameRow rowWithTwo:ComplementaryMark(player)]; // [ O O _ ]
	for (GameRow *row in e) {
		if ([row matches:searchRow]) {
			// Block the opposing player's win by playing the third square
			return row->map.index[2];
		}
	}
	
	// Search for an agression play in a row with our mark and two blanks
	e = [self twoOneRowEnumerator];
	searchRow = [GameRow rowWithOne:player];	// [ X _ _ ]
	for (GameRow *row in e) {
		if ([row matches:searchRow]) {
			// Randomly pick one of the two empty cells
			return row->map.index[1+(random()&0x01)];
		}
	}

	// Pick a square at random
	unsigned int r = ((unsigned int)random())%9;
	while (board[r]!=MARK_EMPTY)
		r = (r+1)%9;
	return r;
}

#pragma mark Row Enumerators

- (GameRowEnumerator*)rowEnumerator
{
	return [[GameRowEnumerator alloc] initWithGame:self];
}

- (GameRowEnumerator*)twoOneRowEnumerator
{
	return [[TwoOneRowEnumerator alloc] initWithGame:self];
}

@end
	