//
//  WordFinder.h
//  Scrapper Words
//
//  Created by James Bucanek on 2/11/09.
//  Copyright 2009 Dawn to Dusk Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ScrapWordsController;

@interface WordFinder : NSOperation {
	ScrapWordsController	*controller;		// reference to controller
	NSArray					*letterSet;			// set of letters to search
}

+ (NSArray*)words;

- (id)initWithLetters:(NSString*)letters controller:(ScrapWordsController*)windowController;

- (void)main;

@end
