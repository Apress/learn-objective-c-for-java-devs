//
//	ChalkboardView.m
//	TicTacToe
//
//	Created by James Bucanek on 5/22/09.
//	Copyright 2009 Apress. All rights reserved.
//

#import "ChalkboardView.h"

#import "TTTDocument+GameLogic.h"
#import "GameRowEnumerator.h"


static NSMutableDictionary *ImageCache = nil;

// Dimensions of squares in the chalkboard image
// (determined empirically from the background image)
#define BORDER_LEFT		34.0	// width of left border
#define BORDER_BOTTOM	42.0	// height of bottom border
#define ROW_0			72.0	// height of bottom row
#define ROW_1			72.0	// height of middle row
#define ROW_2			70.0	// height of top row
#define COLUMN_0		72.0	// width of left column
#define COLUMN_1		80.0	// width of middle column
#define COLUMN_2		70.0	// width of right column

#define XO_WIDTH		70.0	// width of an X or O
#define XO_HEIGHT		70.0	// width of an X or O

static NSRect SquareRect[9] = {
// Bottom Row
{ { BORDER_LEFT,BORDER_BOTTOM },								{ COLUMN_0, ROW_0 } },
{ { BORDER_LEFT+COLUMN_0,BORDER_BOTTOM },						{ COLUMN_1, ROW_0 } },
{ { BORDER_LEFT+COLUMN_0+COLUMN_1,BORDER_BOTTOM },				{ COLUMN_2, ROW_0 } },
// Middle Row
{ { BORDER_LEFT,BORDER_BOTTOM+ROW_0 },							{ COLUMN_0, ROW_1 } },
{ { BORDER_LEFT+COLUMN_0,BORDER_BOTTOM+ROW_0 },					{ COLUMN_1, ROW_1 } },
{ { BORDER_LEFT+COLUMN_0+COLUMN_1,BORDER_BOTTOM+ROW_0 },		{ COLUMN_2, ROW_1 } },
// Top Row
{ { BORDER_LEFT,BORDER_BOTTOM+ROW_0+ROW_1 },					{ COLUMN_0, ROW_2 } },
{ { BORDER_LEFT+COLUMN_0,BORDER_BOTTOM+ROW_0+ROW_1 },			{ COLUMN_1, ROW_2 } },
{ { BORDER_LEFT+COLUMN_0+COLUMN_1,BORDER_BOTTOM+ROW_0+ROW_1 },	{ COLUMN_2, ROW_2 } }
};

#define STROKE_WIDTH	26.0
#define STROKE_HEIGHT	220.0
#define CENTER_ORIGIN(ORIGIN,ROW_WIDTH) ((ORIGIN)+((ROW_WIDTH)-(STROKE_WIDTH))/2)

typedef struct {
	CGRect		rect;
	float		rotation;
	//	float		scale;
	NSString	*imageName;
} StrokeParams;

static StrokeParams StrokeParam[8] = {	// order must match GameRowEnumerator's RowMap
// Rows
{ { BORDER_LEFT,CENTER_ORIGIN(BORDER_BOTTOM,ROW_0),				STROKE_HEIGHT,STROKE_WIDTH }, 0.0, @"StrokeHorz" },
{ { BORDER_LEFT,CENTER_ORIGIN(BORDER_BOTTOM+ROW_0,ROW_1),		STROKE_HEIGHT,STROKE_WIDTH }, 0.0, @"StrokeHorz" },
{ { BORDER_LEFT,CENTER_ORIGIN(BORDER_BOTTOM+ROW_0+ROW_1,ROW_2), STROKE_HEIGHT,STROKE_WIDTH }, 0.0, @"StrokeHorz" },
// Columns
{ { CENTER_ORIGIN(BORDER_LEFT,COLUMN_0),BORDER_BOTTOM,					STROKE_WIDTH,STROKE_HEIGHT }, 0.0, @"StrokeVert" },
{ { CENTER_ORIGIN(BORDER_LEFT+COLUMN_0,COLUMN_1),BORDER_BOTTOM,			STROKE_WIDTH,STROKE_HEIGHT }, 0.0, @"StrokeVert" },
{ { CENTER_ORIGIN(BORDER_LEFT+COLUMN_0+COLUMN_1,COLUMN_2),BORDER_BOTTOM,STROKE_WIDTH,STROKE_HEIGHT }, 0.0, @"StrokeVert" },
// Diagonals
{ { BORDER_LEFT+8.0,BORDER_BOTTOM+8.0,COLUMN_0+COLUMN_1+COLUMN_2-16.0,ROW_0+ROW_1+ROW_2-16.0 }, 0.0, @"StrokeDiag" },
{ { BORDER_LEFT+8.0,BORDER_BOTTOM+8.0,COLUMN_0+COLUMN_1+COLUMN_2-16.0,ROW_0+ROW_1+ROW_2-16.0 }, -0.5, @"StrokeDiag" },
};


