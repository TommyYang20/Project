//Zhijun Yang
//zyang100	
//pa4

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Graph.h"
#include "List.h"



int main(int argc, char* argv[]){
	
	int vertice;
	List L;
	int first, second;
	int source, destination;
	FILE *in, *out;

	if (argc!= 3){
		printf("Usage:<input file> <output file>");
		exit(1);
	}
	in = fopen(argv[1], "r");
	out = fopen(argv[2],"w");

	if (in == NULL){
		printf("Unable to open %s for reading\n", argv[1]);
		exit(1);
	}
	if (out == NULL){
		printf("Unable to open %s for writing\n", argv[2]);
		exit(1);
	}

	fscanf(in,"%d", &vertice);
	Graph G = newGraph(vertice);

	while(fscanf(in,"%d" "%d", &first, &second)==2){
		if(first == 0 && second == 0){
			break;
		}
		else{
		addEdge(G,first,second);
		}
	}
	printGraph(out,G);
	L = newList();
	

	while(fscanf(in, "%d %d", &source, &destination)){
		if(source == 0 && destination == 0){
			break;
		}
		BFS(G, source);
		getPath(L, G, destination);
		if (getDist(G, destination) != INF) {
			fprintf(out, "\n\nThe distance from %d to %d is %d\n", source, destination, getDist(G, destination));
			fprintf(out, "A shortest %d-%d path is: ", source, destination);
			printList(out, L);
		} else {
			fprintf(out, "\n\nThe distance from %d to %d is infinity\n", source, destination);
			fprintf(out, "No %d-%d path exists", source, destination);
		}
		clear(L);
	}

	freeGraph(&G);
	freeList(&L);
	fclose(in);
	fclose(out);
}
