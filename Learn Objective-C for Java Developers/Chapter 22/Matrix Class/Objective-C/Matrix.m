//
//  Matrix.m
//
//  Created by James Bucanek on 6/4/09.
//  Copyright 2009 Apress. All rights reserved.
//

#import "Matrix.h"
#import "Matrix+Private.h"


@implementation Matrix

#pragma mark Constructors

+ (Matrix*)identityMatrixWithDimensions:(NSUInteger)dimensions
{
	return [[Matrix alloc] initIdentityWithDimensions:dimensions];
}

+ (Matrix*)matrixWithMatrix:(Matrix*)matrix
{
	__strong double *copy = MatrixCopyArray(matrix->values,matrix->rows,matrix->columns);
	return [[Matrix alloc] initWithAllocatedArray:copy rows:matrix->rows columns:matrix->columns];
}

- (id)initWithRows:(NSUInteger)rowCount columns:(NSUInteger)colCount
{
	// Create an empty matrix
	return [self initWithAllocatedArray:MatrixAllocateEmptyArray(rowCount,colCount)
								   rows:rowCount
								columns:colCount];
}

- (id)initIdentityWithDimensions:(NSUInteger)dimensions
{
	self = [super init];
	if (self != nil) {
		rows = columns = dimensions;
		values = MatrixAllocateEmptyArray(dimensions,dimensions);
		NSUInteger i;
		for (i=0; i<dimensions; i++)
			IVALUE(i,i) = 1.0;
	}
	return self;
}

- (id)initWithValues:(const double*)valueArray rows:(NSUInteger)rowCount columns:(NSUInteger)colCount
{
	// Construct a matrix from an array of values
	__strong double *duplicateArray = MatrixCopyArray(valueArray,rowCount,colCount);
	return [self initWithAllocatedArray:duplicateArray rows:rowCount columns:colCount];
}

- (id)initWithAllocatedArray:(__strong double*)array rows:(NSUInteger)rowCount columns:(NSUInteger)colCount
{
	// Internal constructor: Construct a Matrix object using a pre-allocated array of values
	// The Matrix object assumes ownership of the array
	self = [super init];
	if (self!=nil) {
		rows = rowCount;
		columns = colCount;
		values = array;
	}
	return self;
}

#pragma mark Properties

@synthesize rows, columns;

- (BOOL)isIdentity
{
	NSUInteger r,c;
	for (r=0; r<rows; r++) {
		for (c=0; c<columns; c++) {
			if ( IVALUE(r,c) != ( (r==c) ? 1.0 : 0.0 ) ) {
				return NO;
			}
		}
	}
	return YES;
}

- (double)valueAtRow:(NSUInteger)row column:(NSUInteger)column
{
	NSParameterAssert(row<rows);
	NSParameterAssert(column<columns);
	return IVALUE(row,column);
}

#pragma mark Math

- (Matrix*)addMatrix:(Matrix*)matrix
{
	NSParameterAssert(rows==matrix.rows);
	NSParameterAssert(columns==matrix.columns);

	__strong double *sumArray = MatrixAllocateArray(rows,columns);
	NSUInteger r,c;
	for (r=0; r<rows; r++) {
		for (c=0; c<columns; c++) {
			VALUE(sumArray,columns,r,c) = IVALUE(r,c)+[matrix valueAtRow:r column:c];
			}
		}
	return [[Matrix alloc] initWithAllocatedArray:sumArray rows:rows columns:columns];
}

- (Matrix*)multiplyMatrix:(Matrix*)matrix
{
	NSParameterAssert(columns==matrix.rows);
	
	__strong double *productArray = MatrixAllocateArray(rows,matrix.columns);
	NSUInteger r,c,n;
	for (r=0; r<rows; r++) {
		for (c=0; c<matrix->columns; c++) {
			double v = 0.0;
			for (n=0; n<columns/*or matrix->rows*/; n++ ) {
				v += IVALUE(r,n)*[matrix valueAtRow:n column:c];
			}
			VALUE(productArray,matrix->columns,r,c) = v;
		}
	}
	return [[Matrix alloc] initWithAllocatedArray:productArray rows:rows columns:matrix->columns];
}

- (Matrix*)multiplyScalar:(double)scalar
{
	__strong double *productArray = MatrixAllocateArray(rows,columns);
	NSUInteger r,c;
	for (r=0; r<rows; r++) {
		for (c=0; c<columns; c++) {
			VALUE(productArray,columns,r,c) = IVALUE(r,c)*scalar;
		}
	}
	return [[Matrix alloc] initWithAllocatedArray:productArray rows:rows columns:columns];
}

- (Matrix*)transpose
{
	__strong double *transArray = MatrixAllocateArray(columns,rows);
	NSUInteger r,c;
	for (r=0; r<rows; r++) {
		for (c=0; c<columns; c++) {
			VALUE(transArray,rows,c,r) = IVALUE(r,c);
		}
	}
	return [[Matrix alloc] initWithAllocatedArray:transArray rows:columns columns:rows];
}

- (NSString*)description
{
	NSMutableString *s = [NSMutableString new];
	//[s appendString:[self className]];
	NSUInteger r,c;
	for (r=0; r<rows; r++) {
		[s appendString:@"\r"];
		for (c=0; c<columns; c++) {
			[s appendFormat:@"%c%5.1f",(c==0?'[':','),IVALUE(r,c)];
		}
		[s appendString:@"]"];
	}
	if ([self isIdentity])
		[s appendString:@" (identity)"];
	return s;
}

@end

#pragma mark C Array Utilities

double *MatrixCopyArray( const __strong double *srcArray, NSUInteger rows, NSUInteger columns )
{
	// Duplicate an array
	__strong double *duplicateArray = MatrixAllocateArray(rows,columns);
	NSCopyMemoryPages(srcArray,duplicateArray,SIZEOFARRAY(rows,columns));
	return duplicateArray;
}

double *MatrixAllocateEmptyArray( NSUInteger rows, NSUInteger columns )
{
	// Allocate a matrix array and fill it with zeros
	__strong double *emptyArray = MatrixAllocateArray(rows,columns);
	bzero(emptyArray,SIZEOFARRAY(rows,columns));
	return emptyArray;
}

double *MatrixAllocateArray( NSUInteger rows, NSUInteger columns )
{
	// Allocate an array to hold [rows][columns] matrix values
	NSCParameterAssert(rows!=0);
	NSCParameterAssert(columns!=0);
	__strong double *array = NSAllocateCollectable(SIZEOFARRAY(rows,columns),NSScannedOption);
	NSCAssert2(array!=NULL,@"falled to allocate %dx%d matrix",rows,columns);
	
	return array;
}
