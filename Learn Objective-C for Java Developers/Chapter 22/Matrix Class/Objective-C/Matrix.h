//
//  Matrix.h
//
//  Created by James Bucanek on 6/4/09.
//  Copyright 2009 Apress. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface Matrix : NSObject {
	@protected
	NSUInteger		rows;
	NSUInteger		columns;
	__strong double	*values;
}

+ (Matrix*)identityMatrixWithDimensions:(NSUInteger)dimension;
+ (Matrix*)matrixWithMatrix:(Matrix*)matrix;

- (id)initWithRows:(NSUInteger)rowCount columns:(NSUInteger)colCount;
- (id)initIdentityWithDimensions:(NSUInteger)dimensions;
- (id)initWithValues:(const double*)valueArray rows:(NSUInteger)rowCount columns:(NSUInteger)colCount;

@property (readonly) NSUInteger rows;
@property (readonly) NSUInteger columns;
@property (readonly,getter=isIdentity) BOOL identity;

- (double)valueAtRow:(NSUInteger)row column:(NSUInteger)column;

- (Matrix*)addMatrix:(Matrix*)matrix;
- (Matrix*)multiplyMatrix:(Matrix*)matrix;
- (Matrix*)multiplyScalar:(double)scalar;
- (Matrix*)transpose;

@end
