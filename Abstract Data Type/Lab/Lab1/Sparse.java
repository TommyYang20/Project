import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;

public class Sparse {

    public static void main(String[] args) throws IOException {
        if (args.length != 2)
            System.out.println("System requires 2 args to execute");

        Scanner in = new Scanner(new File(args[0]));
        PrintWriter out = new PrintWriter(new FileWriter(args[1]));

        int size = in.nextInt()+1;
        Matrix A = new Matrix(size);
        Matrix B = new Matrix(size);
        int nnzA = in.nextInt();
        int nnzB = in.nextInt();


        int index = 0;
        if (index < nnzA) {
            do {
                int rowA = in.nextInt();
                int colA = in.nextInt();
                double valA = in.nextDouble();
                A.changeEntry(rowA, colA, valA);
                index++;
            } while (index < nnzA);
        }
        int j = 0;
        if (j < nnzB) {
            do {
                int rowB = in.nextInt();
                int colB = in.nextInt();
                double valB = in.nextDouble();
                B.changeEntry(rowB, colB, valB);
                j++;
            } while (j < nnzB);
        }

        out.println("A has " + A.getNNZ() + " non-zero entries:");
        out.println(A);

        out.println("B has " + B.getNNZ() + " non-zero entries:");
        out.println(B);

        out.println("(1.5) * A =");
        out.println(A.scalarMult(1.5));

        out.println("A+ B =");
        out.println(A.add(B));

        out.println("A + A =");
        out.println(A.add(A));

        out.println("B - A =");
        out.println(B.sub(A));

        out.println("A - A=");
        out.println(A.sub(A));

        out.println("Transpose(A) =");
        out.println(A.transpose());

        out.println("A * B =");
        out.println(A.mult(B));

        out.println("B * B =");
        out.println(B.mult(B));

        in.close();
        out.close();
    }
}
