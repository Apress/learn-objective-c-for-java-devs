//
//	TTTDocument.h
//	TicTacToe
//
//	Created by James Bucanek on 5/21/09.
//	Copyright Apress 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TicTacToeGame.h"

@class ChalkboardView;

#define GAME_RESET_TAG		1001		/* tag of Reset menu item */
#define GAME_PLAY_ONE_TAG	1002		/* tag of Play One Move menu item */


@interface TTTDocument : NSDocument {
	TicTacToeGame			*game;
	NSString				*gameOutcome;
	IBOutlet ChalkboardView *chalkboardView;
}

@property (assign) TicTacToeGame *game;
@property (assign) NSString *gameOutcome;
@property (assign) id contents;

- (void)undoGame:(NSDictionary*)content;

@end
