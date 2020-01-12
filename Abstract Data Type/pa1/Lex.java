//Zhijun Yang
//zyang100
//pa1

import java.io.*;
import java.util.Scanner;

class Lex{
	public static void main(String[] args) throws IOException{
		int i, j;
		int lineNumber = 0;
		//String[] array = new String[lineNumber];

		if(args.length != 2){
			System.err.println("Usage: Lex infile outfile");
			System.exit(1);
		}

		Scanner in = new Scanner(new File(args[0]));
		PrintWriter out = new PrintWriter(args[1]);

		while(in.hasNextLine()){
			lineNumber++;
			in.nextLine();
		}
		String[] array = new String[lineNumber];

		//sort the list by comparing
		
		List L = new List();

		//open file again
		in = new Scanner(new File(args[0]));


		for(i = 0; i < array.length; i++){
			array[i] = in.nextLine();
		}
			L.append(0);

		for(i = 1; i < lineNumber; i++) {
			String temp = array[i];
				L.moveFront();
					if(temp.compareTo(array[L.get()]) <=0 ) {
						L.prepend(i);
						continue;
					}
					L.moveBack();
					if(temp.compareTo(array[L.get()]) >=0 ) {
						L.append(i);
						continue;
					}

					while(temp.compareTo(array[L.get()]) < 0){
						L.movePrev();
					}
			
				L.insertAfter(i);
			}

		L.moveFront();
		out.print(array[L.get()]);
		L.moveNext();
		
		for(i = 1; i < lineNumber; i++) {
			out.println();
         	out.print(array[L.get()]);
         	L.moveNext();
      	}
     
      	in.close();
      	out.close();
	}
}
