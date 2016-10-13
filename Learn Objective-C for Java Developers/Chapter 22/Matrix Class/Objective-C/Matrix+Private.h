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

#define VALUE(ARRAY,COLUMNS,ROW,COLUMN)		ARRAY[((ROW)*(COLUMNS))+(COLUMN)]
#define IVALUE(ROW,COLUMN)					VALUE(values,columns,ROW,COLUMN)
#define SIZEOFARRAY(ROWS,COLUMNS)			(sizeof(double)*(ROWS)*(COLUMNS))

@interface Matrix ()

- (id)initWithAllocatedArray:(__strong double*)array rows:(NSUInteger)rowCount columns:(NSUInteger)colCount;

@end
