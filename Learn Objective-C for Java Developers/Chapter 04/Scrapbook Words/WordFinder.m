//
//  WordFinder.m
//  Scrapper Words
//
//  Created by James Bucanek on 2/11/09.
//  Copyright 2009 Dawn to Dusk Software. All rights reserved.
//

#import "WordFinder.h"

#import "ScrapWordsController.h"


static NSArray *DictionaryWords;			// singleton copy of English word list

@implementation WordFinder

+ (NSArray*)words
{
	// Returns the singleton |words| array
	
	// Read the 'words' file and convert it into an array of strings.
	// The words file is a legacy UNIX file at /usr/share/dict/words that contains
	//	a alphabetic list of about 200,000 common words. It's a flat, ASCII, text file.
	
	// This is done only once, the first time a WordFinder operation is started.
	@synchronized(self) {
		if (DictionaryWords==nil) {
			NSMutableArray *words = [NSMutableArray new];
			
			// Read the entire "words" file into memory (crude, but effective)
			NSData			*wordsData = [NSData dataWithContentsOfFile:@"/usr/share/dict/words"];
			[wordsData retain];		// don't let NSData get garbage collected until the loop is done
			
			char			buffer[1024];				// 1K buffer used to construct C strings
			char			*t = buffer;				// pointer into buffer
			const char		*s = [wordsData bytes];		// pointer into source array
			unsigned int	count = [wordsData length];
			
			// Append the characters in wordsData to the word string buffer.
			// A newline character seperates words.
			while (count!=0)
			{
				// Get next character from source array
				count--;
				char c = *s++;
				
				if (c=='\n') {
					// newline: append accumulated word and reset buffer for next one
					NSString* word = [[NSString stringWithCString:buffer length:t-buffer] lowercaseString];
					if ([word length]>1)		// only add multicharacter words
						[words addObject:word];
					t = buffer;					// reset pointer to beginning of buffer
				}
				else if (c>' ') {
					// regular character
					*t++ = c;					// append character to buffer
				}
			}
			
			[wordsData release];
			DictionaryWords = [NSArray arrayWithArray:words];
		}
	}
	
	return DictionaryWords;
}

- (id)initWithLetters:(NSString*)letters controller:(ScrapWordsController*)windowController
{
	self = [super init];
	if (self!=nil) {
		// Remember the controller; this is used to send the controller the found words.
		// Note: WordFinder could use NSNotifications to announce the words that it
		//		 finds instead, rather than keeping a reference to ScrapWordsWindowController.
		//		 That would require a more code, but would completely decouple
		//		 the two classes.
		controller = windowController;
		
		// Convert the string into an array of character value objects.
		// Only lower case letters are added to the set; all other characters are ignored
		letters = [letters lowercaseString];
		NSCharacterSet *lowercaseLetters = [NSCharacterSet lowercaseLetterCharacterSet];
		NSMutableArray *set = [NSMutableArray arrayWithCapacity:[letters length]];
		unsigned int i;
		for (i=0; i<[letters length]; i++)
		{
			unichar c = [letters characterAtIndex:i];
			if ([lowercaseLetters characterIsMember:c])
				[set addObject:[NSNumber numberWithUnsignedShort:c]];
		}
		// Keep an immutable copy of the character value array
		letterSet = [NSArray arrayWithArray:set];
	}
	return self;
}

- (void)main
{
	// Search for all of the words that can be spelled using the letter set.
	// This is the operation's main method; invoked by NSOperationQueue to execute the operation
	//NSLog(@"%s start",__func__);

	// Get the list of possible words
	NSArray* possibleWords = [WordFinder words];
	
	// First, signal to the controller that a new word search has started
	[controller performSelectorOnMainThread:@selector(removeWords) withObject:nil waitUntilDone:YES];
	
	// The dictionary array contains only multi-character words...
	// If the letter set is too small to find anything, terminate the search early
	if ([letterSet count]<2)
		return;

	// Brute force search of every word in the dictionary...
	for ( NSString *candidate in possibleWords ) {
		int l = [candidate length];
		
		// optimization: no point in examining words that are longer that the set of letters
		if (l>[letterSet count])
			continue;
		
		NSMutableArray *testSet = [NSMutableArray arrayWithArray:letterSet];	// working copy of letter set
		while (l--) {
			// Test each character by trying to delete it from the working set
			unichar c = [candidate characterAtIndex:l];
			unsigned int i = [testSet indexOfObject:[NSNumber numberWithUnsignedShort:c]];
			if (i==NSNotFound)
				goto skipWord;						// word contains a letter that isn't in the set
			[testSet removeObjectAtIndex:i];
		}
		
		// The word can be spelled: Tell the controller (on the main thread) to add it to the list
		[controller performSelectorOnMainThread:@selector(foundWord:) withObject:candidate waitUntilDone:YES];

	skipWord:
		if ([self isCancelled])
			break;
	}

	//NSLog(@"%s stop",__func__);
}

@end
