 

import java.io.*;
import java.util.*;

public class MadLibs {
    public static void main(String[] args) throws FileNotFoundException {

        boolean playGame = true;
        Scanner console = new Scanner(System.in);
        System.out.println("Welcome to the game of MadLibs.");
        System.out.println("I will ask you to provide various words ");
        System.out.println("and phrases to fill a story.");
        System.out.println("The result will be written to an output file.");
        while (playGame == true) {
            playGame = menu(console);
        }
        System.out.println("Thanks for playing!");
    }

    public static boolean menu(Scanner console) throws FileNotFoundException {
        System.out.print("(C)reate mad-lib, (V)iew mad-lib, (Q)uit?" + " ");
        String answer = console.nextLine();
        if (answer.charAt(0) == 'c' || answer.charAt(0) == 'C') {
            create(console);
            return true;
        }
        if (answer.charAt(0) == 'v' || answer.charAt(0) == 'V') {
            view(console);
            return true;
        }
        if (answer.charAt(0) == 'q' || answer.charAt(0) == 'Q') {
            return false;
        } else {
            //System.out.println("Invalid answer. Please try again.");
            return true;
        }
    }

    public static void create(Scanner console) throws FileNotFoundException {
        System.out.print("Input file name: " + " ");
        String nameIn = console.nextLine();
        File f1 = new File(nameIn);
        while (!f1.exists()) {
            System.out.print("File not found. Try again: " + " ");
            nameIn = console.nextLine();
            f1 = new File(nameIn);

            if (f1.exists()) {
                break;
            }
        }
        System.out.print("Output file name: " + " ");
        String nameOut = console.next();
        File out = new File(nameOut);
        PrintStream output = new PrintStream(out);
        Scanner input = new Scanner(f1);
        System.out.println(" ");

        if (console.hasNextLine()) {
            console.nextLine();
        }

        while (input.hasNextLine()) {

            //System.out.print(text);
            //processLine(console, f1, nameOut);
            String text = input.next();

            if (text.startsWith("<") && text.endsWith(">")) {
                //String x = input.next();
                char a = text.charAt(1);
                String word = alphabet(a);
                text = text.replace('<', ' ');
                text = text.replace('>', ' ');
                text = text.replace('-', ' ');
                //System.out.println("hello");

                System.out.print("Please type" + word + text + ":" + " ");

                String in = console.nextLine();
                output.print(in + " ");

            } else {
                output.print(text + " ");
            }

        }
        System.out.println("Your mad-lib has been created!");
        System.out.println(" ");

    }

    public static void view(Scanner console) throws FileNotFoundException {
        System.out.print("Input file name: " + " ");
        String nameIn = console.nextLine();
        File f1 = new File(nameIn);
        while (!f1.exists()) {
            System.out.print("File not found. Try again: " + " ");
            nameIn = console.nextLine();
            f1 = new File(nameIn);

            if (f1.exists()) {
                break;
            }
        }
        Scanner input = new Scanner(new File(nameIn));
        while (input.hasNextLine()) {
            String text = input.nextLine();
            StringBuilder sb = new StringBuilder(text);

            int i = 0;
            while ((i = sb.indexOf(" ", i + 50)) != -1) {
                sb.replace(i, i + 1, "\n");
            }

            System.out.println(sb.toString());
        }
        System.out.println();
    }

    public static String alphabet(char check) {
        String a;
        if (check == 'a' || check == 'A' || check == 'i' || check == 'I'
                || check == 'i' || check == 'e' || check == 'E' ||
                check == 'o' || check == 'O' || check == 'u' || check == 'U') {
            a = " an";
        } else {
            a = " a";
        }
        return a;
    }
}