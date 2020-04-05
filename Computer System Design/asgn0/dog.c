#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> /*size_t definitions*/
#include <fcntl.h> /*File management*/
#include <err.h> /*warn(3)*/

#define BUF_SIZE 4096

int main(int argc, char *argv[]){
	char buffer[BUF_SIZE];
	/*Check for Valid usage*/
	if(argc <= 1){
		size_t n;
		while((n = read(0, buffer, BUF_SIZE)) > 0){
			write(1, buffer, n);
		} 
		/*fprintf(stderr, "Error: usage: ./cat filename\n");*/
		return 0;
	}

	/*Using loop to open each file*/
	size_t i;
	int file;
	for(i = 1; i < argc; i++){
		if(argv[i][0] == '-'){
			size_t n;
			while((n = read(0, buffer, BUF_SIZE)) > 0){
				write(1, buffer, n);
			} 
			continue;
		}
		file = open(argv[i], O_RDONLY);
		/*Check if the file exist*/
		if (file < 0){
			fprintf(stderr, "File could not be opened.\n");
			return 1;
		}
		/*Read and write, copy input to output*/
		/*Check if the file runs into an error, if it is, then skip to next file*/
		size_t n;
		while((n = read(file, buffer, BUF_SIZE)) > 0){
			write(1, buffer, n);
		} 

		if ((n = read (file, buffer, BUF_SIZE)) < 0){
			warnx("dog: file :No such file or directory\n");	
			continue;
		}
		/*close the file*/
		close(file);
	}
	return 0;
}
