//
//  ScrapWordsWindowController.m
//  Scrapper Words
//
//  Created by James Bucanek on 2/10/09.
//  Copyright 2009 Dawn to Dusk Software. All rights reserved.
//

#import "ScrapWordsController.h"

#import "WordFinder.h"


@implementation ScrapWordsController

@synthesize wordsController;

- (id) init
{
	self = [super init];
	if (self != nil) {
		words = [NSMutableArray new];
		finderQueue = [NSOperationQueue new];
	}
	return self;
}

#pragma mark Properties

- (NSString*)letters
{
	return (letters);
}

- (void)setLetters:(NSString*)newLetters
{
	if (newLetters==nil)
		newLetters = @"";
	if (![letters isEqualToString:newLetters])
	{
		// The set of letters changed
		letters = newLetters;
		
		// Whenever the letter set changes, start a new search
		//	operation to find the words that can be spelled.
		[finderQueue cancelAllOperations];				// stop any searches that are in progress
		WordFinder *finder = [[WordFinder alloc] initWithLetters:newLetters controller:self];
		[finderQueue addOperation:finder];				// start searching using this letter set
	}
}


- (void)removeWords
{
	// Clear the entire list of found words
	// This message is sent when a WordFinder operation begins
	NSIndexSet *everyItemIndex = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[words count])];
	[wordsController removeObjectsAtArrangedObjectIndexes:everyItemIndex];
}

- (void)foundWord:(NSString*)word
{
	// Add a new word to the list, but don't add duplicates.
	// (Words are added is sorted order, so the duplicate check only needs to test the last item in the array)
	// This message is sent whenever the WordFinder operation finds another word
	if ([words count]==0 || ![[words lastObject] isEqualTo:word])
		[wordsController addObject:word];
}

@end
