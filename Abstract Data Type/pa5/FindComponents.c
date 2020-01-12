//Zhijun Yang
//zyang100
//pa5


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Graph.h"




int main(int argc, char* argv[]) {

	int vertice = 0;
	List S = newList();
	int first, second;
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

	for(int i = 1; i<=vertice; i++){
		append(S, i);
	}

	while(fscanf(in,"%d" "%d", &first, &second)==2){
		if(first == 0 && second == 0){
			break;
		}
		else{
		addArc(G,first, second);
		}
	}
	//S = newList();

	fprintf(out, "Adjacency list representation of G:\n");
	printGraph(out, G);
	fprintf(out, "\n");
	fprintf(out, "Before running DFS");
	DFS(G,S);
	fprintf(out, "It doesn't reach here\n");
	Graph T = transpose(G);
	DFS(T, S);

	int SCC = 0;

	moveBack(S);
	while(index(S)!= -1){
		if(getParent(T, get(S)) == NIL){
			SCC++;
		}
		movePrev(S);
	}

	
	fprintf(out,"\nG contains %d strongly connected components:\n", SCC);

	List* LSCC = calloc(SCC+1, sizeof(List));
	int i = 1;
	while(i <= SCC){
		LSCC[i] =  newList();
		i++;
	}
	int iSCC=1;
	moveBack(S);
	while(index(S)!= -1){
		prepend(LSCC[iSCC], get(S));
		if(getParent(T,get(S)) == NIL){
			fprintf(out, "Component %d: ", iSCC);
			printList(out, LSCC[iSCC]);
			fprintf(out, "\n");
			iSCC++;
		}
		movePrev(S);
	}

	freeGraph(&G);   
  	freeGraph(&T);
  	freeList(&S);

  	fclose(in);
  	fclose(out);
  	return(0);
  }
	

