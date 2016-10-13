//
//	MyDocument.m
//	TicTacToe
//
//	Created by James Bucanek on 5/21/09.
//	Copyright Apress 2009. All rights reserved.
//

#import "TTTDocument.h"
#import "TTTDocument+GameLogic.h"

#import "ChalkboardView.h"


@implementation TTTDocument

@synthesize game, gameOutcome;

#pragma mark Construction

- (id)init
{
	self = [super init];
	if (self) {
		game = [TicTacToeGame new];
	}
	return self;
}

- (NSString *)windowNibName
{
	return @"TTTDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController*)controller
{
	[super windowControllerDidLoadNib:controller];
	
	// The game view needs to observe changes to the game board.
	// Set this up in the document initialization, because it's too early to set up
	//	the obsevers while the NIB is loading. (The window doesn't get connected
	//	to its document controller until after the NIB has loaded.)
	[self addObserver:chalkboardView
		   forKeyPath:@"game"
			  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial)
			  context:NULL];
}

#pragma mark NSDocument Support

- (NSData*)dataOfType:(NSString*)typeName error:(NSError**)outError
{
	// Return the document contents as archived data
	return [NSKeyedArchiver archivedDataWithRootObject:self.contents];
}

- (BOOL)readFromData:(NSData*)data ofType:(NSString*)typeName error:(NSError**)outError
{
	// Set the document data model using the archived data
	self.contents = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	return YES;
}

#pragma mark Document Contents

- (id)contents
{
	// Return an immutable copy of the document contents
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[game copy],	@"Game",		// make copy, so future changes don't affect the returned value
			gameOutcome,	@"Message",		// might be nil, which would terminate list
			nil];
}

- (void)setContents:(id)content
{
	// Set the document data model using the contents of the dictionary
	self.game = [content objectForKey:@"Game"];
	self.gameOutcome = [content objectForKey:@"Message"];	// might be nil
}

#pragma mark Menu Items

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
	if ([menuItem action]==@selector(reset:)) {
		// Enable Reset command only if there's something to reset
		return game.isStarted;
	} else if ([menuItem action]==@selector(playForPlayer:)) {
		// Enable "Play one for me" command only when it's the user's turn
		return game.nextPlayer==USER_PLAYER;
	}
	return [super validateMenuItem:menuItem];
}

#pragma mark Undo

- (void)undoGame:(NSDictionary*)content
{
	// Restore the game state to a previously saved value
	NSDictionary *currentContents = self.contents;
	self.contents = content;
	// Push the usurped state onto the redo stack
	[[self undoManager] registerUndoWithTarget:self
									  selector:@selector(undoGame:)
										object:currentContents];
}

@end
