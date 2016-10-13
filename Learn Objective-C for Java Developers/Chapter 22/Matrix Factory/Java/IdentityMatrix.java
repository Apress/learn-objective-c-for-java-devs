package com.apress.java;

class IdentityMatrix extends Matrix {

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
	
	/**
	 * Create an identity matrix.
	 * 
	 * @param dimensions	the dimensions of the identity matrix
	 */
	protected IdentityMatrix( int dimensions )
	{
		super(dimensions,dimensions);
		for (int i=0; i<dimensions; i++)
			this.values[(i*dimensions)+i] = 1.0;
	}
	
	/**
	 * Internal constructor that creates an identity matrix from
	 * an array of prepared values with a given dimension.
	 * <p>
	 * The values in the array are known to form an identity matrix.
	 * 
	 * @param values		identity matrix values array
	 * @param copyValues	true if constructor should make a copy of the values
	 * @param dimensions	dimensions of matrix
	 */
	protected IdentityMatrix( double[] values, boolean copyValues, int dimensions )
	{
		super(values,copyValues,dimensions,dimensions);
		//assert(Matrix.isIdentityMatrix(values,dimensions,dimensions));
	}

	@Override
	public boolean isIdentity()
	{
		return true;
	}
	
	/* You could also optimize the add() method too,
	 * but how much it could be speed up would have
	 * to be determined experimentally, and might not
	 * be worth the effort.
	 */
	// public Matrix add(Matrix matrix)

	@Override
	public Matrix multiply(Matrix right)
	{
		return right;
	}

	@Override
	protected Matrix leftMultiply(Matrix leftMatrix)
	{
		return leftMatrix;
	}

	@Override
	public Matrix transpose()
	{
		return this;
	}

}
