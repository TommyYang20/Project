//Zhijun(Tommy) Yang
//1658412
//zyang100@ucsc.edu

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "List.h"
#define MAX_LEN 255

int main(int argc, char * argv[]){
 int i, count=0;
   FILE *in, *out;
   char line[MAX_LEN];

    // check command line for correct number of arguments
   if( argc != 3 ){
      printf("Usage: %s <input file> <output file>\n", argv[0]);
      exit(1);
   }

   // open files for reading and writing
   in = fopen(argv[1], "r");
   out = fopen(argv[2], "w");

   if( in==NULL ){
      printf("Unable to open file %s for reading\n", argv[1]);
      exit(1);
   }
   if( out==NULL ){
      printf("Unable to open file %s for writing\n", argv[2]);
      exit(1);
   }

   //counts number of lines
   while(fgets(line, MAX_LEN, in) !=NULL){
      count++;
   }
   //holds all of the lines of file
   char Word[count][MAX_LEN];

   //back to top of file
   rewind(in);

   //copies inputs of file into Word array
   while(fgets(line, MAX_LEN, in) != NULL){
      strcpy(Word[i], line);
      i++;
   }
   fclose(in);

   List L = newList();
   append(L, 0);




   for(i = 1; i < count; i++){
            moveFront(L);

            while(index(L)>=0){
               char *temp = Word[i];

               if(strncmp(Word[get(L)], temp, MAX_LEN) > 0){
                  insertBefore(L, i);
                  break;
               }
               moveNext(L);
            }
            if(index(L) < 0){
               append(L, i);
            }
         }


  moveFront(L);

  //prints out array
  i = 0;
    while(i<count){
       fprintf(out, "%s", Word[get(L)]);
       moveNext(L);
       i++;

    }
    fclose(out);
    freeList(&L);
 }