//
//	TwoOneRowEnumerator.h
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GameRowEnumerator.h"

@class GameRow;

//
// TwoOneRowEnumerator is a GameRowEnumerator that returns every row three times,
//	each version rotated so that each square in the row appears as the first
//	square in one enumeration.
// The purpose is to simplify searching for rows containing two different square
//	values (i.e. [ X X _ ] or [ O _ _ ]). By enumerating through each rotated 
//	permutation, the caller can use a simple pattern (i.e. [ O O _ ]) to find
//	any of its rotated variations: [ O O _ ], [ O _ O ], or [ _ O O ].
//


@interface TwoOneRowEnumerator : GameRowEnumerator {
	GameRow *lastRow;
	unsigned int rotation;
}

- (id)initWithGame:(TicTacToeGame*)game;

- (id)nextObject;

@end
