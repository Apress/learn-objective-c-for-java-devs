//
//	ChalkboardView.h
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

#import "TicTacToeDefs.h"
#import "TicTacToeGame.h"

@class TTTDocument;

//
// ChalkboardView displays a tic tac toe game
//

@interface ChalkboardView : NSView {
	// The state of the board being displayed
	Board			gameState;
	unsigned int	winRow;
	NSPointerArray	*squareLayers;		// CALayers for the marks in gameState
	CALayer			*winLayer;			// CALayer of winning stroke

@private
	// indexes to X/O image files
	unsigned int	lastXImageIndex;
	unsigned int	lastOImageIndex;
}

+ (NSRect)rectOfSquare:(SquareIndex)square;
+ (NSRect)XORectOfSquare:(SquareIndex)sqaure;
+ (NSPoint)centerOfSquare:(SquareIndex)square;

- (TTTDocument*)document;

- (CGImageRef)nextImageForMark:(SquareMark)mark;
- (CALayer*)fillSquare:(SquareIndex)square withMark:(SquareMark)mark;
- (CALayer*)strokeWinningRow:(unsigned int)winningRow;

@end
