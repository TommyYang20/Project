//Zhijun Yang
//zyang100
//pa2

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "List.h"

#define MAX_LEN 1000

int main(int argc, char *argv[]){
	int i;
	List L = newList();

	if(argc != 3){
		printf("Usage: %s <input file> <output file>\n", argv[0]);
		exit(1);
	}

	FILE *in = fopen(argv[1], "r");
	FILE *out = fopen(argv[2],"w");

	char buffer[MAX_LEN];
  if(in == NULL){
		printf("Unable to open file %s for reading\n", argv[1]);
    exit(1);
  }

  if(out == NULL ){
    printf("Unable to open file %s for writing\n", argv[2]);
    exit(1);
  }

  int count = 0;
  while(fgets(buffer, MAX_LEN, in) != NULL){
   	count++;
  }
   	
  char **fileArray = (char **)malloc(count *sizeof(char *));

  i = 0;
  while(i < count){
  fileArray[i]= (char *)malloc(MAX_LEN * sizeof(char));
    i++;
  }

  rewind(in);

  int lines = 0;

  while(fgets(buffer, MAX_LEN, in) != NULL) {
		strcpy(fileArray[lines++], buffer);
	}

	append(L,0);

	i = 1;
	while(i<count){
		moveFront(L);
		while(index(L)>=0){
			if(strcmp(fileArray[i], fileArray[get(L)])< 0){
				if(index(L) == 0) {
                    prepend(L,i);
                    break;
                }
                insertBefore(L,i);
                break;
            }
            moveNext(L);
        }

        if(index(L) < 0) {
            append(L,i);
        }
        i++;
    }
    moveFront(L);

  for(i = 0;i < count;i++){
    fprintf(out, "%s", fileArray[get(L)]);
    moveNext(L);
  }
  
    fclose(in);
    fclose(out);
    freeList(&L);
 }


