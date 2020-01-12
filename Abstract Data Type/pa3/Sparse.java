//Zhijun Yang
//zyang100	
//pa3

import java.io.*;
import java.util.Scanner;

public class Sparse{
	public static void main(String[] args) throws IOException{
		Scanner in = new Scanner(new File(args[0]));
		PrintWriter out = new PrintWriter(new FileWriter(args[1]));

		if (args.length != 2){
			System.err.println("Usage: FileIO infile outfile");
			System.exit(1);
		}

		int num, listA, listB;
		num = in.nextInt();
		Matrix A,B;

		A = new Matrix(num);
		B = new Matrix(num);
		listA = in.nextInt();
		listB = in.nextInt();

		int i = 0;
		while(i < listA){
			int rowA= in.nextInt();
			int colA = in.nextInt();
			double valA = in.nextDouble();
			A.changeEntry(rowA, colA, valA);
			i++;
		}

		int j = 0;
		while(j < listB){
			int rowB = in.nextInt();
			int colB = in.nextInt();
			double valB = in.nextDouble();
			B.changeEntry(rowB, colB, valB);
			j++;
		}

		out.println("A has " + A.getNNZ() + " non-zero entries:\n" + A);
        out.println("B has " + B.getNNZ() + " non-zero entries:\n" + B);
        out.println("(1.5)*A = \n" + A.scalarMult(1.5));
        out.println("A+B = \n" + A.add(B));
        out.println("A+A = \n" + A.add(A));
        out.println("B-A = \n" + B.sub(A));
        out.println("A-A = \n" + A.sub(A));
        out.println("Transpose(A) = \n" + A.transpose());
        out.println("A*B = \n" + A.mult(B));
        out.print("B*B = \n" + B.mult(B));
		
		in.close();
		out.close();
	}
}
