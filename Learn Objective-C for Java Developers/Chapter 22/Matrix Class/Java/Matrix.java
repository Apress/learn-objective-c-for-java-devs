package com.apress.java;

public class Matrix {
	protected int rows;
	protected int columns;
	double[] values;
	
	public static void main(String[] args)
	{
		double[] a_values = {
				1.0, 0.0, 2.0,
			   -1.0, 3.0, 1.0
		};
		double[] b_values = {
				3.0, 1.0,
				2.0, 1.0,
				1.0, 0.0
		};
		Matrix A = new Matrix(a_values,2,3);
		Matrix B = new Matrix(b_values,3,2);
		Matrix I = new Matrix(3);
		System.out.println("A="+A);
		System.out.println("B="+B);
		System.out.println("I="+I);
		System.out.println("B+B="+B.add(B));
		System.out.println("A*3="+A.multiply(3.0));
		System.out.println("A*B="+A.multiply(B));
		System.out.println("A*I="+A.multiply(I));
		System.out.println("Atr="+A.transpose());
	}

	/**
	 * Create an identity matrix.
	 * 
	 * @param dimensions	the dimensions of the identity matrix
	 */
	public Matrix( int dimensions )
	{
		assert(dimensions>0);
		this.rows = dimensions;
		this.columns = dimensions;
		this.values = new double[dimensions*dimensions];
		for (int i=0; i<dimensions; i++)
			this.values[(i*dimensions)+i] = 1.0;
	}
	
	/**
	 * Create an empty matrix.
	 * 
	 * @param rows		rows in matrix
	 * @param columns	columns in matrix
	 */
	public Matrix( int rows, int columns )
	{
		this.rows = rows;
		this.columns = columns;
		this.values = new double[rows*columns];
	}
	
	/**
	 * Create a copy of a matrix
	 * 
	 * @param matrix	the original matrix
	 */
	public Matrix( Matrix matrix )
	{
		this(matrix.values,matrix.rows,matrix.columns);
	}
	
	/**
	 * Create a matrix from an array of values.
	 * <p>
	 * The values in the array are arranged so that the first row
	 * of the matrix is contained in the first |columns| number of
	 * elements, followed by the second row, and so on.
	 * <p>
	 * Matrix makes an internal copy of the values in the array.
	 * 
	 * @param values	array of values
	 * @param rows		rows in the matrix
	 * @param columns	columns in the matrix
	 */
	protected Matrix( double[] values, int rows, int columns )
	{
		this(values,true,rows,columns);
	}

	/**
	 * Internal constructor that creates a matrix from an array of values.
	 * <p>
	 * If copyValues is false, the newly created object retains a reference
	 * to the value array. It is up to the caller to ensure that the values
	 * in the array never change.
	 * 
	 * @param values		array of matrix values
	 * @param copyValues	true if constructor should make a copy of value array
	 * @param rows			rows in matrix
	 * @param columns		columns in matrix
	 */
	protected Matrix( double[] values, boolean copyValues, int rows, int columns )
	{
		assert(values.length==rows*columns);
		this.rows = rows;
		this.columns = columns;
		if (copyValues) {
			this.values = new double[values.length];
			System.arraycopy(values,0,this.values,0,rows*columns);
		} else {
			this.values = values;
		}
	}

	/**
	 * @return rows in matrix
	 */
	public int getRows()
	{
		return rows;
	}

	/**
	 * @return columns in matrix
	 */
	public int getColumns()
	{
		return columns;
	}
	
	/**
	 * @param row		row of element
	 * @param column	column of element
	 * @return			value of element at [row][column]
	 */
	public double getValue( int row, int column )
	{
		return values[row*columns+column];
	}
	
	/**
	 * @return true if this object is an identity matrix
	 */
	public boolean isIdentity( )
	{
		if (rows!=columns)
			return false;
		
		for (int r=0; r<rows; r++) {
			for (int c=0; c<columns; c++) {
				if ( values[r*columns+c] != (r==c?1.0:0.0) ) {
					return false;
				}
			}
		}
		return true;
	}
	
	/**
	 * Add two matrices.
	 * 
	 * @param matrix	matrix to add
	 * @return			sum of this and matrix
	 */
	public Matrix add( Matrix matrix )
	{
		assert(rows==matrix.rows);
		assert(columns==matrix.columns);
		
		double[] sumArray = new double[rows*columns];
		for (int r=0; r<rows; r++) {
			for (int c=0; c<columns; c++) {
				sumArray[(r*columns)+c] = getValue(r,c)+matrix.getValue(r,c);
				}
			}
		return new Matrix(sumArray,false,rows,columns);
	}
	
	/**
	 * Multiply two matrices.
	 * 
	 * @param right matrix to multiply
	 * @return product of this and right matrix
	 */
	public Matrix multiply( Matrix right )
	{
		assert(columns==right.rows);
	
		// Each value in the product is the sum of the elements
		//	in a row of the left matrix times the corresponding
		//	element in the corresponding column of the right matrix.
		double[] productArray = new double[rows*right.columns];
		for (int r=0; r<rows; r++) {
			for (int c=0; c<right.columns; c++) {
				double v = 0.0;
				for (int n=0; n<columns; n++) {
					v += getValue(r,n)*right.getValue(n,c);
					}
				productArray[(r*right.columns)+c] = v;
				}
			}
		return new Matrix(productArray,false,rows,right.columns);
	}
	
	/**
	 * Multiply matrix by a scalar value.
	 * 
	 * @param scalar value to multiply
	 * @return product of this matrix and scalar
	 */
	public Matrix multiply( double scalar )
	{
		double[] productArray = new double[rows*columns];
		for (int r=0; r<rows; r++) {
			for (int c=0; c<columns; c++) {
				productArray[(r*columns)+c] = getValue(r,c)*scalar;
				}
			}
		return new Matrix(productArray,false,rows,columns);
	}
	
	/**
	 * Transpose matrix.
	 * 
	 * @return transposed matrix
	 */
	public Matrix transpose( )
	{
		double[] transArray = new double[rows*columns];
		for (int r=0; r<rows; r++) {
			for (int c=0; c<columns; c++) {
				transArray[(c*rows)+r] = getValue(r,c);
				}
			}
		return new Matrix(transArray,false,columns,rows);
	}
	
	public String toString( )
	{
		StringBuilder s = new StringBuilder();
		for (int r=0; r<rows; r++) {
			s.append("\n");
			for (int c=0; c<columns; c++) {
				s.append(c==0?'[':',');
				s.append(String.format("%5.1f",values[(r*columns)+c]));
				}
			s.append(']');
			}
		return s.toString();
	}
}
