/*
 *  Matrix+Private.h
 *
 *  Created by James Bucanek on 6/4/09.
 *  Copyright 2009 Apress. All rights reserved.
 *
 */

#import "Matrix.h"

// Private declarations used by Matrix

extern double *MatrixCopyArray( const __strong double *srcArray, NSUInteger rows, NSUInteger columns );
extern double *MatrixAllocateEmptyArray( NSUInteger rows, NSUInteger columns );
extern double *MatrixAllocateArray( NSUInteger rows, NSUInteger columns );
extern BOOL MatrixIsIdentity( const __strong double *array, NSUInteger rows, NSUInteger columns );

// Some preprocessor macros that make addressing the matrix values easier to write
#define VALUE(ARRAY,COLUMNS,ROW,COLUMN)		ARRAY[((ROW)*(COLUMNS))+(COLUMN)]
#define IVALUE(ROW,COLUMN)					VALUE(values,columns,ROW,COLUMN)
// Macro to calculate the size (in bytes) of a matrix given its dimensions
#define SIZEOFARRAY(ROWS,COLUMNS)			(sizeof(double)*(ROWS)*(COLUMNS))

@interface Matrix ()

- (id)initWithAllocatedArray:(__strong double*)array rows:(NSUInteger)rowCount columns:(NSUInteger)colCount;

- (Matrix*)leftMultiplyMatrix:(Matrix*)leftMatrix;

@end
