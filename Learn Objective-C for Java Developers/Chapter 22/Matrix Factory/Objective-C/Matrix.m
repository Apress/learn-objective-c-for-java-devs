//
//  Matrix.m
//
//  Created by James Bucanek on 6/4/09.
//  Copyright 2009 Apress. All rights reserved.
//

#import "Matrix.h"
#import "Matrix+Private.h"

#import "IdentityMatrix.h"


@implementation Matrix

#pragma mark Constructors

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
		// Class cluster:
		//	If the object being initialized is a Matrix object, but its content is an identity
		//	matrix, substitute an IdentityMatrix object.
		
		// Class clusters can create recursive initialization messages.
		// There are basically two ways to deal with it, both are shown here:
#if 0
		// #1: When creating a subclass, invoke a subclass initializer that
		//	   does NOT recursively invoke this one (as its superclass initializer).
		if (MatrixIsIdentity(array,rowCount,colCount)) {
			// Replace |self| with an empty, uninitialized, IdentityMatrix.
			self = [[IdentityMatrix alloc] init];
			// Fall through and let the base class initialization finish.
		}
#else
		// #2: Check the class of the object being initialized: If it's the base class,
		//	   peform the class cluster test. If not, initialize the base class and return.
		//	   This is probably the "cleaner" of the two solutions, as it makes it easier
		//	   to customize subclass initialization.
		if ([self isMemberOfClass:[Matrix class]]) {
			// Creating a base class object: perform class cluster test...
			if (MatrixIsIdentity(array,rowCount,colCount)) {
				// Creating an IdentityMatrix will recursively send -[Matrix initWithAllocatedArray:rows:columns:].
				// The class test prevents this code from executing during the nested IdentityMatrix initializer.
				return [[IdentityMatrix alloc] initWithAllocatedArray:array rows:rowCount columns:colCount];
			}
		}
#endif
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
	NSAssert(!MatrixIsIdentity(values,rows,columns),@"object class should be IdentityMatrix");
	return NO;
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
	return [matrix leftMultiplyMatrix:self];
}

- (Matrix*)leftMultiplyMatrix:(Matrix*)leftMatrix
{
	NSParameterAssert(leftMatrix.columns==rows);
	
	__strong double *productArray = MatrixAllocateArray(leftMatrix.rows,columns);
	NSUInteger r,c,n;
	for (r=0; r<leftMatrix->rows; r++) {
		for (c=0; c<columns; c++) {
			double v = 0.0;
			for (n=0; n<rows/*or left->columns*/; n++ ) {
				v += [leftMatrix valueAtRow:r column:n]*IVALUE(n,c);
			}
			VALUE(productArray,columns,r,c) = v;
		}
	}
	return [[Matrix alloc] initWithAllocatedArray:productArray rows:leftMatrix.rows columns:columns];
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
	[s appendString:[self className]];
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

BOOL MatrixIsIdentity( const __strong double *array, NSUInteger rows, NSUInteger columns )
{
	if (rows!=columns)
		return NO;
	
	NSUInteger r,c;
	for (r=0; r<rows; r++) {
		for (c=0; c<columns; c++) {
			if ( VALUE(array,columns,r,c) != ( (r==c) ? 1.0 : 0.0 ) ) {
				return NO;
			}
		}
	}
	return YES;
}
