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
		double[] i_values = {
				1.0, 0.0, 0.0,
				0.0, 1.0, 0.0,
				0.0, 0.0, 1.0
				};
		Matrix A = Matrix.makeMatrix(a_values,2,3);
		Matrix B = Matrix.makeMatrix(b_values,3,2);
		Matrix I = Matrix.makeMatrix(i_values,3,3);
		System.out.println("A="+A);
		System.out.println("B="+B);
		System.out.println("I="+I);
		System.out.println("B+B="+B.add(B));
		System.out.println("A*3="+A.multiply(3.0));
		System.out.println("A*B="+A.multiply(B));
		System.out.println("A*I="+A.multiply(I));
		System.out.println("Atr="+A.transpose());
	}
	
	public static Matrix makeMatrix( double[] values, int rows, int columns )
	{
		return Matrix.makeMatrix(values,false,rows,columns);
	}
	
	protected static Matrix makeMatrix( double[] values, boolean copyValues, int rows, int columns )
	{
		if (isIdentityMatrix(values,rows,columns)) {
			return new IdentityMatrix(values,copyValues,rows);
		}
		return new Matrix(values,copyValues,rows,columns);
	}
	
	protected static boolean isIdentityMatrix( double[] values, int rows, int columns )
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
	 * Create an empty matrix.
	 * 
	 * @param rows		rows in matrix
	 * @param columns	columns in matrix
	 */
	protected Matrix( int rows, int columns )
	{
		this.rows = rows;
		this.columns = columns;
		this.values = new double[rows*columns];
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
		return false;
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
		return Matrix.makeMatrix(sumArray,false,rows,columns);
	}
	
	/**
	 * Multiply two matrices.
	 * 
	 * @param right matrix to multiply
	 * @return product of this matrix and right matrix
	 */
	public Matrix multiply( Matrix right )
	{
		return right.leftMultiply(this);
	}
	
	/**
	 * Internal multiply where this matrix is the right matrix
	 * and the parameter is the left matrix.
	 * 
	 * @param leftMatrix left matrix to multiply
	 * @return product of left matrix and this matrix
	 */
	protected Matrix leftMultiply( Matrix leftMatrix )
	{
		assert(leftMatrix.columns==rows);
		
		// Each value in the product is the sum of the elements
		//	in a row of the left matrix times the corresponding
		//	element in the corresponding column of the right matrix.
		double[] productArray = new double[leftMatrix.rows*columns];
		for (int r=0; r<leftMatrix.rows; r++) {
			for (int c=0; c<columns; c++) {
				double v = 0.0;
				for (int n=0; n<rows; n++) {
					v += leftMatrix.getValue(r,n)*getValue(n,c);
					}
				productArray[(r*columns)+c] = v;
				}
			}
		return Matrix.makeMatrix(productArray,false,leftMatrix.rows,columns);
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
		return Matrix.makeMatrix(productArray,false,rows,columns);
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
		return Matrix.makeMatrix(transArray,false,columns,rows);
	}
	
	public String toString( )
	{
		StringBuilder s = new StringBuilder();
		//s.append(super.toString());
		for (int r=0; r<rows; r++) {
			s.append("\n");
			for (int c=0; c<columns; c++) {
				s.append(c==0?'[':',');
				s.append(String.format("%5.1f",values[(r*columns)+c]));
				}
			s.append(']');
			}
		if (isIdentity())
			s.append(" (identity)");
		return s.toString();
	}
}
