//
//  IdentityMatrix.m
//
//  Created by James Bucanek on 6/5/09.
//  Copyright 2009 Apress. All rights reserved.
//

#import "IdentityMatrix.h"
#import "Matrix+Private.h"


@implementation IdentityMatrix

#pragma mark Properties

- (BOOL)isIdentity
{
	return YES;
}

#pragma mark Math

- (Matrix*)addMatrix:(Matrix*)matrix
{
	NSParameterAssert(rows==matrix.rows);
	NSParameterAssert(columns==matrix.columns);
	
	// Optimized add that adds 1.0 only to the diagonal elements in the matrix
	__strong double *sumArray = MatrixCopyArray(matrix->values,rows,columns);
	NSUInteger n;
	for (n=0; n<rows; n++) {
		VALUE(sumArray,columns,n,n) += 1.0;
	}
	return [[Matrix alloc] initWithAllocatedArray:sumArray rows:rows columns:columns];
}

- (Matrix*)multiplyMatrix:(Matrix*)matrix
{
	NSParameterAssert(columns==matrix.rows);
	// Identity property: M*I = M
	return matrix;
}

- (Matrix*)leftMultiplyMatrix:(Matrix*)leftMatrix
{
	NSParameterAssert(leftMatrix.columns==rows);
	// Identity property: M*I = M
	return leftMatrix;
}

- (Matrix*)transpose
{
	// Identity matrix reflection: Itr = I
	return self;
}

@end