@implementation ChalkboardView

+ (NSRect)rectOfSquare:(SquareIndex)square
{
	NSParameterAssert(square<9);
	return SquareRect[square];
}

+ (NSRect)XORectOfSquare:(SquareIndex)square
{
	// Return rect for an X or O centered in the square
	NSPoint center = [ChalkboardView centerOfSquare:square];
	return NSMakeRect(center.x-XO_WIDTH/2,center.y-XO_HEIGHT/2,XO_WIDTH,XO_HEIGHT);
}
+ (NSPoint)centerOfSquare:(SquareIndex)square
{
	// Return the center point of a square
	NSRect rect = [ChalkboardView rectOfSquare:square];
	return NSMakePoint(NSMidX(rect),NSMidY(rect));
}

+ (CGImageRef)pngImageNamed:(NSString*)name
{
	// Get a PNG image file from the bundle and return it as a CGImageRef

	// See if it's already in the cache
	NSValue *ref = [ImageCache objectForKey:name];
	if (ref!=nil)
		return (CGImageRef)[ref pointerValue];

	// Get the path to the resource file
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
	if (path==nil)
		return nil;
	
	// Create a data source from the file
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:path]);
	CGImageRef image = CGImageCreateWithPNGDataProvider(provider,NULL,NO,kCGRenderingIntentDefault);
	
	// Cache the image for next time
	if (ImageCache==nil)
		ImageCache = [NSMutableDictionary dictionaryWithCapacity:16];
	[ImageCache setObject:[NSValue valueWithPointer:image] forKey:name];
	
	return (image);
}

#pragma mark Construction

- (id) initWithFrame:(NSRect)frameRect
{
	// -(id)initWithFrame: is the designated initializer for an NSView subclass
	self = [super initWithFrame:frameRect];
	if (self != nil) {
		squareLayers = [NSPointerArray pointerArrayWithWeakObjects];
		[squareLayers setCount:9];
	}
	return self;
}

- (void)awakeFromNib
{
	// Get the background image
	CGImageRef chalkboardImage = [ChalkboardView pngImageNamed:@"Chalkboard"];
	// Create an animation layer with the same dimensions as the view
	CALayer *animationLayer = [CALayer layer];
	[animationLayer setFrame:NSRectToCGRect([self bounds])];
	// Let the animation layer container draw the background image
	[animationLayer setContents:(id)chalkboardImage];
	// Set up this NSView to use Core Animation Layers
	[self setLayer:animationLayer];
	[self setWantsLayer:YES];
}

//- (void)drawRect:(NSRect)rect
//{
//	// Traditional NSView content drawing method
//	NSImage *chalkboardImage = [NSImage imageNamed:@"Chalkboard"];
//	NSRect imageRect;
//	imageRect.origin = NSMakePoint(0.0,0.0);
//	imageRect.size = [chalkboardImage size];
//	
//	[chalkboardImage drawInRect:[self bounds]
//					   fromRect:imageRect
//					  operation:NSCompositeSourceOver
//					   fraction:1.0];
//}

#pragma mark Properties

- (TTTDocument*)document
{
	return [[[self window] windowController] document];
}

#pragma mark Animation

- (CGImageRef)nextImageForMark:(SquareMark)mark
{
	// Pick the index counter to use
	unsigned int *indexPtr = (mark==MARK_X?&lastXImageIndex:&lastOImageIndex);
	// Get the next X or O image
	CGImageRef image = [ChalkboardView pngImageNamed:[NSString stringWithFormat:@"%c%u",
													  (mark==MARK_X?'X':'O'),
													  *indexPtr]];
	// Get a different image next time
	*indexPtr += 1;
	if (image==nil) {
		// No image with that index: reset index and recursively return image[0]
		*indexPtr = 0;
		return [self nextImageForMark:mark];
	}
	
	return image;
}
								

