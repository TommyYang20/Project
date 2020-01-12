//Zhijun Yang
//zyang100
//pa3

public class MatrixTest {
    public static void main(String[] args) {
        int size = 10;
        /*Matrix A = new Matrix(size);
        Matrix B = new Matrix(size);

        for(int i = 1; i<=size; i++)
        {
            for(int j = 1; j<=size; j++)
            {
                A.changeEntry(i,j,size-j);
                B.changeEntry(i,j,j);
            }
        }
 	  */
 	    Matrix A = new Matrix(10);
        A.changeEntry(2, 1, 2);
        A.changeEntry(3, 1, 5);
        A.changeEntry(1, 2, 2);
        A.changeEntry(1, 3, 5);
        A.changeEntry(1, 1, 4);
        A.changeEntry(2, 2, 2);
        A.changeEntry(2, 5, 0);
        A.changeEntry(2, 3, 0);
        A.changeEntry(3, 3, 5);
      System.out.println(A.getNNZ());
      System.out.println(A);

      /*System.out.println(B.getNNZ());
      System.out.println(B);

      Matrix C = A.add(A);
      System.out.println(C.getNNZ());
      System.out.println(C);

      Matrix D = A.sub(A);
      System.out.println(D.getNNZ());
      System.out.println(D);

      Matrix E = A.scalarMult(2.0);
      System.out.println(E.getNNZ());
      System.out.println(E);

      Matrix F = B.transpose();
      System.out.println(F.getNNZ());
      System.out.println(F);

      Matrix G = B.mult(B);
      System.out.println(G.getNNZ());
      System.out.println(G);*/
  }
}

