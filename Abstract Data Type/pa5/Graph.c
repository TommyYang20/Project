//Zhijun Yang
//zyang100
//pa5

#include <stdio.h>
#include <stdlib.h>
#include "Graph.h"
#include "List.h"

#define BLACK 0
#define GRAY 1
#define WHITE 2

#define INF -1
#define NIL 0

typedef struct GraphObj{
	int* parent;
	int order;
	int size;
	int *discover;
	int *finish;
	List* adj;
	int* color;
}GraphObj;

Graph newGraph(int n){
	if (n<1) {
		printf("Graph error:newGraph is invalid");
		exit(1);
	}
	Graph G = malloc(sizeof(GraphObj));
	G->size = 0;
	G->order = n;
	G->color = calloc((n+1), sizeof(int));
	G->parent = calloc((n+1), sizeof(int));
	G->adj = calloc((n+1), sizeof(List));
	G->discover = calloc((n+1), sizeof(int));
	G->finish = calloc((n+1),sizeof(int));
	
	int i = 1;
	while(i <= n){
		G->adj[i] = newList();
		G->parent[i] = NIL;
		G->discover[i] = UNDEF;
		G->finish[i] =  UNDEF;
		G->color[i] = WHITE;
		i++;
	}
	return G;
}

void freeGraph(Graph *pG){
	int i = 1;
		while(i <=getOrder(*pG)){
			freeList(&(*pG)->adj[i]);
			free((*pG)->adj[i]);
			i++;
		}
	free((*pG)->adj);
	free((*pG)->parent);
	free((*pG)->color);
	free((*pG)->discover);
	free((*pG)->finish);
	free(*pG);
	(*pG) = NULL;
}

int getOrder(Graph G){
	if(G!=NULL){
		return G->order;
	}else{
		printf("Error: getOrder is NULL");
		exit(1);
	}
}

int getSize(Graph G){
	if(G!=NULL){
		return G->size;
	}else{
		printf("Error: getSize is NULL");
		exit(1);
	}
}

int getParent(Graph G,int u){
	if(G == NULL){
		printf("Error: getParent is NULL");
		exit(1);
	}else{
		if ((0 >= u) || (u > G->order)){
			printf("Error: getParent is invalid");
			exit(1);
		}
	}	
	return G->parent[u];
}

int getDiscover(Graph G, int u){
	if(G == NULL){
		printf("Error: getDiscover is NULL");
		exit(1);
	}else{
		if ((1 > u) || (u > G->order)){
			printf("Error: getDiscover is invalid");
			exit(1);
		}
	}	
	return G->discover[u];
}

int getFinish(Graph G, int u){
	if(G == NULL){
		printf("Error: getFinish is NULL");
		exit(1);
	}else{
		if ((1 > u) || (u > G->order)){
			printf("Error: getFinish is invalid");
			exit(1);
		}
	}	
	return G->finish[u];
}

void makeNull(Graph G){
	if (G == NULL){
		printf("Error: makeNull is NULL");
		exit(1);
	}
	else if (G != NULL){
		for(int i = 1; i < getOrder(G); i++){
			clear(G->adj[i]);
	}
		G->size = 0;
	}else{
		printf("Error: makeNull is NULL");
		exit(1);
	}
}

void addEdge (Graph G, int u, int v){
	if (G == NULL){
		printf("Error: addEdge is NULL");
		exit(1);
	}else{
		if (1 > u || 1 > v){
			printf("Error: addEdge has invalid indices\n");
			exit(1);
		}
		if (u > getOrder(G) || v > getOrder(G)){
			printf("Error: addEdge is out of bound\n");
			exit(1);
		}
	}
	addArc(G, u , v);
	addArc(G, v, u);
	G->size--;
}

void addArc(Graph G, int u, int v){
	if(G == NULL){
		printf("Error: addArc is NULL");
		exit(1);
	}else{
		if (1 > u || 1 > v ){
			printf("Error: addArc has invalid indices");
			exit(1);
		}
		if (u > getOrder(G) || v > getOrder(G)){
			printf("Error:addArc is out of bound\n");
			exit(1);
		}
	}
	List L = G->adj[u];

	moveFront(L);
	while(index(L)!= -1 && v > get(L)){
		moveNext(L);
	}
	if (index(L) == -1){
		append(L, v);
	}
	else{
		insertBefore(L, v);
	}
	G->size++;
}

void Visit(Graph G, List S, int u, int *time){
	if(G == NULL){
		printf("Error: Visit is NULL");
		exit(1);
	}
	G->color[u] = GRAY;
	G->discover[u] = ++*time;
	List adj = G->adj[u];
	moveFront(adj);
	while(index(adj)>=0){
		int v = get(adj);
		if(G->color[v] == WHITE){
			G->parent[v] = u;
			Visit(G, S, v, time);
		}
		moveNext(adj);
	}
	G->color[u] = BLACK;
	G->finish[u] = ++*time;
	prepend(S,u);
}

void DFS(Graph G, List S){
	if(G == NULL){
		printf("Error: DFS is NULL");
		exit(1);
	}
	if(S == NULL){
		printf("Error: list is NULL");
		exit(1);
	}
	if (length(S)!= getOrder(G)){
		printf("Error: DFS with wrong length");
		exit(1);
	}
	for(int i =1;i<= getOrder(G); i++){
		G->color[i] = WHITE;
		G->parent[i] = NIL;
		G->discover[i]= UNDEF;
		G->finish[i] = UNDEF;
	}
	int time = 0;
	moveFront(S);

	while(index(S) >= 0){
		int u = get(S);
		if(G->color[u] == WHITE){
			Visit(G, S, u,  &time);
		}
		moveNext(S);
	}
	int size = length(S)/2;
	while(size > 0){
		deleteBack(S);
		size--;
	}
}

Graph transpose(Graph G){
	if(G == NULL){
		printf("Error: tranpose is NULL");
		exit(1);
	}
	Graph T = newGraph(getOrder(G));
	int i = 1;
	while (i <= getOrder(G)){
		moveFront(G->adj[i]);
		if (length(G->adj[i])> 0){
			while(index(G->adj[i]) != -1){
				addArc(T, get(G->adj[i]), i);
				moveNext(G->adj[i]);
			}
		}
		i++;
	}
	return T;
}

Graph copyGraph(Graph G){
	if(G == NULL){
		printf("Error: copyGraph is NULL");
		exit(1);
	}
	Graph C = newGraph(getOrder(G));
	int i = 1;
	while(i <= getOrder(G)) {
		moveFront(G->adj[i]);
		while(index(G->adj[i]) >= 0) {
			addArc(C, i, get(G->adj[i]));
			moveNext(G->adj[i]);

		}
		i++;
	}
	return C;
}

void printGraph(FILE* out, Graph G){
	if(G == NULL){
		printf("Error: Graph is NULL");
		exit(1);
	}
	if (out == NULL){
		printf("Error: printGraph is NULL");
		exit(1);
	}

	for (int i = 1; i <= getOrder(G); i++){
		fprintf(out,"%d:", i);
		printList(out, G->adj[i]);
		fprintf(out, "\n");
	}
}