- (CALayer*)fillSquare:(SquareIndex)square withMark:(SquareMark)mark
{
	// Create an animation object to draw an X or O and add it to the view.
	// Return the animation object created (for future reference).
	
	CGRect rect = NSRectToCGRect([ChalkboardView XORectOfSquare:square]);
	CGRect startRect = CGRectInset(rect,XO_WIDTH/2-1.0,XO_HEIGHT/2-1.0);
	CALayer *xoLayer = [CALayer layer];
	CGImageRef xoImage = [self nextImageForMark:mark];

	[CATransaction begin];				// Create two trasactions, so setFrame: is animated
	[xoLayer setFrame:startRect];
	[xoLayer setContents:(id)xoImage];
	[[self layer] addSublayer:xoLayer];
	[CATransaction commit];				// animate addSublayer (fade in)
	[xoLayer setFrame:rect];			// animate frame change (zoom)
	
	return xoLayer;
}

- (CALayer*)strokeWinningRow:(unsigned int)winningRow
{
	// Create an animation object to draw the chalk line over the winning row
	//	and add it to the view.
	// Schedule the line to appear after a short delay.
	// Return the animation object created (for future reference).
	
	NSParameterAssert(winningRow<8);
	StrokeParams *params = &StrokeParam[winningRow];
	
	CALayer *strokeLayer = [CALayer layer];
	[[self layer] addSublayer:strokeLayer];
	[strokeLayer setFrame:params->rect];
	[strokeLayer setContents:(id)[ChalkboardView pngImageNamed:params->imageName]];
	[strokeLayer setContentsGravity:kCAGravityResizeAspect];
	if (params->rotation!=0.0) {
		[strokeLayer setTransform:CATransform3DRotate(CATransform3DIdentity,pi*params->rotation,0.0,0.0,1.0)];
	}
	[strokeLayer setHidden:YES];			// stroke is initially invisible
	
	// Delay showing the winning stroke for 1/4 second
	[NSTimer scheduledTimerWithTimeInterval:0.25
									 target:self
								   selector:@selector(animateStrokeTime:)
								   userInfo:[NSDictionary dictionaryWithObject:strokeLayer forKey:@"Stroke"]
									repeats:NO];
	
	return strokeLayer;
}

- (void)animateStrokeTime:(NSTimer*)timer
{
	CALayer *strokeLayer = [[timer userInfo] objectForKey:@"Stroke"];
	[strokeLayer setHidden:NO];
}

#pragma mark Events

- (void)mouseUp:(NSEvent*)theEvent
{
	// Get the mouse up location in local view coordinates (nil translates from window->view).
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	SquareIndex index;
	for (index=0; index<9; index++) {
		if (NSPointInRect(location,[ChalkboardView rectOfSquare:index])) {
			// User clicked in a square: tell the document
			[[self document] playerClickedSquare:index];
			break;
		}
	}
}

#pragma mark Observing

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
	if ([keyPath isEqualToString:@"game"]) {
		// The game object changed: Update the view so that it matches the new game state.
		// This is done intellegently so that only changes between the game and the
		//	current view state are animated.
		TicTacToeGame *game = [change objectForKey:NSKeyValueChangeNewKey];
		SquareIndex i;
		for (i=0; i<9; i++) {
			// Set, replace, or clear each square
			SquareMark mark = [game markAtSquare:i];
			if (mark!=gameState[i]) {
				// Change the display mark for this square
				CALayer *xoLayer = (CALayer*)[squareLayers pointerAtIndex:i];
				[xoLayer removeFromSuperlayer];			// remove (fade out)
				xoLayer = nil;							// forget old animation object
				if (mark!=MARK_EMPTY) {
					// Draw the desired mark
					xoLayer = [self fillSquare:i withMark:mark];
				}
				// Remember new animation object (if any) and update state
				[squareLayers replacePointerAtIndex:i withPointer:xoLayer];
				gameState[i] = mark;
			}
		}
		// Set or clear the winning stroke
		unsigned int winningRow = [game winningRow];
		// (winningRow is only significant if there's a winner)
		if (winningRow!=winRow) {
			// Remove any existing stroke
			[winLayer removeFromSuperlayer];
			winLayer = nil;
			// If there's a winner, place the stroke object
			if (winningRow!=INVALID_ROW) {
				winLayer = [self strokeWinningRow:winningRow];
			}
			winRow = winningRow;
		}
//	} else {	-- none of the superclasses are observers...
//		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
