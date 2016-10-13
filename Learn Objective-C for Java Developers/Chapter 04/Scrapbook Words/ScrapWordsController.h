//
//  ScrapWordsWindowController.h
//  Scrapper Words
//
//  Created by James Bucanek on 2/10/09.
//  Copyright 2009 Dawn to Dusk Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ScrapWordsController : NSObject {
	NSString				*letters;
	NSMutableArray			*words;
	NSArrayController		*wordsController;
	NSOperationQueue		*finderQueue;
}

@property (assign) NSString *letters;
@property (assign) IBOutlet NSArrayController *wordsController;

- (void)removeWords;
- (void)foundWord:(NSString*)word;

@end
