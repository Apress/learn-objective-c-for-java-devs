/*
 *	TicTacToeDefs.h
 *	TicTacToe
 *
 *	Created by James Bucanek on 5/22/09.
 *	Copyright 2009 Apress. All rights reserved.
 *
 */

// The value of a single square
typedef enum {
	MARK_EMPTY = 0,
	MARK_X = 1,
	MARK_O = 2
} SquareMark;
#define ComplementaryMark(MARK) ((3-MARK)%3)	// 0->0, 1->2, 2->1

// Players are assigned the same values as marks
#define Player		SquareMark
#define PLAYER_NONE MARK_EMPTY
#define PLAYER_X	MARK_X
#define PLAYER_O	MARK_O

typedef struct {
	SquareMark mark[3];				// A row of three squares
} Row;

typedef unsigned int SquareIndex;	// The index (address) of a square on the board
typedef struct {
	SquareIndex index[3];			// A row of game board indexes
} SquareMap;

#define INVALID_MOVE	9			// An invalid square
typedef SquareMark Board[9];		// A playing board consists of nine squares

