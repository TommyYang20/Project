//Zhijun(Tommy) Yang
//1658412
//CMPS 101
//pa1

//Based on FileIO.java
import java.io.*;
import java.util.Scanner;

class Lex {
	public static void main (String[] args) throws IOException {
		Scanner in = null;
		PrintWriter out = null;
		String[] token = null;
		int i, n =0;
		int lineNumber =0;
		int line = -1;

		//makes sure two arguements are inputted
		if(args.length != 2) {
			System.err.println("Usage: FileIO infile outfile");
			System.exit(1);
		}

		in = new Scanner(new File(args[0]));
		out = new PrintWriter(new FileWriter(args[1]));




		//counts number of lines
		while(in.hasNextLine()) {
			lineNumber++;
			in.nextLine();
		}
		in.close();
		in = null;

		List list = new List();
		token = new String[lineNumber];
		in = new Scanner(new File(args[0]));
		out = new PrintWriter(new FileWriter(args[1]));

		//inputs values to token array
		while(in.hasNextLine()){
			token[++line] = in.nextLine();
		}
		list.append(0);

		//based off of insertion sort
		for(int j = 1; j < token.length; j++) {
			i = j - 1;
			String tmp = token[j];
			list.moveBack();
			while(i >= 0 && tmp.compareTo(token[list.get()]) <= 0) {
				list.movePrev();
				i--;
			}
			if(list.index() >= 0) list.insertAfter(j);
			else list.prepend(j);
		}

		list.moveFront();
		while(list.index() >= 0) {
			out.println(token[list.get()]);
			list.moveNext();
		}

		in.close();
		out.close();
	}
}
